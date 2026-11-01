import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Business Story report retains its originating identity and blocking requires confirmation',
    (tester) async {
      final stories = StoriesController();
      final wallet = WalletController();
      final business = BusinessController(wallet: wallet, stories: stories);
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
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      expect(find.text('View Business profile'), findsOneWidget);
      await tester.tap(find.text('Report Story'));
      await tester.pumpAndSettle();
      expect(
        find.text('Report Maison Studio · Spaces that feel like home'),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block Maison Studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(business.isBlocked(story), isFalse);
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block Maison Studio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();
      expect(business.isBlocked(story), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );

  testWidgets('contact Story block and unblock updates the existing chat', (
    tester,
  ) async {
    final stories = StoriesController();
    final chats = ChatsController();
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'sarah',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          controller: stories,
          story: story,
          chatsController: chats,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Story options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block Sarah Wilson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(chats.byId('sarah').blocked, isTrue);
    await tester.tap(find.byTooltip('Story options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unblock Sarah Wilson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();
    expect(chats.byId('sarah').blocked, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
    chats.dispose();
  });

  testWidgets(
    'own publication options retain the selected publication and honor delete cancellation',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status)
        ..caption = 'My special update';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      final stories = StoriesController(publishing: publishing);
      final story = stories.allStories.firstWhere(
        (item) => item.id == publication.id,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(controller: stories, story: story),
        ),
      );
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Story viewers'));
      await tester.pumpAndSettle();
      expect(find.text('No contact views yet.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.active);
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.removed);
      expect(find.text('This Story has been removed.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    },
  );
  testWidgets(
    'blocked contacts disappear from Status and return after unblocking',
    (tester) async {
      final stories = StoriesController();
      final chats = ChatsController();
      await tester.pumpWidget(
        MaterialApp(
          home: StatusScreen(
            controller: stories,
            chatsController: chats,
            onDiscover: () {},
            onCreate: () {},
          ),
        ),
      );
      expect(find.text('Sarah Wilson'), findsOneWidget);
      chats.toggleBlocked(chats.byId('sarah'));
      await tester.pump();
      expect(find.text('Sarah Wilson'), findsNothing);
      chats.toggleBlocked(chats.byId('sarah'));
      await tester.pump();
      expect(find.text('Sarah Wilson'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
      chats.dispose();
    },
  );

  testWidgets(
    'a promoted own Story exposes aggregate analytics rather than viewer identities',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..caption = 'Promoted';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      publishing.recordView(
        publication,
        viewerId: 'someone',
        viewerName: 'Private Viewer',
      );
      final stories = StoriesController(publishing: publishing);
      final story = stories.allStories.firstWhere(
        (item) => item.id == publication.id,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: StoryViewerScreen(controller: stories, story: story),
        ),
      );
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      expect(find.text('Promotion analytics'), findsOneWidget);
      expect(find.text('Story viewers'), findsNothing);
      await tester.tap(find.text('Promotion analytics'));
      await tester.pumpAndSettle();
      expect(find.text('Aggregate insights'), findsOneWidget);
      expect(find.text('Private Viewer'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    },
  );
}
