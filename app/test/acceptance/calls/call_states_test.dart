import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final outcome in [
    CallPhase.busy,
    CallPhase.declined,
    CallPhase.missed,
  ]) {
    testWidgets('outgoing business ${outcome.name} has no charge', (
      tester,
    ) async {
      var charges = 0;
      final controller = CallsController(
        spendCredits: (_, _, _) {
          charges++;
          return true;
        },
      );
      addTearDown(controller.dispose);
      final call = controller.start(
        name: 'Maison Studio',
        kind: CallKind.audio,
        business: true,
        storyId: 'maison',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CallScreen(controller: controller, call: call),
        ),
      );
      expect(find.text('Ringing…'), findsOneWidget);
      expect(find.text('BUSINESS CALL'), findsOneWidget);
      await tester.tap(find.byTooltip('Simulate call outcome'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(switch (outcome) {
          CallPhase.busy => 'Busy',
          CallPhase.declined => 'Declined',
          _ => 'Unanswered',
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('Call summary'), findsOneWidget);
      expect(find.text(outcome.name), findsOneWidget);
      expect(find.text('0 Credits'), findsOneWidget);
      expect(charges, 0);
      expect(controller.history.single, same(call));
    });
  }

  for (final business in [false, true]) {
    testWidgets(
      'incoming ${business ? 'business' : 'personal'} call can be answered without recipient charge',
      (tester) async {
        var charges = 0;
        final controller = CallsController(
          spendCredits: (_, _, _) {
            charges++;
            return true;
          },
        );
        addTearDown(controller.dispose);
        final call = controller.start(
          name: 'A caller',
          kind: CallKind.audio,
          business: business,
          incoming: true,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: CallScreen(controller: controller, call: call),
          ),
        );
        expect(find.text('Incoming audio call'), findsOneWidget);
        expect(find.text('Answer'), findsOneWidget);
        if (business) {
          expect(find.text('No charge to recipient'), findsOneWidget);
        }
        await tester.tap(find.text('Answer'));
        await tester.pump();
        expect(call.phase, CallPhase.active);
        controller.setReconnecting(true);
        await tester.pump();
        expect(find.textContaining('Reconnecting…'), findsOneWidget);
        controller.setReconnecting(false);
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);
        await tester.tap(find.text('End call'));
        await tester.pumpAndSettle();
        expect(find.text('Call summary'), findsOneWidget);
        expect(charges, 0);
        expect(controller.history.single, same(call));
      },
    );
  }
}
