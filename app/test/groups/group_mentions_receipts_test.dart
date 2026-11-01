import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/message_details_screen/message_details_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'receipts snapshot recipients and permit only the sender to advance them',
    () {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      final ownFixtures = group.conversation.messages
          .where(group.isOwnMessage)
          .toList();
      expect(
        ownFixtures.first.recipients.every(
          (r) => r.status == RecipientDeliveryStatus.read,
        ),
        isTrue,
      );
      expect(
        ownFixtures.last.recipients.where(
          (r) => r.status == RecipientDeliveryStatus.read,
        ),
        hasLength(1),
      );
      expect(
        ownFixtures.last.recipients.where(
          (r) => r.status == RecipientDeliveryStatus.delivered,
        ),
        hasLength(2),
      );
      final john = group.members.firstWhere((m) => m.id == 'john');
      expect(group.remove(john), isTrue);
      final message = group.send('Hello @Sarah Wilson and @John Davis')!;
      expect(message.mentionedMemberIds, ['sarah']);
      expect(message.recipients.map((r) => r.memberId), ['sarah', 'amira']);
      expect(
        group.advanceReceipt(message, 'john', RecipientDeliveryStatus.read),
        isFalse,
      );
      expect(
        group.advanceReceipt(
          message,
          'sarah',
          RecipientDeliveryStatus.delivered,
        ),
        isTrue,
      );
      expect(
        group.advanceReceipt(message, 'sarah', RecipientDeliveryStatus.read),
        isTrue,
      );
      expect(
        group.advanceReceipt(
          message,
          'sarah',
          RecipientDeliveryStatus.delivered,
        ),
        isFalse,
      );
      expect(message.status, DeliveryStatus.sent);
      expect(
        group.advanceReceipt(message, 'amira', RecipientDeliveryStatus.read),
        isTrue,
      );
      expect(message.status, DeliveryStatus.read);
      chats.setOnline(false);
      final queued = group.send('Waiting for connection')!;
      expect(
        group.advanceReceipt(queued, 'sarah', RecipientDeliveryStatus.read),
        isFalse,
      );
      chats.setOnline(true);
      expect(
        group.advanceReceipt(queued, 'sarah', RecipientDeliveryStatus.read),
        isTrue,
      );
      group.setPerspective('sarah');
      expect(
        group.advanceReceipt(message, 'amira', RecipientDeliveryStatus.read),
        isFalse,
      );
    },
  );

  testWidgets(
    'mention suggestions select an active member at the caret and send the mention',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(home: GroupScreen(controller: group)),
      );
      await tester.enterText(find.byType(TextField), 'Hello @Sa');
      await tester.pump();
      expect(find.text('Sarah Wilson'), findsOneWidget);
      expect(find.text('Amira Hassan'), findsNothing);
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Hello @Sarah Wilson ',
      );
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      expect(group.conversation.messages.last.mentionedMemberIds, ['sarah']);
      expect(find.text('Hello @Sarah Wilson'), findsOneWidget);
    },
  );

  testWidgets(
    'group message info separates read and delivered members and protects other senders',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      final message = group.conversation.messages
          .where(group.isOwnMessage)
          .last;
      await tester.pumpWidget(
        MaterialApp(
          home: MessageDetailsScreen(
            message: message,
            group: true,
            canSeeGroupReceipts: true,
          ),
        ),
      );
      expect(find.text('Read by'), findsOneWidget);
      expect(find.text('Delivered to'), findsOneWidget);
      expect(find.text('Sarah Wilson'), findsOneWidget);
      expect(find.text('Amira Hassan'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: MessageDetailsScreen(
            message: message,
            group: true,
            canSeeGroupReceipts: false,
          ),
        ),
      );
      expect(
        find.text('Only the sender can view group receipts.'),
        findsOneWidget,
      );
      expect(find.text('Sarah Wilson'), findsNothing);
    },
  );
  testWidgets(
    'initial mention draft focuses the composer and survives updates',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: GroupScreen(controller: group, initialDraft: '@'),
        ),
      );
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '@');
      expect(field.controller!.selection.baseOffset, 1);
      expect(field.focusNode!.hasFocus, isTrue);
      expect(find.text('Sarah Wilson'), findsOneWidget);
      expect(find.text('Amira Hassan'), findsOneWidget);
      expect(find.text('Alex Morgan'), findsNothing);
      await tester.enterText(find.byType(TextField), '@Am');
      await tester.pump();
      group.toggleMuted();
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '@Am',
      );
      expect(find.text('Amira Hassan'), findsOneWidget);
      expect(find.text('Sarah Wilson'), findsNothing);
    },
  );
}
