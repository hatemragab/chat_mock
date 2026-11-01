import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';

void main() {
  test('offline messages are queued then sent once without duplicates', () {
    final controller = ChatsController();
    final chat = controller.byId('sarah');
    final before = chat.messages.length;
    controller.setOnline(false);
    final message = controller.send(chat, 'Hello offline')!;
    expect(message.status, DeliveryStatus.queued);
    controller.setOnline(true);
    controller.setOnline(true);
    expect(message.status, DeliveryStatus.sent);
    expect(chat.messages.length, before + 1);
    controller.dispose();
  });

  test('editing and deleting for everyone apply only to own messages', () {
    final controller = ChatsController();
    final chat = controller.byId('sarah');
    final incoming = chat.messages.first;
    final original = incoming.text;
    controller.edit(incoming, 'wrong');
    controller.delete(chat, incoming, forEveryone: true);
    expect(incoming.text, original);
    final sent = controller.send(chat, 'first')!;
    controller.edit(sent, 'updated');
    expect(sent.text, 'updated');
    controller.toggleStar(sent);
    controller.delete(chat, sent, forEveryone: true);
    expect(sent.deleted, isTrue);
    expect(sent.starred, isFalse);
    controller.react(sent, '👍');
    expect(sent.reaction, isNull);
    expect(chat.messages, contains(sent));
    controller.dispose();
  });

  test('forwarding and blocking update session state', () {
    final controller = ChatsController();
    final source = controller.byId('sarah');
    final target = controller.byId('amira');
    final count = target.messages.length;
    controller.forward(source.messages.first, [target]);
    expect(target.messages.length, count + 1);
    expect(target.messages.last.text, source.messages.first.text);
    controller.toggleBlocked(target);
    expect(controller.send(target, 'blocked'), isNull);
    controller.dispose();
  });
}
