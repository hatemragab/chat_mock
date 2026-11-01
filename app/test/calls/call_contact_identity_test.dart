import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_details_screen/call_details_screen.dart';
import 'package:app/features/calls/ui/screens/call_summary_screen/call_summary_screen.dart';
import 'package:app/features/calls/ui/screens/calls_screen/calls_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CallsController callsFor(ChatsController chats, {bool seedHistory = false}) =>
    CallsController(
      spendCredits: (_, _, _) => true,
      seedHistory: seedHistory,
      contactChanges: chats,
      contactName: (call) {
        final matches = chats.conversations.where(
          (chat) =>
              chat.kind == ChatKind.contact &&
              (call.contactId == null
                  ? chat.name == call.name
                  : chat.id == call.contactId),
        );
        return matches.length == 1 ? matches.single.name : null;
      },
      canRecallContact: (call) {
        final matches = chats.conversations.where(
          (chat) =>
              chat.kind == ChatKind.contact &&
              (call.contactId == null
                  ? chat.name == call.name
                  : chat.id == call.contactId),
        );
        return matches.length == 1 &&
            chats.canCommunicateWithContact(matches.single);
      },
    );

void main() {
  testWidgets(
    'history opens the same contact after a rename and duplicate name',
    (tester) async {
      final chats = ChatsController();
      final calls = callsFor(chats, seedHistory: true);
      addTearDown(() {
        calls.dispose();
        chats.dispose();
      });
      final sarah = chats.byId('sarah');
      expect(chats.updateContact(sarah, 'Sarah Renamed', sarah.phone!), isTrue);
      chats.addContact('Sarah Wilson', '+12025550190');
      await tester.pumpWidget(
        MaterialApp(
          home: CallsScreen(controller: calls, chats: chats),
        ),
      );
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(find.text('Sarah Renamed'), findsWidgets);
    },
  );

  for (final summary in [false, true]) {
    testWidgets(
      '${summary ? 'summary' : 'details'} blocks redial immediately after a contact is blocked',
      (tester) async {
        final chats = ChatsController();
        final calls = callsFor(chats);
        addTearDown(() {
          calls.dispose();
          chats.dispose();
        });
        final sarah = chats.byId('sarah');
        final call = calls.start(
          name: sarah.name,
          contactId: sarah.id,
          kind: CallKind.audio,
        );
        calls.finishRinging(CallPhase.missed);
        await tester.pumpWidget(
          MaterialApp(
            home: summary
                ? CallSummaryScreen(controller: calls, call: call)
                : CallDetailsScreen(controller: calls, call: call),
          ),
        );
        final button = find.widgetWithText(FilledButton, 'Call again');
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
        chats.toggleBlocked(sarah);
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        chats.toggleBlocked(sarah);
        expect(
          chats.updateContact(sarah, 'Sarah Renamed', sarah.phone!),
          isTrue,
        );
        await tester.pump();
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(calls.active?.contactId, sarah.id);
        expect(calls.active?.name, 'Sarah Renamed');
        expect(calls.active?.phase, CallPhase.ringing);
        expect(call.name, 'Sarah Wilson');
      },
    );
  }

  testWidgets('picker rechecks contact eligibility before placing a call', (
    tester,
  ) async {
    final chats = ChatsController();
    final calls = callsFor(chats);
    addTearDown(() {
      calls.dispose();
      chats.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: CallsScreen(controller: calls, chats: chats),
      ),
    );
    await tester.tap(find.text('Start a call'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Wilson'));
    await tester.pumpAndSettle();
    chats.toggleBlocked(chats.byId('sarah'));
    await tester.tap(find.text('Audio call'));
    await tester.pumpAndSettle();
    expect(calls.active, isNull);
    expect(find.textContaining('unblocked contact match'), findsOneWidget);
  });
}
