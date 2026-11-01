import 'package:app/features/discover/ui/screens/discover_screen/discover_screen.dart';
import 'package:app/features/discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'search retains category and explains when there are no matches',
    (tester) async {
      final stories = StoriesController();
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoverSearchScreen(
            controller: stories,
            initialCategory: 'Design',
          ),
        ),
      );
      expect(find.text('Maison Studio'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'does not exist');
      await tester.pump();
      expect(
        find.text('No stories match your search. Try another category.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'Maison');
      await tester.pump();
      expect(find.text('Maison Studio'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
    },
  );

  testWidgets(
    'Discover shows empty state when promoted stories become unavailable',
    (tester) async {
      final stories = StoriesController();
      for (final story in StoriesController.stories.where(
        (item) => item.kind == StoryKind.business,
      )) {
        stories.setAvailability(story.id, StoryAvailability.expired);
      }
      await tester.pumpWidget(
        MaterialApp(home: DiscoverScreen(controller: stories)),
      );
      expect(
        find.text('No promoted Stories are available right now.'),
        findsOneWidget,
      );
      stories.setAvailability('maison', StoryAvailability.active);
      await tester.pump();
      expect(
        find.text('No promoted Stories are available right now.'),
        findsNothing,
      );
      expect(find.text('Maison Studio'), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
    },
  );
  testWidgets('category fee alone does not promote a Status', (tester) async {
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final stories = StoriesController(publishing: publishing);
    final draft = publishing.createDraft(PublicationType.status)
      ..paidCategory = true
      ..caption = 'Unboosted private status';
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    await tester.pumpWidget(
      MaterialApp(home: DiscoverSearchScreen(controller: stories)),
    );
    await tester.enterText(find.byType(TextField), 'Unboosted private status');
    await tester.pump();
    expect(
      find.text('No stories match your search. Try another category.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
    publishing.dispose();
    wallet.dispose();
  });
}
