import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/ui/screens/appearance_screen/appearance_screen.dart';
import 'package:app/features/settings/ui/screens/blocked_accounts_screen/blocked_accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('system theme follows platform brightness after selection', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    var mode = ThemeMode.light;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, update) => MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: AppearanceScreen(
            mode: mode,
            onChanged: (value) => update(() => mode = value),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('System'));
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(mode, ThemeMode.system);
    expect(
      Theme.of(tester.element(find.text('Choose your theme'))).brightness,
      Brightness.dark,
    );
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Choose your theme'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('empty blocked list shows an appropriate search state', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    addTearDown(() {
      settings.dispose();
      chats.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(home: BlockedAccountsScreen(controller: settings)),
    );
    expect(find.text('No blocked accounts.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Someone');
    await tester.pump();
    expect(find.text('No blocked accounts match your search.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.text('No blocked accounts.'), findsOneWidget);
  });
}
