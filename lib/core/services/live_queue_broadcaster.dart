import 'dart:async';

/// Real-time live queue event payload
class QueueBroadcastEvent {
  final String chamberId;
  final int activeSerial;
  final String patientName;
  final String status; // 'CALLED', 'IN_CHAMBER', 'COMPLETED', 'DELAY_NOTICE', 'EMERGENCY'
  final String message;
  final DateTime timestamp;

  QueueBroadcastEvent({
    required this.chamberId,
    required this.activeSerial,
    required this.patientName,
    required this.status,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Singleton pattern providing a live publish/subscribe stream
/// for real-time queue serialization and audio chime notifications.
class LiveQueueBroadcaster {
  LiveQueueBroadcaster._internal();

  static LiveQueueBroadcaster? _instance;

  static LiveQueueBroadcaster get instance {
    _instance ??= LiveQueueBroadcaster._internal();
    return _instance!;
  }

  final StreamController<QueueBroadcastEvent> _eventController =
      StreamController<QueueBroadcastEvent>.broadcast();

  /// Public read-only stream to subscribe anywhere in the app
  Stream<QueueBroadcastEvent> get eventStream => _eventController.stream;

  /// Broadcast a new serial call or queue state update
  void broadcast({
    required String chamberId,
    required int activeSerial,
    required String patientName,
    required String status,
    required String message,
  }) {
    _eventController.add(
      QueueBroadcastEvent(
        chamberId: chamberId,
        activeSerial: activeSerial,
        patientName: patientName,
        status: status,
        message: message,
      ),
    );
  }

  void dispose() {
    _eventController.close();
  }
}
