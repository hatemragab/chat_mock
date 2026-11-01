import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/notifications_screen/notifications_screen.dart';
import 'package:app/features/settings/ui/screens/privacy_screen/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('notification preview reflects switches and denied permission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    await tester.pumpWidget(
      MaterialApp(home: NotificationsScreen(controller: settings)),
    );
    await tester.scrollUntilVisible(
      find.text('Message'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Message'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Are we still meeting later?'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Are we still meeting later?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Show previews'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Show previews'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('New message'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Are we still meeting later?'), findsNothing);
    settings.setPermission('Notifications', MockPermission.denied);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Call'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Call'));
    await tester.pump();
    expect(
      find.text('Allow notification permission to show this preview.'),
      findsOneWidget,
    );
    expect(settings.notifications.items.length, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    settings.dispose();
    chats.dispose();
  });

  testWidgets('photo preview changes for contact, other and blocked viewer', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    await tester.pumpWidget(
      MaterialApp(home: PrivacyScreen(controller: settings)),
    );
    await tester.tap(find.text('Preview photo visibility'));
    await tester.pumpAndSettle();
    expect(find.text('Profile photo visible'), findsOneWidget);
    await tester.tap(find.text('Other person'));
    await tester.pumpAndSettle();
    expect(find.text('Profile photo hidden'), findsOneWidget);
    settings.setPhotoVisibility(PhotoVisibility.everyone);
    await tester.pump();
    expect(find.text('Profile photo visible'), findsOneWidget);
    await tester.tap(find.text('Blocked'));
    await tester.pumpAndSettle();
    expect(find.text('Blocked account'), findsOneWidget);
    expect(find.text('Profile photo hidden'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    settings.dispose();
    chats.dispose();
  });
}
