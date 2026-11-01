import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:app/features/calls/ui/screens/calls_screen/calls_screen.dart';
import 'package:app/features/calls/ui/widgets/minimized_call_bar.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      Future<void> mount(WidgetTester tester, Widget home) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.create(brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
              ),
              child: child!,
            ),
            home: home,
          ),
        );
      }

      testWidgets(
        'ringing Business outcome stays reachable at $size in $brightness',
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
            name: 'Maison Studio',
            kind: CallKind.video,
            business: true,
            story: StoriesController.stories.first,
          );
          await mount(tester, CallScreen(controller: calls, call: call));
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Simulate call outcome'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Busy'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('0 Credits'), 180);
          expect(call.phase, CallPhase.busy);
          expect(charges, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'minimized call return and end stay reachable at $size in $brightness',
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
            name: 'Maison Studio',
            kind: CallKind.audio,
            business: true,
            story: StoriesController.stories.first,
          );
          calls.answer();
          calls.setMinimized(true);
          var returned = false;
          await mount(
            tester,
            Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: MinimizedCallBar(
                  controller: calls,
                  onReturn: () {
                    returned = true;
                    calls.setMinimized(false);
                  },
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Maison Studio'));
          await tester.pump();
          expect(returned, isTrue);
          expect(call.minimized, isFalse);
          calls.setMinimized(true);
          calls.setReconnecting(true);
          await tester.pump();
          expect(find.textContaining('Reconnecting…'), findsOneWidget);
          await tester.tap(find.byTooltip('End call'));
          await tester.pump();
          expect(calls.active, isNull);
          expect(charges, 1);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'active Business video controls and balance warning are usable at $size in $brightness',
        (tester) async {
          var credits = 25;
          final calls = CallsController(
            availableCredits: () => credits,
            spendCredits: (_, amount, _) {
              credits -= amount;
              return true;
            },
          );
          addTearDown(calls.dispose);
          final call = calls.start(
            name: 'Maison Studio',
            kind: CallKind.video,
            business: true,
            story: StoriesController.stories.first,
          );
          calls.answer();
          await mount(tester, CallScreen(controller: calls, call: call));
          expect(tester.takeException(), isNull);
          final warning = tester.widget<ListTile>(
            find.widgetWithText(ListTile, 'Your Credits are running low'),
          );
          final scheme = Theme.of(
            tester.element(find.text('Your Credits are running low')),
          ).colorScheme;
          expect(warning.textColor, scheme.onTertiaryContainer);
          final light = scheme.tertiaryContainer.computeLuminance();
          final dark = scheme.onTertiaryContainer.computeLuminance();
          final ratio = light > dark
              ? (light + .05) / (dark + .05)
              : (dark + .05) / (light + .05);
          expect(ratio, greaterThanOrEqualTo(4.5));
          await tester.tap(find.byTooltip('Low balance details'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Mute'));
          await tester.pump();
          expect(call.muted, isTrue);
          await tester.tap(find.byTooltip('Audio output'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text('Bluetooth device'));
          await tester.tap(find.text('Bluetooth device'));
          await tester.pumpAndSettle();
          expect(call.output, CallOutput.bluetooth);
          await tester.tap(find.byTooltip('Turn camera off'));
          await tester.pump();
          expect(call.cameraEnabled, isFalse);
          await tester.tap(find.byTooltip('Switch camera'));
          await tester.pump();
          expect(call.frontCamera, isFalse);
          calls.setReconnecting(true);
          await tester.pump();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('End call'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('25 Credits'), 200);
          expect(call.totalCost, 25);
          expect(calls.history.single, same(call));
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'incoming Business answer and summary remain usable at $size in $brightness',
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
            name: 'Maison Studio',
            kind: CallKind.audio,
            business: true,
            incoming: true,
            story: StoriesController.stories.first,
          );
          await mount(tester, CallScreen(controller: calls, call: call));
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Answer'));
          await tester.pump();
          expect(call.phase, CallPhase.active);
          await tester.tap(find.text('End call'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('0 Credits'), 180);
          expect(charges, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'Business history details and deletion remain usable at $size in $brightness',
        (tester) async {
          final calls = CallsController(
            spendCredits: (_, _, _) => true,
            seedHistory: true,
          );
          addTearDown(calls.dispose);
          await mount(tester, CallsScreen(controller: calls));
          await tester.tap(find.text('Business'));
          await tester.pump();
          expect(find.text('Sarah Wilson'), findsNothing);
          await tester.tap(find.text('Maison Studio'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.textContaining('Return to the originating Story'),
            160,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('15 Credits'), findsOneWidget);
          await tester.tap(find.byTooltip('Delete call'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          expect(calls.history, hasLength(3));
          await tester.tap(find.byTooltip('Delete call'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();
          expect(calls.history, hasLength(2));
          expect(find.text('No calls in this view yet.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
