import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/business/ui/screens/business_info_screen/business_info_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reason in ['blocked', 'suspended', 'expired']) {
    testWidgets('$reason Business history cannot be edited or reacted to', (
      tester,
    ) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      chats.canMessage = () => settings.canMessage;
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(
        wallet: wallet,
        chats: chats,
        stories: stories,
        settings: settings,
      );
      addTearDown(() {
        business.dispose();
        stories.dispose();
        wallet.dispose();
        settings.dispose();
        chats.dispose();
      });
      final story = StoriesController.stories.first;
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      expect(business.send(story.id, 'Original message'), isTrue);
      final room = business.roomFor(story.id)!;
      final message = room.messages.last;
      switch (reason) {
        case 'blocked':
          business.setBlocked(story, true);
        case 'suspended':
          settings.setRestriction(RestrictionLevel.suspension);
        case 'expired':
          business.advance(const Duration(hours: 24));
      }
      expect(business.canInteract(room), isFalse);
      expect(business.send(story.id, 'New message'), isFalse);
      expect(business.editMessage(story.id, message, 'Changed'), isFalse);
      business.react(story.id, message, '👍');
      business.removeMessage(story.id, message, forEveryone: true);
      expect(message.text, 'Original message');
      expect(message.reaction, isNull);
      expect(message.deleted, isFalse);
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessConversationScreen(controller: business, story: story),
        ),
      );
      expect(find.text('Original message'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.longPress(find.text('Original message'));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Reply'), findsNothing);
      expect(find.byTooltip('More reactions'), findsNothing);
      expect(find.text('Delete for everyone'), findsNothing);
      expect(find.text('Star'), findsOneWidget);
      await tester.ensureVisible(find.text('Delete'));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete for me'), findsOneWidget);
      expect(find.text('Delete for everyone'), findsNothing);
      if (reason == 'suspended') {
        expect(find.text('Business room · unavailable'), findsOneWidget);
        expect(find.text('Reopen room'), findsNothing);
      }
      if (reason == 'blocked') {
        expect(find.text('Business room · blocked'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('recipient sees room expiry but cannot reopen an expired room', (
    tester,
  ) async {
    final wallet = WalletController();
    final business = BusinessController(
      wallet: wallet,
      clock: () => DateTime.utc(2026, 1, 1),
    );
    addTearDown(() {
      business.dispose();
      wallet.dispose();
    });
    final story = StoriesController.stories.first;
    business.setPerspective(BusinessPerspective.recipient);
    business.seedRecipientRoom(story);
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessConversationScreen(controller: business, story: story),
      ),
    );
    expect(find.textContaining('Recipient view · Expires'), findsOneWidget);
    business.advance(const Duration(hours: 24));
    await tester.pump();
    expect(find.textContaining('Recipient view · Expired'), findsOneWidget);
    expect(find.text('Reopen room'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessInfoScreen(controller: business, story: story),
      ),
    );
    expect(find.text('Room expired'), findsOneWidget);
    expect(find.text('Reopen room'), findsNothing);
    expect(wallet.credits, 3000);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('expired room explains an unavailable originating Story', (
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
    final story = StoriesController.stories.first;
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    business.setSourceEligible(story.id, false);
    business.advance(const Duration(hours: 24));
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessConversationScreen(controller: business, story: story),
      ),
    );
    expect(
      find.text(
        'The originating Story is unavailable, so this room cannot be reopened.',
      ),
      findsOneWidget,
    );
    expect(find.text('Reopen room'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
