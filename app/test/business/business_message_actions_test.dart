import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/message_details_screen/message_details_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final linked in [true, false]) {
    testWidgets(
      '${linked ? 'linked' : 'standalone'} Business actions keep perspective ownership, pin, info and reactions',
      (tester) async {
        final wallet = WalletController();
        final chats = linked ? ChatsController() : null;
        final business = BusinessController(wallet: wallet, chats: chats);
        addTearDown(() {
          business.dispose();
          chats?.dispose();
          wallet.dispose();
        });
        final story = StoriesController.stories.first;
        expect(
          business.openRoom(story, confirmed: true),
          OpenRoomResult.opened,
        );
        business.send(story.id, 'Customer question');
        final message = business.roomFor(story.id)!.messages.last;
        business.setPerspective(BusinessPerspective.recipient);
        await tester.pumpWidget(
          MaterialApp(
            home: BusinessConversationScreen(
              controller: business,
              story: story,
            ),
          ),
        );

        Future<void> actions() async {
          await tester.longPress(find.text(message.text));
          await tester.pumpAndSettle();
        }

        Future<void> choose(String label) async {
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }

        await actions();
        expect(find.text('Edit'), findsNothing);
        expect(find.text('Forward'), linked ? findsOneWidget : findsNothing);
        await choose('Pin');
        expect(message.pinned, isTrue);
        await actions();
        await choose('Unpin');
        expect(message.pinned, isFalse);
        await actions();
        await choose('Message info');
        expect(
          tester
              .widget<MessageDetailsScreen>(find.byType(MessageDetailsScreen))
              .message,
          same(message),
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        await actions();
        await tester.tap(find.byTooltip('More reactions'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('React with 🎉'));
        await tester.pumpAndSettle();
        expect(message.reaction, '🎉');
        await actions();
        await tester.tap(find.byTooltip('More reactions'));
        await tester.pumpAndSettle();
        await choose('Remove reaction');
        expect(message.reaction, isNull);
        business.setPerspective(BusinessPerspective.customer);
        await tester.pump();
        await actions();
        expect(find.text('Edit'), findsOneWidget);
        expect(wallet.credits, 2990);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'Business forwarding rechecks selected recipients without another debit',
    (tester) async {
      final wallet = WalletController();
      final chats = ChatsController();
      final business = BusinessController(wallet: wallet, chats: chats);
      addTearDown(() {
        business.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final story = StoriesController.stories.first;
      business.openRoom(story, confirmed: true);
      business.send(story.id, 'Forward this answer');
      final room = business.roomFor(story.id)!;
      final message = room.messages.last;
      final sarah = chats.byId('sarah');
      final originalCount = sarah.messages.length;
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessConversationScreen(controller: business, story: story),
        ),
      );
      await tester.longPress(find.text(message.text));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forward'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pump();
      chats.toggleBlocked(sarah);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Continue (0)'),
            )
            .onPressed,
        isNull,
      );
      chats.toggleBlocked(sarah);
      await tester.pump();
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pump();
      await tester.tap(find.text('Continue (1)'));
      await tester.pumpAndSettle();
      expect(sarah.messages, hasLength(originalCount + 1));
      expect(sarah.messages.last.text, message.text);
      expect(room.messages, hasLength(1));
      expect(wallet.credits, 2990);
      expect(wallet.activity, hasLength(1));
    },
  );

  testWidgets('expiry prevents a reaction chosen from an already open picker', (
    tester,
  ) async {
    final wallet = WalletController();
    final business = BusinessController(wallet: wallet);
    addTearDown(() {
      business.dispose();
      wallet.dispose();
    });
    final story = StoriesController.stories.first;
    business.openRoom(story, confirmed: true);
    business.send(story.id, 'Keep history read-only');
    final message = business.roomFor(story.id)!.messages.last;
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessConversationScreen(controller: business, story: story),
      ),
    );
    await tester.longPress(find.text(message.text));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More reactions'));
    await tester.pumpAndSettle();
    business.advance(const Duration(hours: 24));
    await tester.pump();
    await tester.tap(find.byTooltip('React with 🎉'));
    await tester.pumpAndSettle();
    expect(message.reaction, isNull);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.text('This room has expired. History is read-only.'),
      findsOneWidget,
    );
  });

  test('Business pin ignores deleted and other-Story messages', () {
    final wallet = WalletController();
    final business = BusinessController(wallet: wallet);
    addTearDown(() {
      business.dispose();
      wallet.dispose();
    });
    final first = StoriesController.stories.first;
    final second = StoriesController.stories[1];
    business.openRoom(first, confirmed: true);
    business.openRoom(second, confirmed: true);
    business.send(first.id, 'Original');
    final message = business.roomFor(first.id)!.messages.single;
    business.togglePin(second.id, message);
    expect(message.pinned, isFalse);
    business.togglePin(first.id, message);
    business.toggleStar(first.id, message);
    expect(message.pinned, isTrue);
    business.removeMessage(first.id, message, forEveryone: true);
    business.togglePin(first.id, message);
    expect(message.pinned, isFalse);
    expect(message.starred, isFalse);
  });
}
