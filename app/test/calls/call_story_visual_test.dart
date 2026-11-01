import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_details_screen/call_details_screen.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:app/features/calls/ui/screens/call_summary_screen/call_summary_screen.dart';
import 'package:app/features/calls/ui/widgets/minimized_call_bar.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'business call keeps the Story cover through the active, minimized and history views',
    (tester) async {
      final calls = CallsController(spendCredits: (_, _, _) => true);
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      final call = calls.start(
        name: 'Private name',
        kind: CallKind.video,
        business: true,
        story: story,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CallScreen(controller: calls, call: call),
        ),
      );
      expect(find.byKey(const ValueKey('call-story-maison')), findsOneWidget);
      expect(find.text('Maison Studio'), findsOneWidget);
      expect(find.text('Private name'), findsNothing);
      calls.answer();
      await tester.pump();
      expect(find.byKey(const ValueKey('call-story-maison')), findsOneWidget);
      expect(find.text('Spaces that feel like home'), findsOneWidget);
      calls.setMinimized(true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimizedCallBar(controller: calls, onReturn: () {}),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('call-story-maison')), findsOneWidget);
      expect(find.text('Maison Studio'), findsOneWidget);
      calls.end();
      await tester.pumpWidget(
        MaterialApp(
          home: CallDetailsScreen(call: call, controller: calls),
        ),
      );
      expect(find.byKey(const ValueKey('call-story-maison')), findsOneWidget);
      expect(find.text('Spaces that feel like home'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: CallSummaryScreen(call: call, controller: calls),
        ),
      );
      expect(find.byKey(const ValueKey('call-story-maison')), findsOneWidget);
      expect(find.text('Spaces that feel like home'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      calls.dispose();
    },
  );

  testWidgets(
    'an incoming Business call displays its own Story, not another identity',
    (tester) async {
      final calls = CallsController(spendCredits: (_, _, _) => true);
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'brew',
      );
      final call = calls.start(
        name: 'Private name',
        kind: CallKind.audio,
        business: true,
        incoming: true,
        story: story,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CallScreen(controller: calls, call: call),
        ),
      );
      expect(find.byKey(const ValueKey('call-story-brew')), findsOneWidget);
      expect(find.byKey(const ValueKey('call-story-maison')), findsNothing);
      expect(find.text('Daily Brew'), findsOneWidget);
      expect(find.text('Private name'), findsNothing);
      calls.finishRinging(CallPhase.declined);
      await tester.pumpWidget(const SizedBox.shrink());
      calls.dispose();
    },
  );
}
