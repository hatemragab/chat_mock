import '../../settings/models/settings_models.dart';

enum NotificationDelivery {
  delivered,
  permissionDenied,
  preferenceDisabled,
  blocked,
}

/// An in-memory event for the simulated notifications inbox.
class DemoNotification {
  const DemoNotification({
    required this.id,
    required this.kind,
    required this.sender,
    required this.message,
    required this.createdAt,
    required this.vibrates,
  });

  final int id;
  final NotificationKind kind;
  final String sender;
  final String message;
  final DateTime createdAt;
  final bool vibrates;

  String body({required bool showPreview}) {
    if (showPreview) return message;
    return switch (kind) {
      NotificationKind.message => 'New message',
      NotificationKind.group => 'New group message',
      NotificationKind.call => 'Incoming call',
    };
  }
}
