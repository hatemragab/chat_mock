import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/models/group_member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ChatsController chats;
  late GroupController group;
  setUp(() {
    chats = ChatsController();
    group = GroupController(chats: chats);
  });
  tearDown(() {
    group.dispose();
    chats.dispose();
  });

  test('owner transfers ownership before leaving; history stays read-only', () {
    final sarah = group.members.firstWhere((member) => member.id == 'sarah');
    expect(group.leave(), isFalse);
    expect(group.transfer(sarah), isTrue);
    expect(sarah.role, GroupRole.owner);
    expect(group.perspective.role, GroupRole.admin);
    expect(group.leave(), isTrue);
    expect(group.left, isTrue);
    expect(group.canSend, isFalse);
    expect(group.send('Should not send'), isNull);
    expect(group.conversation.messages, isNotEmpty);
    group.setPerspective('sarah');
    group.setPerspective('alex');
    expect(group.left, isTrue);
  });

  test(
    'only allowed roles manage members and admin-only sending is enforced',
    () {
      final amira = group.members.firstWhere((member) => member.id == 'amira');
      final sarah = group.members.firstWhere((member) => member.id == 'sarah');
      group.setPermissions(send: true);
      group.setPerspective('amira');
      expect(group.canSend, isFalse);
      expect(group.promote(amira), isFalse);
      expect(group.remove(sarah), isFalse);
      group.setPerspective('sarah');
      expect(group.canSend, isTrue);
      expect(group.remove(amira), isTrue);
      expect(
        group.remove(group.members.firstWhere((member) => member.id == 'alex')),
        isFalse,
      );
      group.setPerspective('alex');
      expect(group.addMembers([amira]), isTrue);
      expect(amira.active, isTrue);
      expect(amira.departure, isNull);
      expect(group.addMembers([amira]), isFalse);
      expect(group.members.where((member) => member.id == 'amira').length, 1);
    },
  );

  test(
    'owner-only role changes reject nonmembers and update exactly one owner',
    () {
      final john = group.members.firstWhere((member) => member.id == 'john');
      final unknown = GroupMember(id: 'unknown', name: 'Unknown');
      expect(group.promote(unknown), isFalse);
      expect(group.transfer(unknown), isFalse);
      expect(group.promote(john), isTrue);
      expect(group.demote(john), isTrue);
      expect(group.transfer(john), isTrue);
      expect(
        group.members.where((member) => member.role == GroupRole.owner).single,
        same(john),
      );
    },
  );
  test(
    'shared chat updates identity and enforces permissions for all send paths',
    () {
      expect(group.updateIdentity('Creative Team', 'Updated'), isTrue);
      expect(chats.byId('design').name, 'Creative Team');
      group.toggleMuted();
      expect(chats.byId('design').muted, isTrue);
      group.setPermissions(send: true);
      group.setPerspective('amira');
      final count = group.conversation.messages.length;
      final source = chats.byId('sarah').messages.first;
      chats.forward(source, [group.conversation]);
      expect(chats.send(group.conversation, 'Bypass'), isNull);
      expect(group.conversation.messages.length, count);
      group.setPerspective('sarah');
      final sent = group.send('Hello team')!;
      expect(sent.authorId, 'sarah');
      expect(group.isOwnMessage(sent), isTrue);
      group.setPerspective('alex');
      expect(group.isOwnMessage(sent), isFalse);
    },
  );
}
