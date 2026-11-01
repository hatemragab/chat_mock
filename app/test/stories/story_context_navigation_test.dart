import 'package:app/features/discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search viewer keeps navigation within the filtered results', (
    tester,
  ) async {
    final stories = StoriesController();
    addTearDown(stories.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DiscoverSearchScreen(controller: stories)),
    );
    await tester.enterText(find.byType(TextField), 'Maison');
    await tester.pump();
    await tester.tap(find.text('Maison Studio'));
    await tester.pumpAndSettle();
    expect(find.byType(StoryViewerScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Next Story'));
    await tester.pumpAndSettle();
    expect(find.byType(DiscoverSearchScreen), findsOneWidget);
    expect(find.text('Maison Studio'), findsOneWidget);
    expect(find.text('Daily Brew'), findsNothing);
  });

  testWidgets('own Status navigation does not include advertisements', (
    tester,
  ) async {
    final wallet = WalletController();
    final publishing = PublishingController(
      wallet: wallet,
      seedPublications: true,
    );
    final stories = StoriesController(publishing: publishing);
    addTearDown(() {
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    });
    final ad = publishing.createDraft(PublicationType.advertisement)
      ..caption = 'Private ad context';
    expect(
      publishing.publish(ad, publishing.review(ad)),
      PublishResult.success,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StatusScreen(
          controller: stories,
          onDiscover: () {},
          onCreate: () {},
        ),
      ),
    );
    final first = publishing.publications.firstWhere(
      (item) => item.type == PublicationType.status,
    );
    await tester.tap(find.text(first.caption));
    await tester.pumpAndSettle();
    final viewer = tester.widget<StoryViewerScreen>(
      find.byType(StoryViewerScreen),
    );
    expect(viewer.storyQueue!.map((story) => story.id), isNot(contains(ad.id)));
    await tester.tap(find.byTooltip('Next Story'));
    await tester.pump();
    expect(find.text('Private ad context'), findsNothing);
  });

  test(
    'only promoted publications become Popular at the qualified threshold',
    () {
      final wallet = WalletController();
      final publishing = PublishingController(
        wallet: wallet,
        config: const PublishingConfig(popularThreshold: 2),
      );
      final stories = StoriesController(publishing: publishing);
      addTearDown(() {
        stories.dispose();
        publishing.dispose();
        wallet.dispose();
      });
      final promoted = publishing.createDraft(PublicationType.status)
        ..boosted = true;
      final ordinary = publishing.createDraft(PublicationType.status);
      expect(
        publishing.publish(promoted, publishing.review(promoted)),
        PublishResult.success,
      );
      expect(
        publishing.publish(ordinary, publishing.review(ordinary)),
        PublishResult.success,
      );
      final promotedItem = publishing.publications.firstWhere(
        (item) => item.id == promoted.id,
      );
      final ordinaryItem = publishing.publications.firstWhere(
        (item) => item.id == ordinary.id,
      );
      for (final item in [promotedItem, ordinaryItem]) {
        publishing.recordView(item, viewerId: 'one', viewerName: 'One');
        publishing.recordView(item, viewerId: 'two', viewerName: 'Two');
      }
      expect(
        stories.allStories
            .firstWhere((story) => story.id == promoted.id)
            .popular,
        isTrue,
      );
      expect(
        stories.allStories
            .firstWhere((story) => story.id == ordinary.id)
            .popular,
        isFalse,
      );
    },
  );
}
