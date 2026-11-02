import '../../domain/models/appointment_model.dart';
import '../../domain/models/patient_model.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/live_queue_broadcaster.dart';
import '../../../live_serial_queue/domain/models/chamber_queue_state.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getAppointments({String? chamberId, String? date});
  Future<AppointmentModel?> getAppointmentById(String id);
  Future<List<AppointmentModel>> getAppointmentsByPhone(String phone);
  Future<AppointmentModel> bookAppointment({
    required String chamberId,
    required String chamberName,
    required String date,
    required String slotTime,
    required PatientModel patient,
    required int consultationFee,
    required bool isFollowUp,
    required PaymentMethod paymentMethod,
    String? trxId,
  });
  Future<void> updateStatus({
    required String appointmentId,
    required AppointmentStatus newStatus,
    String? doctorNotes,
  });
  Future<void> updatePayment({
    required String appointmentId,
    required PaymentStatus paymentStatus,
    String? trxId,
  });
  Future<ChamberQueueState> getChamberQueueState(String chamberId);
  Future<void> updateDoctorChamberStatus({
    required String chamberId,
    required DoctorChamberStatus status,
    String? delayNotice,
  });
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl._internal();
  static final AppointmentRepositoryImpl instance = AppointmentRepositoryImpl._internal();

  static const String _storageKey = 'smilecraft_appointments_v1';
  static const String _queueKey = 'smilecraft_queues_v1';

  List<AppointmentModel> _cache = [];
  Map<String, ChamberQueueState> _queueStates = {};
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final storage = StorageService.instance;
    await storage.init();

    final storedList = storage.getJsonList(_storageKey);
    if (storedList != null && storedList.isNotEmpty) {
      _cache = storedList.map((j) => AppointmentModel.fromJson(j)).toList();
    } else {
      _cache = MockData.getInitialAppointments();
      await _persistAppointments();
    }

    final storedQueues = storage.getJson(_queueKey);
    if (storedQueues != null && storedQueues.isNotEmpty) {
      _queueStates = storedQueues.map(
        (key, val) => MapEntry(key, ChamberQueueState.fromJson(val as Map<String, dynamic>)),
      );
    } else {
      _queueStates = MockData.getInitialQueueStates();
      await _persistQueues();
    }

    _initialized = true;
  }

  Future<void> _persistAppointments() async {
    final list = _cache.map((a) => a.toJson()).toList();
    await StorageService.instance.setJsonList(_storageKey, list);
  }

  Future<void> _persistQueues() async {
    final map = _queueStates.map((k, v) => MapEntry(k, v.toJson()));
    await StorageService.instance.setJson(_queueKey, map);
  }

  @override
  Future<List<AppointmentModel>> getAppointments({String? chamberId, String? date}) async {
    await _ensureInitialized();
    return _cache.where((a) {
      if (chamberId != null && a.chamberId != chamberId) return false;
      if (date != null && a.appointmentDate != date) return false;
      return true;
    }).toList();
  }

  @override
  Future<AppointmentModel?> getAppointmentById(String id) async {
    await _ensureInitialized();
    try {
      return _cache.firstWhere((a) => a.id.toUpperCase() == id.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByPhone(String phone) async {
    await _ensureInitialized();
    final cleanQuery = phone.replaceAll(RegExp(r'\s+|-'), '');
    return _cache.where((a) {
      final cleanPhone = a.patient.phone.replaceAll(RegExp(r'\s+|-'), '');
      return cleanPhone.contains(cleanQuery) || cleanQuery.contains(cleanPhone);
    }).toList();
  }

  @override
  Future<AppointmentModel> bookAppointment({
    required String chamberId,
    required String chamberName,
    required String date,
    required String slotTime,
    required PatientModel patient,
    required int consultationFee,
    required bool isFollowUp,
    required PaymentMethod paymentMethod,
    String? trxId,
  }) async {
    await _ensureInitialized();

    // Calculate next serial for this chamber & date
    final existingToday = _cache.where((a) => a.chamberId == chamberId && a.appointmentDate == date).toList();
    final nextSerial = existingToday.isEmpty ? 1 : existingToday.map((e) => e.serialNumber).reduce((a, b) => a > b ? a : b) + 1;

    final token = 'DENT-${DateTime.now().year % 100}${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';

    final newAppointment = AppointmentModel(
      id: token,
      chamberId: chamberId,
      chamberName: chamberName,
      serialNumber: nextSerial,
      appointmentDate: date,
      slotTime: slotTime,
      patient: patient,
      status: AppointmentStatus.booked,
      consultationFee: consultationFee,
      isFollowUp: isFollowUp,
      paymentMethod: paymentMethod,
      paymentStatus: (paymentMethod == PaymentMethod.bKash || paymentMethod == PaymentMethod.nagad) && trxId != null && trxId.isNotEmpty
          ? PaymentStatus.paid
          : PaymentStatus.pending,
      trxId: trxId,
      createdAt: DateTime.now(),
    );

    _cache.add(newAppointment);
    await _persistAppointments();

    // Update queue summary
    _recalculateQueueState(chamberId, date);
    await _persistQueues();

    // Broadcast new booking
    LiveQueueBroadcaster.instance.broadcast(
      chamberId: chamberId,
      activeSerial: _queueStates[chamberId]?.activeSerial ?? 0,
      patientName: patient.name,
      status: 'BOOKED',
      message: 'New appointment booked: Serial #$nextSerial for ${patient.name}',
    );

    return newAppointment;
  }

  @override
  Future<void> updateStatus({
    required String appointmentId,
    required AppointmentStatus newStatus,
    String? doctorNotes,
  }) async {
    await _ensureInitialized();
    final index = _cache.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;

    final old = _cache[index];
    final updated = old.copyWith(
      status: newStatus,
      doctorNotes: doctorNotes ?? old.doctorNotes,
    );
    _cache[index] = updated;
    await _persistAppointments();

    // Update Live Chamber State
    final chamberId = updated.chamberId;
    var state = _queueStates[chamberId] ?? MockData.getInitialQueueStates()[chamberId]!;

    int newActiveSerial = state.activeSerial;
    String? newPatientName = state.activePatientName;

    if (newStatus == AppointmentStatus.called || newStatus == AppointmentStatus.inChamber) {
      newActiveSerial = updated.serialNumber;
      newPatientName = updated.patient.name;
    }

    _recalculateQueueState(chamberId, updated.appointmentDate, activeSerial: newActiveSerial, activePatientName: newPatientName);
    await _persistQueues();

    // Broadcast live event for Waiting Room Display & Patient mobile trackers!
    LiveQueueBroadcaster.instance.broadcast(
      chamberId: chamberId,
      activeSerial: newActiveSerial,
      patientName: updated.patient.name,
      status: newStatus.name.toUpperCase(),
      message: 'Serial #$newActiveSerial (${updated.patient.name}): ${updated.statusDisplayEn}',
    );
  }

  @override
  Future<void> updatePayment({
    required String appointmentId,
    required PaymentStatus paymentStatus,
    String? trxId,
  }) async {
    await _ensureInitialized();
    final index = _cache.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;

    _cache[index] = _cache[index].copyWith(
      paymentStatus: paymentStatus,
      trxId: trxId ?? _cache[index].trxId,
    );
    await _persistAppointments();
  }

  @override
  Future<ChamberQueueState> getChamberQueueState(String chamberId) async {
    await _ensureInitialized();
    if (_queueStates.containsKey(chamberId)) {
      return _queueStates[chamberId]!;
    }
    return MockData.getInitialQueueStates()[chamberId] ??
        ChamberQueueState(
          chamberId: chamberId,
          chamberName: 'Chamber',
          date: DateTime.now().toIso8601String().split('T').first,
          activeSerial: 0,
          completedCount: 0,
          waitingCount: 0,
          totalBooked: 0,
          lastUpdated: DateTime.now(),
        );
  }

  @override
  Future<void> updateDoctorChamberStatus({
    required String chamberId,
    required DoctorChamberStatus status,
    String? delayNotice,
  }) async {
    await _ensureInitialized();
    final current = await getChamberQueueState(chamberId);
    final updated = current.copyWith(
      doctorStatus: status,
      delayNotice: delayNotice,
      lastUpdated: DateTime.now(),
    );
    _queueStates[chamberId] = updated;
    await _persistQueues();

    LiveQueueBroadcaster.instance.broadcast(
      chamberId: chamberId,
      activeSerial: updated.activeSerial,
      patientName: updated.activePatientName ?? 'N/A',
      status: 'DOCTOR_STATUS_UPDATE',
      message: '${updated.doctorStatusLabelEn}. ${delayNotice ?? ""}',
    );
  }

  void _recalculateQueueState(String chamberId, String date, {int? activeSerial, String? activePatientName}) {
    final list = _cache.where((a) => a.chamberId == chamberId && a.appointmentDate == date).toList();
    final completed = list.where((a) => a.status == AppointmentStatus.completed).length;
    final waiting = list.where((a) => a.status == AppointmentStatus.booked || a.status == AppointmentStatus.called).length;
    final total = list.length;

    final existing = _queueStates[chamberId] ?? MockData.getInitialQueueStates()[chamberId]!;

    _queueStates[chamberId] = existing.copyWith(
      activeSerial: activeSerial ?? existing.activeSerial,
      activePatientName: activePatientName ?? existing.activePatientName,
      completedCount: completed,
      waitingCount: waiting,
      totalBooked: total,
      lastUpdated: DateTime.now(),
    );
  }
}
