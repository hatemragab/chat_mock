import 'package:flutter/material.dart';

import '../../../../chats/models/chat_models.dart';
import '../../../../chats/ui/screens/chat_info_screen/chat_info_screen.dart';
import '../../../../chats/ui/screens/conversation_screen/conversation_screen.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_member.dart';
import '../../dialogs/group_member_action_dialog/group_member_action_dialog.dart';

class GroupMemberActionsSheet extends StatelessWidget {
  const GroupMemberActionsSheet({
    super.key,
    required this.controller,
    required this.member,
    this.transferMode = false,
  });
  final GroupController controller;
  final GroupMember member;
  final bool transferMode;

  Future<void> _confirm(
    BuildContext context,
    GroupMemberAction action,
    VoidCallback execute,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => GroupMemberActionDialog(member: member, action: action),
    );
    if (confirmed == true) execute();
    if (confirmed == true && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final contact = controller.chats.conversations
        .where((chat) => chat.kind == ChatKind.contact && chat.id == member.id)
        .firstOrNull;
    final canRemove =
        controller.canManage &&
        member.id != controller.perspectiveId &&
        member.role != GroupRole.owner &&
        (controller.isOwner || member.role != GroupRole.admin);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(GroupCopy.roleLabel(member.role)),
            ),
            if (contact != null &&
                member.id != controller.perspectiveId &&
                !transferMode) ...[
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text(GroupCopy.viewProfile),
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatInfoScreen(
                        controller: controller.chats,
                        chat: contact,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text(GroupCopy.message),
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute<void>(
                      builder: (_) => ConversationScreen(
                        controller: controller.chats,
                        chat: contact,
                      ),
                    ),
                  );
                },
              ),
            ],
            if (controller.isOwner &&
                member.role == GroupRole.member &&
                !transferMode)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text(GroupCopy.promoteToAdmin),
                onTap: () => _confirm(
                  context,
                  GroupMemberAction.promote,
                  () => controller.promote(member),
                ),
              ),
            if (controller.isOwner &&
                member.role == GroupRole.admin &&
                !transferMode)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text(GroupCopy.demoteAdmin),
                onTap: () => _confirm(
                  context,
                  GroupMemberAction.demote,
                  () => controller.demote(member),
                ),
              ),
            if (controller.isOwner && member.id != controller.perspectiveId)
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text(GroupCopy.transferOwnership),
                onTap: () => _confirm(
                  context,
                  GroupMemberAction.transfer,
                  () => controller.transfer(member),
                ),
              ),
            if (canRemove && !transferMode)
              ListTile(
                leading: const Icon(Icons.person_remove_outlined),
                title: const Text(GroupCopy.removeMember),
                onTap: () => _confirm(
                  context,
                  GroupMemberAction.remove,
                  () => controller.remove(member),
                ),
              ),
            if (!canRemove && !controller.isOwner)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(GroupCopy.cannotManageMember),
              ),
          ],
        ),
      ),
    );
  }
}
