import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/discover/controllers/discover_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/models/review_entry.dart';
import 'package:app/features/prototype_tools/ui/screens/review_catalog_screen/review_catalog_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('viewer scenarios are offered only for matching publication state', () {
    final wallet = WalletController();
    final chats = ChatsController();
    final calls = CallsController(spendCredits: (_, _, _) => true);
    final group = GroupController(chats: chats);
    final business = BusinessController(wallet: wallet);
    final publishing = PublishingController(wallet: wallet);
    final stories = StoriesController();
    addTearDown(() {
      calls.dispose();
      group.dispose();
      business.dispose();
      publishing.dispose();
      stories.dispose();
      chats.dispose();
      wallet.dispose();
    });
    final actions = ReviewActions(
      chats: chats,
      calls: calls,
      group: group,
      business: business,
      publishing: publishing,
      stories: stories,
      wallet: wallet,
    );
    expect(actions.canOpen('V091'), isFalse);
    final draft = publishing.createDraft(PublicationType.status);
    publishing.publish(draft, publishing.review(draft));
    final publication = publishing.publications.single;
    expect(actions.canOpen('V091'), isTrue);
    expect(actions.canOpen('V092'), isFalse);
    publishing.recordView(publication, viewerId: 'sarah', viewerName: 'Sarah');
    expect(actions.canOpen('V091'), isFalse);
    expect(actions.canOpen('V092'), isTrue);
    final ad = publishing.createDraft(PublicationType.advertisement);
    publishing.publish(ad, publishing.review(ad));
    final promoted = publishing.publications.first;
    expect(actions.canOpen('V093'), isTrue);
    expect(actions.canOpen('V094'), isFalse);
    publishing.recordView(
      promoted,
      viewerId: 'held',
      viewerName: 'Held',
      suspicious: true,
    );
    expect(actions.canOpen('V095'), isTrue);
  });

  test(
    'catalog retains each requested product surface and scenario ID once',
    () {
      expect(reviewEntries.length, 254);
      final ids = reviewEntries.map((entry) => entry.id).toSet();
      expect(ids.length, 254);
      expect(ids.where((id) => id.startsWith('P')).length, 80);
      expect(ids.where((id) => id.startsWith('S')).length, 21);
      expect(ids.where((id) => id.startsWith('D')).length, 23);
      expect(ids.where((id) => id.startsWith('V')).length, 130);
    },
  );

  testWidgets(
    'offline scenario opens the conversation with a real queued message',
    (tester) async {
      final wallet = WalletController();
      final chats = ChatsController();
      final calls = CallsController(
        spendCredits: (id, amount, description) => wallet.spendCredits(
          id: id,
          amount: amount,
          description: description,
        ),
      );
      final group = GroupController(chats: chats);
      final business = BusinessController(wallet: wallet);
      final publishing = PublishingController(wallet: wallet);
      final stories = StoriesController();
      addTearDown(() {
        calls.dispose();
        group.dispose();
        business.dispose();
        publishing.dispose();
        stories.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final actions = ReviewActions(
        chats: chats,
        calls: calls,
        group: group,
        business: business,
        publishing: publishing,
        stories: stories,
        wallet: wallet,
      );
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: actions)),
      );
      await tester.enterText(find.byType(TextField), 'V018');
      await tester.pumpAndSettle();
      expect(find.text('Offline queued message'), findsOneWidget);
      await tester.tap(find.text('Offline queued message'));
      await tester.pumpAndSettle();
      expect(chats.online, isFalse);
      expect(
        chats
            .byId('sarah')
            .messages
            .where((message) => message.status == DeliveryStatus.queued)
            .length,
        1,
      );
      expect(find.text('Let’s catch up soon.'), findsOneWidget);
      chats.setOnline(true);
      expect(chats.byId('sarah').messages.last.status, DeliveryStatus.sent);
    },
  );

  testWidgets(
    'entries without the required session state remain visible and disabled',
    (tester) async {
      final wallet = WalletController();
      final chats = ChatsController();
      final calls = CallsController(spendCredits: (_, _, _) => true);
      final group = GroupController(chats: chats);
      final business = BusinessController(wallet: wallet);
      final publishing = PublishingController(wallet: wallet);
      final stories = StoriesController();
      addTearDown(() {
        calls.dispose();
        group.dispose();
        business.dispose();
        publishing.dispose();
        stories.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final actions = ReviewActions(
        chats: chats,
        calls: calls,
        group: group,
        business: business,
        publishing: publishing,
        stories: stories,
        wallet: wallet,
      );
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: actions)),
      );
      await tester.enterText(find.byType(TextField), 'V113');
      await tester.pumpAndSettle();
      expect(find.text('Frequency limit reached'), findsOneWidget);
      expect(find.text('Not available in the current session'), findsOneWidget);
      expect(
        tester.widget<ListTile>(find.byType(ListTile).first).enabled,
        isFalse,
      );
    },
  );
  testWidgets(
    'loading and error scenarios open the real Discover state and retry',
    (tester) async {
      final wallet = WalletController();
      final chats = ChatsController();
      final calls = CallsController(spendCredits: (_, _, _) => true);
      final group = GroupController(chats: chats);
      final business = BusinessController(wallet: wallet);
      final publishing = PublishingController(wallet: wallet);
      final stories = StoriesController();
      final discover = DiscoverController();
      addTearDown(() {
        discover.dispose();
        calls.dispose();
        group.dispose();
        business.dispose();
        publishing.dispose();
        stories.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final actions = ReviewActions(
        chats: chats,
        calls: calls,
        group: group,
        business: business,
        publishing: publishing,
        stories: stories,
        wallet: wallet,
        discover: discover,
      );
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: actions)),
      );
      await tester.enterText(find.byType(TextField), 'V001');
      await tester.pump();
      await tester.tap(find.text('Initial application loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Loading stories…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Explore stories'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'V003');
      await tester.pump();
      await tester.tap(find.text('Recoverable page error'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load Stories'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('Loading stories…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Explore stories'), findsOneWidget);
    },
  );
}
