import 'package:flutter/foundation.dart';

import '../../settings/models/settings_models.dart';
import '../models/demo_notification.dart';

/// Produces local, inspectable notifications without invoking platform APIs.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter({
    required this.hasPermission,
    required this.shouldNotify,
    required this.vibrationEnabled,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool Function() hasPermission;
  final bool Function(NotificationKind) shouldNotify;
  final bool Function() vibrationEnabled;
  final DateTime Function() _clock;
  final List<DemoNotification> _items = [];
  int _nextId = 0;

  List<DemoNotification> get items => List.unmodifiable(_items);

  NotificationDelivery receive({
    required NotificationKind kind,
    required String sender,
    required String message,
    bool blocked = false,
  }) {
    if (blocked) return NotificationDelivery.blocked;
    if (!hasPermission()) return NotificationDelivery.permissionDenied;
    if (!shouldNotify(kind)) return NotificationDelivery.preferenceDisabled;
    _items.insert(
      0,
      DemoNotification(
        id: ++_nextId,
        kind: kind,
        sender: sender,
        message: message,
        createdAt: _clock(),
        vibrates: vibrationEnabled(),
      ),
    );
    if (_items.length > 50) _items.removeLast();
    notifyListeners();
    return NotificationDelivery.delivered;
  }

  void dismiss(int id) {
    final before = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length != before) notifyListeners();
  }

  void reset() {
    _items.clear();
    _nextId = 0;
    notifyListeners();
  }
}
