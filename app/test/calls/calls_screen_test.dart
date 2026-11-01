import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/calls_screen/calls_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'selects a contact and video call, then records a busy outcome without charging',
    (tester) async {
      var spent = 0;
      final calls = CallsController(
        spendCredits: (_, amount, _) {
          spent += amount;
          return true;
        },
      );
      final chats = ChatsController();
      addTearDown(calls.dispose);
      addTearDown(chats.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: CallsScreen(controller: calls, chats: chats),
        ),
      );
      await tester.tap(find.text('Start a call'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Video call'));
      await tester.pumpAndSettle();
      expect(calls.active?.kind, CallKind.video);
      await tester.tap(find.byTooltip('Simulate call outcome'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Busy'));
      await tester.pumpAndSettle();
      expect(calls.active, isNull);
      expect(calls.history.single.phase, CallPhase.busy);
      expect(spent, 0);
      expect(find.text('Call summary'), findsOneWidget);
    },
  );

  testWidgets('call controls and warning remain accessible on a short phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var credits = 25;
    final calls = CallsController(
      spendCredits: (_, amount, _) {
        if (credits < amount) return false;
        credits -= amount;
        return true;
      },
      availableCredits: () => credits,
    );
    addTearDown(calls.dispose);
    final call = calls.start(
      name: 'Maison Studio',
      kind: CallKind.video,
      business: true,
      storyId: 'maison',
    );
    await tester.pumpWidget(MaterialApp(home: CallsScreen(controller: calls)));
    await tester.tap(find.text('Ongoing call with Maison Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate answer'));
    await tester.pump();
    expect(find.text('Your Credits are running low'), findsOneWidget);
    expect(find.byTooltip('Switch camera'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch camera'));
    await tester.pump();
    expect(call.frontCamera, isFalse);
    expect(tester.takeException(), isNull);
    calls.end();
    await tester.pump();
  });
}
