import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/controllers/group_directory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('created groups retain independent membership and permission state', () {
    final chats = ChatsController();
    final seed = GroupController(chats: chats);
    final groups = GroupDirectory(chats: chats, initialGroup: seed);
    addTearDown(groups.dispose);
    addTearDown(seed.dispose);
    addTearDown(chats.dispose);
    final sarah = chats.byId('sarah');
    final created = groups.create(
      name: 'New team',
      description: 'Our project',
      members: [sarah, sarah],
    );
    expect(groups.forChat(created.chatId), same(created));
    expect(created.activeMembers.map((m) => m.id), ['alex', 'sarah']);
    expect(created.conversation.name, 'New team');
    expect(created.description, 'Our project');
    expect(created.updateIdentity('Updated team', 'Updated'), isTrue);
    expect(chats.byId(created.chatId).name, 'Updated team');
    created.setPermissions(send: true);
    created.setPerspective('sarah');
    expect(created.canSend, isFalse);
    expect(chats.send(created.conversation, 'Not allowed'), isNull);
    expect(seed.canSend, isTrue);
    final id = created.chatId;
    groups.reset();
    expect(groups.forChat(id), isNull);
    expect(groups.forChat('design'), same(seed));
  });

  test('group creation requires a name and eligible selected contacts', () {
    final chats = ChatsController();
    final seed = GroupController(chats: chats);
    final groups = GroupDirectory(chats: chats, initialGroup: seed);
    addTearDown(groups.dispose);
    addTearDown(seed.dispose);
    addTearDown(chats.dispose);
    expect(
      () => groups.create(
        name: '',
        description: '',
        members: [chats.byId('sarah')],
      ),
      throwsArgumentError,
    );
    expect(
      () => groups.create(
        name: 'No contacts',
        description: '',
        members: [chats.byId('design')],
      ),
      throwsArgumentError,
    );
    expect(
      chats.conversations.where((chat) => chat.id.startsWith('group')),
      isEmpty,
    );
  });
}
