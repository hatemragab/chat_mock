import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/widgets/minimized_call_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final incoming in [false, true]) {
    testWidgets(
      'ending minimized ${incoming ? 'incoming' : 'outgoing'} ringing records the right outcome',
      (tester) async {
        var charges = 0;
        final calls = CallsController(
          spendCredits: (_, _, _) {
            charges++;
            return true;
          },
        );
        addTearDown(calls.dispose);
        final call = calls.start(
          name: 'Maison',
          kind: CallKind.video,
          business: true,
          incoming: incoming,
        );
        calls.setMinimized(true);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MinimizedCallBar(controller: calls, onReturn: () {}),
            ),
          ),
        );
        expect(
          find.textContaining(incoming ? 'Incoming video call' : 'Ringing…'),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip('End call'));
        await tester.pump();
        expect(calls.active, isNull);
        expect(calls.history.single, same(call));
        expect(call.phase, incoming ? CallPhase.declined : CallPhase.cancelled);
        expect(call.totalCost, 0);
        expect(charges, 0);
      },
    );
  }
}
