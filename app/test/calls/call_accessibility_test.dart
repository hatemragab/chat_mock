import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    testWidgets('Business video controls fit at $size with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var balance = 25;
      final calls = CallsController(
        availableCredits: () => balance,
        spendCredits: (_, amount, _) {
          balance -= amount;
          return true;
        },
      );
      addTearDown(calls.dispose);
      final call = calls.start(
        name: 'Maison Studio',
        kind: CallKind.video,
        business: true,
      );
      calls.answer();
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: CallScreen(controller: calls, call: call),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Your Credits are running low'), findsOneWidget);
      await tester.tap(find.byTooltip('Turn camera off'));
      await tester.pump();
      expect(call.cameraEnabled, isFalse);
      expect(find.text('End call'), findsOneWidget);
      await tester.tap(find.text('End call'));
      await tester.pumpAndSettle();
      expect(find.text('Call summary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
