import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('viewer marks the correct story seen, pauses and advances', (
    tester,
  ) async {
    final controller = StoriesController();
    final sarah = StoriesController.stories.firstWhere(
      (story) => story.id == 'sarah',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: controller, story: sarah),
      ),
    );
    expect(controller.isSeen('sarah'), isTrue);
    expect(controller.isSeen('amira'), isFalse);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Sarah Wilson'), findsOneWidget);
    await tester.tap(find.byTooltip('Next Story'));
    await tester.pump();
    expect(find.text('Amira Hassan'), findsOneWidget);
    expect(controller.isSeen('amira'), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('unavailable and failed media states are actionable', (
    tester,
  ) async {
    final controller = StoriesController();
    final story = StoriesController.stories.firstWhere(
      (story) => story.id == 'sarah',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: controller, story: story),
      ),
    );
    controller.setMediaFailed(story.id, true);
    await tester.pump();
    expect(find.text('Story media could not be loaded.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(controller.mediaFailed(story.id), isFalse);
    controller.setAvailability(story.id, StoryAvailability.removed);
    await tester.pump();
    expect(find.text('This Story has been removed.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
  testWidgets('review opens a real paused and muted video state', (
    tester,
  ) async {
    final controller = StoriesController();
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'amira',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          controller: controller,
          story: story,
          initiallyPaused: true,
          initiallyMuted: true,
        ),
      ),
    );
    expect(find.text('Paused'), findsOneWidget);
    expect(find.byTooltip('Unmute'), findsOneWidget);
    await tester.tap(find.byTooltip('Unmute'));
    await tester.pump();
    expect(find.byTooltip('Mute'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
