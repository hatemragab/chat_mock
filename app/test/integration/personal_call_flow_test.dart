import 'package:app/app/app.dart';
import 'package:app/app/ui/screens/home_shell/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('call history uses contact identity and reacts to blocking', (
    tester,
  ) async {
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pumpAndSettle();
    final shell = tester.widget<HomeShell>(find.byType(HomeShell));
    final sarah = shell.chats.byId('sarah');
    shell.chats.updateContact(sarah, 'Sarah Renamed', sarah.phone!);
    await tester.tap(find.text('Calls').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Wilson'));
    await tester.pumpAndSettle();
    final callAgain = find.widgetWithText(FilledButton, 'Call again');
    expect(tester.widget<FilledButton>(callAgain).onPressed, isNotNull);
    shell.chats.toggleBlocked(sarah);
    await tester.pump();
    expect(tester.widget<FilledButton>(callAgain).onPressed, isNull);
    shell.chats.toggleBlocked(sarah);
    await tester.pump();
    expect(tester.widget<FilledButton>(callAgain).onPressed, isNotNull);
    await tester.tap(callAgain);
    await tester.pumpAndSettle();
    expect(find.text('Sarah Renamed'), findsOneWidget);
    expect(shell.calls.active?.contactId, 'sarah');
  });

  testWidgets(
    'unmatched contact cannot start a call through the app callback',
    (tester) async {
      await tester.pumpWidget(const WhizpeeApp());
      await tester.pumpAndSettle();
      final shell = tester.widget<HomeShell>(find.byType(HomeShell));
      final contact = shell.chats.addContact('Unmatched', '+237600123456');
      shell.chats.onStartCall!(contact, false);
      await tester.pump();
      expect(shell.calls.active, isNull);
      expect(find.textContaining('mutual contact match'), findsOneWidget);
    },
  );

  testWidgets('a direct conversation starts and ends a personal audio call', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chats').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Wilson').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Audio call'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Wilson'), findsWidgets);
    expect(find.textContaining('Credits'), findsNothing);
    expect(find.text('Ringing…'), findsOneWidget);
    await tester.tap(find.text('Simulate answer'));
    await tester.pump();
    await tester.tap(find.text('End call'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Credits'), findsNothing);
  });
}
