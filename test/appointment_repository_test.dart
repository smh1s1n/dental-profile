import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_profile/features/appointment_booking/data/repositories/appointment_repository_impl.dart';
import 'package:dental_profile/features/appointment_booking/domain/models/appointment_model.dart';
import 'package:dental_profile/features/appointment_booking/domain/models/patient_model.dart';
import 'package:dental_profile/features/live_serial_queue/domain/models/chamber_queue_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppointmentRepositoryImpl Singleton Tests', () {
    test('Ensures single instance across invocations', () {
      final r1 = AppointmentRepositoryImpl.instance;
      final r2 = AppointmentRepositoryImpl.instance;
      expect(identical(r1, r2), isTrue);
    });

    test('Loads initial seeded appointments and queues', () async {
      final repo = AppointmentRepositoryImpl.instance;
      final appointments = await repo.getAppointments(chamberId: 'CHAMBER-DHANMONDI');
      expect(appointments.isNotEmpty, isTrue);

      final queue = await repo.getChamberQueueState('CHAMBER-DHANMONDI');
      expect(queue.chamberId, equals('CHAMBER-DHANMONDI'));
    });

    test('Books new appointment with auto-increment serial number', () async {
      final repo = AppointmentRepositoryImpl.instance;
      final dateStr = DateTime.now().toIso8601String().split('T').first;

      final existing = await repo.getAppointments(chamberId: 'CHAMBER-DHANMONDI', date: dateStr);
      final expectedSerial = existing.isEmpty ? 1 : existing.map((e) => e.serialNumber).reduce((a, b) => a > b ? a : b) + 1;

      final booked = await repo.bookAppointment(
        chamberId: 'CHAMBER-DHANMONDI',
        chamberName: 'SmileCraft Dental Care (Dhanmondi)',
        date: dateStr,
        slotTime: '08:30 PM',
        patient: const PatientModel(
          name: 'Shahriar Kabir',
          age: 34,
          gender: 'Male',
          phone: '01711009988',
          addressArea: 'Dhanmondi',
          medicalConditions: [],
          chiefComplaint: 'Tooth filling',
          painScale: 4,
        ),
        consultationFee: 1000,
        isFollowUp: false,
        paymentMethod: PaymentMethod.bKash,
        trxId: 'BK778899XX',
      );

      expect(booked.serialNumber, equals(expectedSerial));
      expect(booked.patient.name, equals('Shahriar Kabir'));
      expect(booked.paymentStatus, equals(PaymentStatus.paid));
    });

    test('Updates status and advances queue state', () async {
      final repo = AppointmentRepositoryImpl.instance;
      final appointments = await repo.getAppointments(chamberId: 'CHAMBER-DHANMONDI');
      final first = appointments.first;

      await repo.updateStatus(appointmentId: first.id, newStatus: AppointmentStatus.completed);

      final updated = await repo.getAppointmentById(first.id);
      expect(updated?.status, equals(AppointmentStatus.completed));
    });
  });
}
