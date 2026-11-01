import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('business rooms and chat search use one Story-keyed message list', () {
    var now = DateTime(2026, 1, 1);
    final chats = ChatsController();
    final wallet = WalletController(clock: () => now);
    final stories = StoriesController(clock: () => now);
    final business = BusinessController(
      chats: chats,
      stories: stories,
      wallet: wallet,
      clock: () => now,
    );
    final maison = StoriesController.stories.first;
    final brew = StoriesController.stories[1];
    final initial = chats.businessConversation(maison.id)!;
    expect(business.storyForChat(initial), maison);
    expect(business.isActive(business.roomFor(maison.id)!), isFalse);
    expect(chats.canSendTo(initial), isFalse);
    expect(business.openRoom(maison), OpenRoomResult.confirmationRequired);
    expect(business.openRoom(maison, confirmed: true), OpenRoomResult.opened);
    final afterOpening = wallet.credits;
    expect(
      business.openRoom(maison, confirmed: true),
      OpenRoomResult.alreadyActive,
    );
    expect(wallet.credits, afterOpening);
    business.send(maison.id, 'Can I see the catalogue?');
    final sent = initial.messages.last;
    expect(identical(sent, business.roomFor(maison.id)!.messages.last), isTrue);
    business.toggleStar(maison.id, sent);
    expect(initial.messages.where((message) => message.starred).single, sent);
    expect(business.openRoom(brew, confirmed: true), OpenRoomResult.opened);
    business.send(brew.id, 'Coffee please');
    expect(
      chats.businessConversation(brew.id)!.messages.single.text,
      'Coffee please',
    );
    expect(
      initial.messages.any((message) => message.text == 'Coffee please'),
      isFalse,
    );
    expect(chats.businessConversation(brew.id)!.name, brew.author);
    now = now.add(const Duration(hours: 25));
    expect(chats.canSendTo(initial), isFalse);
    expect(business.send(maison.id, 'Too late'), isFalse);
    business.reset();
    expect(
      chats.conversations
          .where((chat) => chat.kind == ChatKind.business)
          .length,
      1,
    );
    expect(chats.businessConversation(maison.id)!.messages.length, 1);
    business.dispose();
    stories.dispose();
    wallet.dispose();
    chats.dispose();
  });

  test('blocking a Business prevents direct and forwarded sends', () {
    final chats = ChatsController();
    final wallet = WalletController();
    final stories = StoriesController();
    final business = BusinessController(
      chats: chats,
      stories: stories,
      wallet: wallet,
    );
    final story = StoriesController.stories.first;
    business.openRoom(story, confirmed: true);
    final chat = chats.businessConversation(story.id)!;
    chats.toggleBlocked(chat);
    expect(business.send(story.id, 'Blocked'), isFalse);
    final before = chat.messages.length;
    chats.forward(
      ChatMessage(
        id: 'other',
        author: 'Sarah',
        text: 'Forward',
        time: DateTime.now(),
        isMine: false,
      ),
      [chat],
    );
    expect(chat.messages.length, before);
    business.dispose();
    stories.dispose();
    wallet.dispose();
    chats.dispose();
  });

  test('opening a chat respects the current read receipts preference', () {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    chats.readReceiptsEnabled = () => false;
    chats.markRead(chat);
    expect(chat.unread, 0);
    expect(
      chat.messages
          .where((message) => !message.isMine)
          .every((message) => message.status == DeliveryStatus.delivered),
      isTrue,
    );
    chats.setUnread(chat, true);
    chats.readReceiptsEnabled = () => true;
    chats.markRead(chat);
    expect(
      chat.messages
          .where((message) => !message.isMine)
          .every((message) => message.status == DeliveryStatus.read),
      isTrue,
    );
    chats.dispose();
  });

  testWidgets(
    'target message from search is visible and highlighted in the Story room',
    (tester) async {
      final chats = ChatsController();
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(
        chats: chats,
        stories: stories,
        wallet: wallet,
      );
      final story = StoriesController.stories.first;
      business.openRoom(story, confirmed: true);
      for (var i = 0; i < 40; i++) {
        business.send(story.id, 'Message $i');
      }
      final target = business.roomFor(story.id)!.messages[30];
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessConversationScreen(
            controller: business,
            story: story,
            initialMessageId: target.id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(target.text), findsOneWidget);
      final y = tester.getTopLeft(find.text(target.text)).dy;
      expect(y, greaterThan(0));
      expect(
        y,
        lessThan(
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        ),
      );
      await tester.pumpWidget(const SizedBox());
      business.dispose();
      stories.dispose();
      wallet.dispose();
      chats.dispose();
    },
  );
}
