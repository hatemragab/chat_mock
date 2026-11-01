import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'outgoing direct receipts advance once in order and honor read privacy',
    () {
      final chats = ChatsController();
      final chat = chats.byId('sarah');
      var readReceipts = false;
      chats.readReceiptsEnabled = () => readReceipts;
      final message = chats.send(chat, 'A new message')!;
      final originalCount = chat.messages.length;
      final deliveredAt = DateTime(2026, 1, 1, 10);
      expect(
        chats.advanceDirectReceipt(chat, message, DeliveryStatus.read),
        isFalse,
      );
      expect(
        chats.advanceDirectReceipt(
          chat,
          message,
          DeliveryStatus.delivered,
          at: deliveredAt,
        ),
        isTrue,
      );
      expect(message.deliveredAt, deliveredAt);
      expect(
        chats.advanceDirectReceipt(chat, message, DeliveryStatus.delivered),
        isFalse,
      );
      expect(
        chats.advanceDirectReceipt(chat, message, DeliveryStatus.read),
        isFalse,
      );
      expect(message.status, DeliveryStatus.delivered);
      readReceipts = true;
      final readAt = deliveredAt.add(const Duration(minutes: 1));
      expect(
        chats.advanceDirectReceipt(
          chat,
          message,
          DeliveryStatus.read,
          at: readAt,
        ),
        isTrue,
      );
      expect(message.readAt, readAt);
      expect(
        chats.advanceDirectReceipt(chat, message, DeliveryStatus.delivered),
        isFalse,
      );
      expect(chat.messages.length, originalCount);
      chats.dispose();
    },
  );

  test('queued, failed, deleted, incoming and group messages cannot acquire direct receipts', () {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    chats.setOnline(false);
    final queued = chats.send(chat, 'Waiting')!;
    expect(
      chats.advanceDirectReceipt(chat, queued, DeliveryStatus.delivered),
      isFalse,
    );
    chats.setOnline(true);
    expect(queued.status, DeliveryStatus.sent);
    queued.status = DeliveryStatus.failed;
    expect(
      chats.advanceDirectReceipt(chat, queued, DeliveryStatus.delivered),
      isFalse,
    );
    chats.retry(queued);
    expect(
      chats.advanceDirectReceipt(chat, queued, DeliveryStatus.delivered),
      isTrue,
    );
    final incoming = chat.messages.firstWhere((message) => !message.isMine);
    expect(
      chats.advanceDirectReceipt(chat, incoming, DeliveryStatus.read),
      isFalse,
    );
    chats.delete(chat, queued, forEveryone: true);
    expect(
      chats.advanceDirectReceipt(chat, queued, DeliveryStatus.read),
      isFalse,
    );
    final group = chats.byId('design');
    final groupMessage = group.messages.firstWhere((message) => message.isMine);
    expect(
      chats.advanceDirectReceipt(group, groupMessage, DeliveryStatus.delivered),
      isFalse,
    );
    chats.dispose();
  });
}
