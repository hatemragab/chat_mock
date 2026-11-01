import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'long Story caption stays usable at $size, ${brightness.name}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final stories = StoriesController();
          final story = Story(
            id: 'long-caption',
            author: 'Maison Studio with a long public Business name',
            title: List.filled(
              12,
              'A meaningful long caption with Unicode ✨',
            ).join(' '),
            category: 'Design',
            kind: StoryKind.business,
            media: StoryMedia.video,
            colors: const [Colors.teal, Colors.black],
          );
          var openedProfile = false;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.create(brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
                ),
                child: child!,
              ),
              home: StoryViewerScreen(
                controller: stories,
                story: story,
                storyQueue: [story],
                initiallyPaused: true,
                onBusinessProfile: (_) => openedProfile = true,
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -300),
          );
          await tester.pump();
          final scrollable = tester.state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          expect(scrollable.position.pixels, greaterThan(0));
          await tester.tap(find.byTooltip('Mute'));
          await tester.pump();
          expect(find.byTooltip('Unmute'), findsOneWidget);
          stories.setMediaFailed(story.id, true);
          await tester.pump();
          final retry = tester.widget<TextButton>(
            find.widgetWithText(TextButton, 'Retry'),
          );
          expect(retry.style!.foregroundColor!.resolve({}), Colors.white);
          await tester.tap(find.text('Retry'));
          await tester.pump();
          expect(stories.mediaFailed(story.id), isFalse);
          await tester.tap(find.text('View Business'));
          expect(openedProfile, isTrue);
          expect(
            tester.getBottomRight(find.text('View Business')).dy,
            lessThanOrEqualTo(size.height - 16),
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          stories.dispose();
        },
      );
    }
  }
}
