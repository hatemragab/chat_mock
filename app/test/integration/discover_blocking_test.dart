import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/discover/ui/screens/discover_screen/discover_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'blocking a Business removes its Stories from Discover and unblocking restores them',
    (tester) async {
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(wallet: wallet, stories: stories);
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoverScreen(
            controller: stories,
            businessController: business,
          ),
        ),
      );
      expect(find.text(story.title), findsWidgets);
      business.setBlocked(story, true);
      await tester.pump();
      expect(find.text(story.title), findsNothing);
      business.setBlocked(story, false);
      await tester.pump();
      expect(find.text(story.title), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );
  testWidgets(
    'Story navigation skips a Business blocked after the viewer opens',
    (tester) async {
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(wallet: wallet, stories: stories);
      final first = StoriesController.stories.firstWhere(
        (story) => story.id == 'maison',
      );
      final blocked = StoriesController.stories.firstWhere(
        (story) => story.id == 'brew',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(
            controller: stories,
            story: first,
            businessController: business,
          ),
        ),
      );
      business.setBlocked(blocked, true);
      await tester.pump();
      await tester.tap(find.byTooltip('Next Story'));
      await tester.pump();
      expect(find.text('Made Local'), findsOneWidget);
      expect(find.text('Daily Brew'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );
}
