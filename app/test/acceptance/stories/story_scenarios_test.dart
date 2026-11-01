import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long press preserves an already paused Story', (tester) async {
    final stories = StoriesController();
    final story = StoriesController.stories.firstWhere((s) => s.id == 'sarah');
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: stories, story: story),
      ),
    );
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    final gesture = await tester.startGesture(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });

  testWidgets('next and previous skip Stories that expire during viewing', (
    tester,
  ) async {
    final stories = StoriesController();
    final maison = StoriesController.stories.firstWhere(
      (s) => s.id == 'maison',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: stories, story: maison),
      ),
    );
    stories.setAvailability('brew', StoryAvailability.expired);
    await tester.pump();
    await tester.tap(find.byTooltip('Next Story'));
    await tester.pump();
    expect(find.text('Made Local'), findsOneWidget);
    expect(stories.isSeen('brew'), isFalse);
    await tester.tap(find.byTooltip('Previous Story'));
    await tester.pump();
    expect(find.text('Maison Studio'), findsOneWidget);
    expect(stories.isSeen('brew'), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });

  testWidgets('navigation skips a contact Story removed while viewing', (
    tester,
  ) async {
    final stories = StoriesController();
    final sarah = StoriesController.stories.firstWhere((s) => s.id == 'sarah');
    final amira = StoriesController.stories.firstWhere((s) => s.id == 'amira');
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: stories, story: sarah),
      ),
    );
    stories.setAvailability(amira.id, StoryAvailability.removed);
    await tester.pump();
    await tester.tap(find.byTooltip('Next Story'));
    await tester.pump();
    expect(find.text('Amira Hassan'), findsNothing);
    expect(stories.isSeen(amira.id), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });

  testWidgets('empty contact Status explains the state and permits exploring', (
    tester,
  ) async {
    final stories = StoriesController();
    for (final story in StoriesController.stories.where(
      (story) => story.kind == StoryKind.contact,
    )) {
      stories.setAvailability(story.id, StoryAvailability.removed);
    }
    var exploreCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatusScreen(
          controller: stories,
          onCreate: () {},
          onDiscover: () => exploreCount++,
        ),
      ),
    );
    expect(
      find.text('No updates yet. Your contacts’ stories will appear here.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Explore Discover'));
    expect(exploreCount, 1);
    stories.setAvailability('sarah', StoryAvailability.active);
    await tester.pump();
    expect(find.text('Sarah Wilson'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });

  testWidgets('Business photo can open the matching Business profile', (
    tester,
  ) async {
    final stories = StoriesController();
    final story = StoriesController.stories.firstWhere((s) => s.id == 'maison');
    Story? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          controller: stories,
          story: story,
          onBusinessProfile: (value) => selected = value,
        ),
      ),
    );
    expect(find.text(story.title), findsOneWidget);
    expect(find.byTooltip('Mute'), findsNothing);
    await tester.tap(find.text('View Business'));
    await tester.pump();
    expect(selected?.id, story.id);
    expect(find.text('Paused'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });

  testWidgets('audio Story has simulated playback and mute controls', (
    tester,
  ) async {
    final stories = StoriesController();
    const audio = Story(
      id: 'audio',
      author: 'Alex Morgan',
      title: 'Voice update',
      category: 'Friends',
      kind: StoryKind.own,
      media: StoryMedia.audio,
      colors: [Colors.blue, Colors.black],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(controller: stories, story: audio),
      ),
    );
    expect(find.text('Audio preview'), findsOneWidget);
    await tester.tap(find.byTooltip('Mute'));
    await tester.pump();
    expect(find.byTooltip('Unmute'), findsOneWidget);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
  });
}
