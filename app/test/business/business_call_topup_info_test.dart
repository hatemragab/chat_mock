import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/business/ui/screens/business_info_screen/business_info_screen.dart';
import 'package:app/features/business/ui/sheets/business_call_preflight_sheet/business_call_preflight_sheet.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final orange in [false, true]) {
    testWidgets(
      'Business call top-up returns to the same preflight using ${orange ? 'Orange' : 'MTN'}',
      (tester) async {
        final wallet = WalletController()..credits = 5;
        final stories = StoriesController();
        final business = BusinessController(wallet: wallet, stories: stories);
        final story = StoriesController.stories.firstWhere(
          (item) => item.id == 'maison',
        );
        Story? selectedStory;
        bool? selectedVideo;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => FilledButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BusinessCallPreflightSheet(
                      controller: business,
                      story: story,
                      video: true,
                      onCall: (source, video) {
                        selectedStory = source;
                        selectedVideo = video;
                      },
                    ),
                  ),
                  child: const Text('Open preflight'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open preflight'));
        await tester.pumpAndSettle();
        expect(find.text('Video call with Maison Studio'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Start call'),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(find.widgetWithText(OutlinedButton, 'Buy Credits'));
        await tester.pumpAndSettle();
        expect(find.text('Required: 25 Credits'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Buy Credits'));
        await tester.pumpAndSettle();
        if (orange) {
          await tester.tap(find.text('Payment method'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Orange Mobile Money'));
          await tester.pumpAndSettle();
        }
        await tester.enterText(
          find.widgetWithText(TextField, 'Mobile Money phone number'),
          '670000000',
        );
        await tester.ensureVisible(find.text('Review payment'));
        await tester.tap(find.text('Review payment'));
        await tester.pumpAndSettle();
        expect(
          find.text(orange ? 'Orange Mobile Money' : 'MTN Mobile Money'),
          findsWidgets,
        );
        await tester.tap(find.text('Continue to provider'));
        await tester.pumpAndSettle();
        expect(find.text('Processing'), findsOneWidget);
        await tester.tap(find.text('Refresh status'));
        await tester.pumpAndSettle();
        expect(find.text('Pending'), findsOneWidget);
        expect(wallet.credits, 5);
        expect(selectedStory, isNull);
        await tester.tap(find.text('Refresh status'));
        await tester.pumpAndSettle();
        expect(wallet.credits, 105);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Video call with Maison Studio'), findsOneWidget);
        expect(find.textContaining('Balance: 105 Credits'), findsOneWidget);
        expect(
          wallet.activity.where((item) => item.title == 'Credit purchase'),
          hasLength(1),
        );
        await tester.tap(find.text('Start call'));
        await tester.pumpAndSettle();
        expect(selectedStory, same(story));
        expect(selectedVideo, isTrue);
        expect(wallet.credits, 105);
        await tester.pumpWidget(const SizedBox.shrink());
        business.dispose();
        stories.dispose();
        wallet.dispose();
      },
    );
  }

  testWidgets(
    'preflight reflects a Story becoming unavailable without starting a call',
    (tester) async {
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(wallet: wallet, stories: stories);
      final story = StoriesController.stories.first;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusinessCallPreflightSheet(
              controller: business,
              story: story,
              video: false,
              onCall: (_, _) => calls++,
            ),
          ),
        ),
      );
      business.setSourceEligible(story.id, false);
      await tester.pump();
      expect(
        find.text('The originating Story is no longer available.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Start call'),
            )
            .onPressed,
        isNull,
      );
      expect(calls, 0);
      expect(wallet.credits, 3000);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );

  testWidgets(
    'Business info scopes shared content and returns to the originating room',
    (tester) async {
      final wallet = WalletController();
      final stories = StoriesController();
      final chats = ChatsController();
      final business = BusinessController(
        wallet: wallet,
        stories: stories,
        chats: chats,
      );
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      final chat = chats.businessConversation(story.id)!;
      final message = ChatMessage(
        id: 'shared-file',
        author: story.author,
        text: 'Maison plan.pdf',
        time: DateTime.now(),
        isMine: false,
        kind: MessageKind.document,
        starred: true,
      );
      chat.messages.add(message);
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessInfoScreen(controller: business, story: story),
        ),
      );
      await tester.ensureVisible(find.text('Media, files and links'));
      await tester.tap(find.text('Media, files and links'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Files'));
      await tester.pumpAndSettle();
      expect(find.text('Maison plan.pdf'), findsOneWidget);
      await tester.tap(find.text('Maison plan.pdf'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Show in chat'));
      await tester.tap(find.text('Show in chat'));
      await tester.pumpAndSettle();
      final sourceScreen = tester.widget<BusinessConversationScreen>(
        find.byType(BusinessConversationScreen),
      );
      expect(sourceScreen.story.id, story.id);
      expect(sourceScreen.initialMessageId, message.id);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Starred messages'));
      await tester.tap(find.text('Starred messages'));
      await tester.pumpAndSettle();
      expect(find.text('Maison plan.pdf'), findsOneWidget);
      await tester.tap(find.text('Maison plan.pdf'));
      await tester.pumpAndSettle();
      final screen = tester.widget<BusinessConversationScreen>(
        find.byType(BusinessConversationScreen),
      );
      expect(screen.story.id, story.id);
      expect(screen.initialMessageId, message.id);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      chats.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );
  testWidgets('cancelling the top-up preserves the preflight and wallet', (
    tester,
  ) async {
    final wallet = WalletController()..credits = 5;
    final stories = StoriesController();
    final business = BusinessController(wallet: wallet, stories: stories);
    final story = StoriesController.stories.first;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => BusinessCallPreflightSheet(
                  controller: business,
                  story: story,
                  video: false,
                  onCall: (_, _) => calls++,
                ),
              ),
              child: const Text('Open preflight'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open preflight'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Buy Credits'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(find.text('Audio call with Maison Studio'), findsOneWidget);
    expect(wallet.credits, 5);
    expect(wallet.payments, isEmpty);
    expect(calls, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    business.dispose();
    stories.dispose();
    wallet.dispose();
  });

  testWidgets('Business info search and starred views never mix Story rooms', (
    tester,
  ) async {
    final wallet = WalletController();
    final stories = StoriesController();
    final chats = ChatsController();
    final business = BusinessController(
      wallet: wallet,
      stories: stories,
      chats: chats,
    );
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'maison',
    );
    final other = StoriesController.stories.firstWhere(
      (item) => item.id == 'brew',
    );
    business.seedRecipientRoom(other);
    final mine = chats.businessConversation(story.id)!;
    final theirs = chats.businessConversation(other.id)!;
    final message = ChatMessage(
      id: 'maison-search',
      author: story.author,
      text: 'Design proposal',
      time: DateTime.now(),
      isMine: false,
      starred: true,
    );
    mine.messages.add(message);
    theirs.messages.add(
      ChatMessage(
        id: 'brew-search',
        author: other.author,
        text: 'Design proposal elsewhere',
        time: DateTime.now(),
        isMine: false,
        starred: true,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessInfoScreen(controller: business, story: story),
      ),
    );
    await tester.ensureVisible(find.text('Search messages'));
    await tester.tap(find.text('Search messages'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'proposal');
    await tester.pump();
    expect(find.text('Design proposal'), findsOneWidget);
    expect(find.text('Design proposal elsewhere'), findsNothing);
    await tester.tap(find.text('Design proposal'));
    await tester.pumpAndSettle();
    final screen = tester.widget<BusinessConversationScreen>(
      find.byType(BusinessConversationScreen),
    );
    expect(screen.story.id, story.id);
    expect(screen.initialMessageId, message.id);
    await tester.pumpWidget(const SizedBox.shrink());
    business.dispose();
    chats.dispose();
    stories.dispose();
    wallet.dispose();
  });
}
