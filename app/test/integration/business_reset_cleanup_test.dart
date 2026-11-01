import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reset removes old Business room guards before IDs are reused', () {
    final chats = ChatsController();
    final old = chats.ensureBusinessConversation('old-story', 'Old Business');
    chats.setSendGuard(old.id, () => false);
    expect(chats.canSendTo(old), isFalse);
    chats.reset();
    final replacement = chats.ensureBusinessConversation(
      'new-story',
      'New Business',
    );
    expect(replacement.id, old.id);
    expect(chats.canSendTo(replacement), isTrue);
    chats.dispose();
  });
}
