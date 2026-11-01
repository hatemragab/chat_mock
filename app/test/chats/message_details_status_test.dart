import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/copy/chats_copy.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/message_details_screen/message_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'message info distinguishes unsent states and updates receipt times after retry',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final chat = chats.byId('sarah');
      chats.setOnline(false);
      final message = chats.send(chat, 'Waiting for a connection')!;
      await tester.pumpWidget(
        MaterialApp(
          home: MessageDetailsScreen(message: message, updates: chats),
        ),
      );
      final createdAt = ChatCopy.createdAt(ChatCopy.clockTime(message.time));
      for (final (status, label) in [
        (DeliveryStatus.queued, 'Queued'),
        (DeliveryStatus.sending, 'Sending'),
        (DeliveryStatus.failed, 'Failed to send'),
      ]) {
        message.status = status;
        chats.refreshConversations();
        await tester.pump();
        expect(find.text(label), findsOneWidget);
        expect(find.text(createdAt), findsOneWidget);
        expect(find.text('Sent'), findsNothing);
        expect(find.text('Not yet read'), findsOneWidget);
      }
      chats.setOnline(true);
      chats.retry(message);
      await tester.pump();
      expect(find.text('Sent'), findsOneWidget);
      expect(find.text(createdAt), findsNothing);
      final deliveredAt = DateTime(2026, 1, 1, 10, 5);
      final readAt = deliveredAt.add(const Duration(minutes: 2));
      expect(
        chats.advanceDirectReceipt(
          chat,
          message,
          DeliveryStatus.delivered,
          at: deliveredAt,
        ),
        isTrue,
      );
      await tester.pump();
      expect(find.text('Delivered at 10:05'), findsOneWidget);
      expect(find.text('Not yet read'), findsOneWidget);
      expect(
        chats.advanceDirectReceipt(
          chat,
          message,
          DeliveryStatus.read,
          at: readAt,
        ),
        isTrue,
      );
      await tester.pump();
      expect(find.text('Read at 10:07'), findsOneWidget);
      expect(find.text('Delivered at 10:05'), findsOneWidget);
      expect(
        chat.messages.where((item) => item.id == message.id),
        hasLength(1),
      );
    },
  );
}
