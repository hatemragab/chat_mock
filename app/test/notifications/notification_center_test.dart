import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/notifications/models/demo_notification.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications apply permission, kind preferences, blocked and preview policies', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final center = settings.notifications;
    NotificationDelivery receive(
      NotificationKind kind, {
      bool blocked = false,
    }) => center.receive(
      kind: kind,
      sender: 'Sarah Wilson',
      message: 'Meet at 5?',
      blocked: blocked,
    );

    expect(receive(NotificationKind.message), NotificationDelivery.delivered);
    expect(
      center.items.single.body(showPreview: settings.previews),
      'Meet at 5?',
    );
    expect(center.items.single.vibrates, isTrue);
    settings.setPreviews(false);
    expect(
      center.items.single.body(showPreview: settings.previews),
      'New message',
    );
    settings.setGroupNotifications(false);
    expect(
      receive(NotificationKind.group),
      NotificationDelivery.preferenceDisabled,
    );
    expect(
      receive(NotificationKind.call, blocked: true),
      NotificationDelivery.blocked,
    );
    settings.setPermission('Notifications', MockPermission.denied);
    expect(
      receive(NotificationKind.call),
      NotificationDelivery.permissionDenied,
    );
    expect(center.items.length, 1);
    settings.setPermission('Notifications', MockPermission.allowed);
    settings.setVibration(false);
    expect(receive(NotificationKind.call), NotificationDelivery.delivered);
    expect(center.items.first.vibrates, isFalse);
    settings.reset();
    expect(center.items, isEmpty);
    expect(settings.shouldNotify(NotificationKind.group), isTrue);
    settings.dispose();
    chats.dispose();
  });

  test('inbox is bounded and dismissal only removes the selected event', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final center = settings.notifications;
    for (var i = 0; i < 52; i++) {
      center.receive(
        kind: NotificationKind.message,
        sender: 'Sarah',
        message: '$i',
      );
    }
    expect(center.items.length, 50);
    expect(center.items.last.message, '2');
    final id = center.items.first.id;
    center.dismiss(id);
    expect(center.items.length, 49);
    expect(center.items.any((item) => item.id == id), isFalse);
    settings.dispose();
    chats.dispose();
  });

  test('private identity never reveals its photo to a blocked viewer', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    expect(
      settings
          .privateProfileFor(displayName: 'Alex Morgan', isContact: true)
          .photoVisible,
      isTrue,
    );
    expect(
      settings
          .privateProfileFor(displayName: 'Alex Morgan', isContact: false)
          .photoVisible,
      isFalse,
    );
    settings.setPhotoVisibility(PhotoVisibility.everyone);
    expect(
      settings
          .privateProfileFor(displayName: 'Alex Morgan', isContact: false)
          .photoVisible,
      isTrue,
    );
    final blocked = settings.privateProfileFor(
      displayName: 'Alex Morgan',
      isContact: true,
      blocked: true,
    );
    expect(blocked.displayName, 'Blocked account');
    expect(blocked.photoVisible, isFalse);
    settings.setPhotoVisibility(PhotoVisibility.nobody);
    expect(
      settings
          .privateProfileFor(displayName: 'Alex Morgan', isContact: true)
          .photoVisible,
      isFalse,
    );
    settings.dispose();
    chats.dispose();
  });
}
