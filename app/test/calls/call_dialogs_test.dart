import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_details_screen/call_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'delete call confirmation names its target and cancel preserves history',
    (tester) async {
      final calls = CallsController(spendCredits: (_, _, _) => true);
      addTearDown(calls.dispose);
      final call = calls.start(name: 'Sarah Wilson', kind: CallKind.audio);
      calls.finishRinging(CallPhase.missed);
      await tester.pumpWidget(
        MaterialApp(
          home: CallDetailsScreen(call: call, controller: calls),
        ),
      );
      await tester.tap(find.byTooltip('Delete call'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sarah Wilson'), findsWidgets);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls.history, contains(call));
    },
  );
}
