import 'package:flutter_test/flutter_test.dart';
import 'package:dental_profile/core/services/live_queue_broadcaster.dart';

void main() {
  group('LiveQueueBroadcaster Singleton Tests', () {
    test('Ensures single instance across invocations', () {
      final instance1 = LiveQueueBroadcaster.instance;
      final instance2 = LiveQueueBroadcaster.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('Broadcasts queue events to listeners in real-time', () async {
      final broadcaster = LiveQueueBroadcaster.instance;

      expectLater(
        broadcaster.eventStream,
        emits(predicate<QueueBroadcastEvent>((event) {
          return event.chamberId == 'CHAMBER-DHANMONDI' &&
              event.activeSerial == 5 &&
              event.status == 'CALLED' &&
              event.patientName == 'Kamal Hossain';
        })),
      );

      broadcaster.broadcast(
        chamberId: 'CHAMBER-DHANMONDI',
        activeSerial: 5,
        patientName: 'Kamal Hossain',
        status: 'CALLED',
        message: 'Serial #5 called to room 1',
      );
    });
  });
}
