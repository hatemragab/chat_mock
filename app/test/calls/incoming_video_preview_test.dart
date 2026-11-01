import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final business in [false, true]) {
    testWidgets(
      'incoming ${business ? 'Business' : 'personal'} video shows self preview before answering',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var charges = 0;
        final calls = CallsController(
          spendCredits: (_, _, _) {
            charges++;
            return true;
          },
        );
        addTearDown(calls.dispose);
        final story = business ? StoriesController.stories.first : null;
        final call = calls.start(
          name: story?.author ?? 'Sarah Wilson',
          kind: CallKind.video,
          business: business,
          incoming: true,
          story: story,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.create(Brightness.dark),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
              ),
              child: child!,
            ),
            home: CallScreen(controller: calls, call: call),
          ),
        );
        expect(find.text('Camera preview'), findsOneWidget);
        expect(find.text('${call.name} · remote preview'), findsNothing);
        expect(find.text('You · front'), findsOneWidget);
        if (story != null) {
          expect(
            find.byKey(ValueKey('call-story-${story.id}')),
            findsOneWidget,
          );
        }
        expect(charges, 0);
        await tester.tap(find.text('Answer'));
        await tester.pump();
        expect(call.phase, CallPhase.active);
        expect(find.text('${call.name} · remote preview'), findsOneWidget);
        expect(find.text('Camera preview'), findsNothing);
        expect(charges, 0);
        await tester.tap(find.text('End call'));
        await tester.pumpAndSettle();
        expect(calls.active, isNull);
        expect(charges, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
