import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/appointment_model.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../../chamber_management/domain/models/chamber_model.dart';
import '../../../chamber_management/domain/repositories/chamber_repository.dart';
import '../../../live_serial_queue/domain/models/chamber_queue_state.dart';
import '../../../../core/services/live_queue_broadcaster.dart';

// Repositories
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl.instance;
});

final chamberRepositoryProvider = Provider<ChamberRepository>((ref) {
  return ChamberRepositoryImpl.instance;
});

// Chambers list
final allChambersProvider = FutureProvider<List<ChamberModel>>((ref) async {
  final repo = ref.watch(chamberRepositoryProvider);
  return await repo.getAllChambers();
});

// Currently selected chamber for booking / queue viewing
class SelectedChamberNotifier extends Notifier<String> {
  @override
  String build() => 'CHAMBER-DHANMONDI';

  void setChamber(String id) => state = id;
}

final selectedChamberIdProvider = NotifierProvider<SelectedChamberNotifier, String>(SelectedChamberNotifier.new);

// Today's date string YYYY-MM-DD
class SelectedDateNotifier extends Notifier<String> {
  @override
  String build() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void setDate(String date) => state = date;
}

final selectedDateStringProvider = NotifierProvider<SelectedDateNotifier, String>(SelectedDateNotifier.new);

// Appointments for selected chamber and date
final appointmentsListProvider = FutureProvider.family<List<AppointmentModel>, String>((ref, chamberId) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final date = ref.watch(selectedDateStringProvider);
  return await repo.getAppointments(chamberId: chamberId, date: date);
});

// Real-time Queue State Provider for a specific chamber
final chamberQueueNotifierProvider = FutureProvider.family<ChamberQueueState, String>((ref, chamberId) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  // Auto-refresh when event stream receives an update for this chamber
  ref.listen(liveQueueEventsProvider, (previous, next) {
    if (next.hasValue && next.value!.chamberId == chamberId) {
      ref.invalidateSelf();
    }
  });
  return await repo.getChamberQueueState(chamberId);
});

// Live Queue Broadcaster Event Stream Provider
final liveQueueEventsProvider = StreamProvider<QueueBroadcastEvent>((ref) {
  return LiveQueueBroadcaster.instance.eventStream;
});
