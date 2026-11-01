import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/appearance_screen/appearance_screen.dart';
import 'package:app/features/settings/ui/screens/appearance_screen/widgets/appearance_preview.dart';
import 'package:app/features/settings/ui/screens/permissions_screen/permissions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('matching uses contact relationships even when chat is hidden', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final sarah = chats.byId('sarah');
    chats.deleteConversation(sarah);
    final unmatched = chats.addContact('Unmatched', '+237600123456');
    settings.startContactMatching();
    await tester.pump(const Duration(milliseconds: 800));
    expect(settings.matchedContacts, contains(sarah));
    expect(settings.matchedContacts, isNot(contains(unmatched)));
    chats.toggleBlocked(sarah);
    expect(settings.matchedContacts, isNot(contains(sarah)));
    chats.toggleBlocked(sarah);
    expect(settings.matchedContacts, contains(sarah));
    settings.dispose();
    chats.dispose();
  });

  testWidgets('appearance changes preview and forwards theme and text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var mode = ThemeMode.light;
    var factor = 1.0;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, update) => MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: AppearanceScreen(
            mode: mode,
            onChanged: (value) => update(() => mode = value),
            textScaleFactor: factor,
            onTextScaleChanged: (value) => update(() => factor = value),
          ),
        ),
      ),
    );
    expect(find.byType(AppearancePreview), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(mode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(AppearancePreview))).brightness,
      Brightness.dark,
    );
    final slider = find.byType(Slider);
    await tester.ensureVisible(slider);
    await tester.tapAt(tester.getCenter(slider) + const Offset(90, 0));
    await tester.pump();
    expect(factor, greaterThan(1));
    expect(
      tester
          .widget<AppearancePreview>(find.byType(AppearancePreview))
          .textScaleFactor,
      factor,
    );
  });

  testWidgets(
    'contact matching shows progress, retry and mutual fixture results',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      chats.toggleBlocked(chats.byId('amira'));
      final unmatched = chats.addContact('New Contact', '+237670123456');
      settings.failNextContactMatch();
      await tester.pumpWidget(
        MaterialApp(home: PermissionsScreen(controller: settings)),
      );
      await tester.tap(find.text('Find contacts'));
      await tester.pump();
      expect(settings.contactMatchingState, ContactMatchingState.matching);
      expect(find.text('Finding mutual contacts…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(settings.contactMatchingState, ContactMatchingState.failed);
      expect(find.text('Retry matching'), findsOneWidget);
      await tester.tap(find.text('Retry matching'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      expect(settings.contactMatchingState, ContactMatchingState.matched);
      expect(
        settings.matchedContacts.map((chat) => chat.id),
        contains('sarah'),
      );
      expect(
        settings.matchedContacts.map((chat) => chat.id),
        isNot(contains('amira')),
      );
      expect(
        settings.matchedContacts.map((chat) => chat.id),
        isNot(contains(unmatched.id)),
      );
      expect(find.text('Sarah Wilson'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets(
    'permanently denied permission has recovery and matching can be cancelled',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      settings.setPermission('Contacts', MockPermission.permanentlyDenied);
      await tester.pumpWidget(
        MaterialApp(home: PermissionsScreen(controller: settings)),
      );
      await tester.tap(find.text('Review Contacts permission'));
      await tester.pumpAndSettle();
      expect(find.text('Contacts access'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Contacts'], MockPermission.allowed);
      await tester.tap(find.text('Find contacts'));
      await tester.pump();
      await tester.tap(find.text('Cancel matching'));
      await tester.pump(const Duration(seconds: 1));
      expect(settings.contactMatchingState, ContactMatchingState.idle);
      expect(settings.matchedContacts, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets('empty matches, reset, and permission changes cancel timers', (
    tester,
  ) async {
    final chats = ChatsController();
    chats.conversations.clear();
    final settings = SettingsController(chats: chats);
    settings.startContactMatching();
    await tester.pump(const Duration(milliseconds: 800));
    expect(settings.contactMatchingState, ContactMatchingState.empty);
    settings.startContactMatching();
    settings.setPermission('Contacts', MockPermission.denied);
    await tester.pump(const Duration(seconds: 1));
    expect(settings.contactMatchingState, ContactMatchingState.denied);
    settings.setTextScaleFactor(1.3);
    settings.reset();
    expect(settings.textScaleFactor, 1);
    expect(settings.contactMatchingState, ContactMatchingState.idle);
    expect(settings.matchedContacts, isEmpty);
    settings.dispose();
    chats.dispose();
  });
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    testWidgets(
      'settings screens remain usable at $size with scaled text and keyboard inset',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chats = ChatsController();
        final settings = SettingsController(chats: chats);
        final screens = <Widget>[
          AppearanceScreen(mode: ThemeMode.system, onChanged: (_) {}),
          PermissionsScreen(controller: settings),
        ];
        for (final screen in screens) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  viewInsets: const EdgeInsets.only(bottom: 200),
                ),
                child: child!,
              ),
              home: screen,
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} should fit',
          );
          await tester.pumpWidget(const SizedBox.shrink());
        }
        settings.dispose();
        chats.dispose();
      },
    );
  }
}
