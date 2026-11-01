import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/stories/ui/widgets/story_media_background.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Status previews promoted Stories with their original context', (
    tester,
  ) async {
    final wallet = WalletController();
    final stories = StoriesController();
    final business = BusinessController(wallet: wallet, stories: stories);
    addTearDown(() {
      business.dispose();
      stories.dispose();
      wallet.dispose();
    });
    final maison = StoriesController.stories.firstWhere(
      (story) => story.id == 'maison',
    );
    String? openedProfile;
    await tester.pumpWidget(
      MaterialApp(
        home: StatusScreen(
          controller: stories,
          businessController: business,
          onBusinessProfile: (story) => openedProfile = story.id,
          onCreate: () {},
          onDiscover: () {},
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('Discover preview'), 250);
    expect(find.text('Maison Studio'), findsOneWidget);
    business.setBlocked(maison, true);
    await tester.pump();
    expect(find.text('Maison Studio'), findsNothing);
    business.setBlocked(maison, false);
    await tester.pump();
    await tester.tap(find.text('Maison Studio'));
    await tester.pumpAndSettle();
    final viewer = tester.widget<StoryViewerScreen>(
      find.byType(StoryViewerScreen),
    );
    expect(viewer.story.id, maison.id);
    expect(
      viewer.storyQueue!.every(
        (item) => item.boosted || item.sponsored || item.popular,
      ),
      isTrue,
    );
    await tester.tap(find.text('View Business'));
    expect(openedProfile, maison.id);
  });

  testWidgets('contact rename updates the Status card and an open viewer', (
    tester,
  ) async {
    final chats = ChatsController();
    final stories = StoriesController();
    addTearDown(() {
      stories.dispose();
      chats.dispose();
    });
    final sarah = chats.byId('sarah');
    await tester.pumpWidget(
      MaterialApp(
        home: StatusScreen(
          controller: stories,
          chatsController: chats,
          onCreate: () {},
          onDiscover: () {},
        ),
      ),
    );
    expect(find.text('Sarah Wilson'), findsOneWidget);
    expect(chats.updateContact(sarah, 'Sarah New', sarah.phone!), isTrue);
    await tester.pump();
    expect(find.text('Sarah New'), findsOneWidget);
    await tester.tap(find.text('Sarah New'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah New'), findsOneWidget);
    expect(chats.updateContact(sarah, 'Sarah Latest', sarah.phone!), isTrue);
    await tester.pump();
    expect(find.text('Sarah Latest'), findsOneWidget);
    await tester.tap(find.byTooltip('Story options'));
    await tester.pumpAndSettle();
    expect(find.text('Block Sarah Latest'), findsOneWidget);
  });

  testWidgets(
    'blocking an open Business Story hides media and actions until unblocked',
    (tester) async {
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(wallet: wallet, stories: stories);
      addTearDown(() {
        business.dispose();
        stories.dispose();
        wallet.dispose();
      });
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(
            controller: stories,
            story: story,
            businessController: business,
            onBusinessProfile: (_) {},
          ),
        ),
      );
      expect(find.byType(StoryMediaBackground), findsOneWidget);
      expect(find.text(story.title), findsOneWidget);
      business.setBlocked(story, true);
      await tester.pump();
      expect(find.text('This Story is unavailable.'), findsOneWidget);
      expect(find.byType(StoryMediaBackground), findsNothing);
      expect(find.text(story.title), findsNothing);
      expect(find.text('View Business'), findsNothing);
      final value = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator).first,
          )
          .value;
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator).first,
            )
            .value,
        value,
      );
      business.setBlocked(story, false);
      await tester.pump();
      expect(find.byType(StoryMediaBackground), findsOneWidget);
      expect(find.text(story.title), findsOneWidget);
      expect(find.text('View Business'), findsOneWidget);
    },
  );

  testWidgets('initially blocked contact is not seen until it can be viewed', (
    tester,
  ) async {
    final chats = ChatsController();
    final stories = StoriesController();
    addTearDown(() {
      stories.dispose();
      chats.dispose();
    });
    final contact = chats.byId('sarah');
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == contact.id,
    );
    chats.toggleBlocked(contact);
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          controller: stories,
          story: story,
          chatsController: chats,
        ),
      ),
    );
    await tester.pump();
    expect(stories.isSeen(story.id), isFalse);
    expect(find.text(story.title), findsNothing);
    chats.toggleBlocked(contact);
    await tester.pump();
    await tester.pump();
    expect(stories.isSeen(story.id), isTrue);
    expect(find.text(story.title), findsOneWidget);
  });
}
