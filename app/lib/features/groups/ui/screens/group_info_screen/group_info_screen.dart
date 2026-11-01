import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../chats/copy/chats_copy.dart';
import '../../../../chats/ui/dialogs/delete_conversation_dialog/delete_conversation_dialog.dart';
import '../../../../chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import '../../../../chats/ui/screens/shared_media_screen/shared_media_screen.dart';
import '../../../../chats/ui/screens/starred_messages_screen/starred_messages_screen.dart';
import '../../../../chats/ui/sheets/mute_duration_sheet/mute_duration_sheet.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../../dialogs/leave_group_dialog/leave_group_dialog.dart';
import '../../sheets/group_member_actions_sheet/group_member_actions_sheet.dart';
import '../../widgets/group_member_row.dart';
import '../group_details_screen/group_details_screen.dart';
import '../add_group_members_screen/add_group_members_screen.dart';
import '../group_members_screen/group_members_screen.dart';
import '../group_permissions_screen/group_permissions_screen.dart';
import '../group_screen/group_screen.dart';

class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key, required this.controller});
  final GroupController controller;
  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConversationDialog(
        chat: controller.conversation,
        groupMembershipActive:
            controller.perspective.active && !controller.left,
      ),
    );
    if (confirmed != true || !context.mounted) return;
    controller.chats.deleteConversation(controller.conversation);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _leave(BuildContext context) async {
    final choice = await showDialog<LeaveGroupChoice>(
      context: context,
      builder: (_) => LeaveGroupDialog(
        groupName: controller.name,
        isOwner: controller.isOwner,
      ),
    );
    if (!context.mounted) return;
    if (choice == LeaveGroupChoice.leave) {
      controller.leave();
    } else if (choice == LeaveGroupChoice.chooseOwner) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              GroupMembersScreen(controller: controller, transferMode: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([controller, controller.chats]),
    builder: (context, _) => AppScaffold(
      appBar: AppHeader(
        title: const Text(GroupCopy.groupInfo),
        actions: [
          if (controller.canEdit)
            IconButton(
              tooltip: GroupCopy.editGroup,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => GroupDetailsScreen(controller: controller),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: AppAvatar(
              name: controller.name,
              radius: 42,
              image: controller.photo.assetPath == null
                  ? null
                  : AssetImage(controller.photo.assetPath!),
              textStyle: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              controller.name,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(controller.description, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(GroupCopy.muteNotifications),
            value: controller.muted,
            onChanged: (_) async {
              final choice = await showModalBottomSheet<MuteChoice>(
                context: context,
                showDragHandle: true,
                builder: (_) => MuteDurationSheet(
                  name: controller.name,
                  isMuted: controller.muted,
                ),
              );
              if (choice == null) return;
              switch (choice) {
                case MuteChoice.eightHours:
                  controller.muteFor(const Duration(hours: 8));
                case MuteChoice.oneWeek:
                  controller.muteFor(const Duration(days: 7));
                case MuteChoice.always:
                  controller.muteFor(null);
                case MuteChoice.unmute:
                  controller.unmute();
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text(GroupCopy.mediaFilesAndLinks),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SharedMediaScreen(
                  chat: controller.conversation,
                  controller: controller.chats,
                  specialMessageScreenBuilder: (chat, messageId) =>
                      chat.id == controller.conversation.id
                      ? GroupScreen(
                          controller: controller,
                          initialMessageId: messageId,
                        )
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_outline),
            title: const Text(GroupCopy.starredMessages),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StarredMessagesScreen(
                  controller: controller.chats,
                  chat: controller.conversation,
                  specialMessageScreenBuilder: (chat, messageId) =>
                      chat.id == controller.conversation.id
                      ? GroupScreen(
                          controller: controller,
                          initialMessageId: messageId,
                        )
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.search),
            title: const Text(GroupCopy.searchConversation),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ChatSearchScreen(
                  controller: controller.chats,
                  chat: controller.conversation,
                  specialMessageScreenBuilder: (chat, messageId) =>
                      chat.id == controller.conversation.id
                      ? GroupScreen(
                          controller: controller,
                          initialMessageId: messageId,
                        )
                      : null,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.people_outline),
            title: Text(GroupCopy.memberCount(controller.activeMembers.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => GroupMembersScreen(controller: controller),
              ),
            ),
          ),
          for (final member in controller.activeMembers.take(3))
            GroupMemberRow(
              member: member,
              isCurrentUser: member.id == controller.perspectiveId,
              contentPadding: EdgeInsets.zero,
              onTap: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => GroupMemberActionsSheet(
                  controller: controller,
                  member: member,
                ),
              ),
            ),
          if (controller.canManage)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_add_alt),
              title: const Text(GroupCopy.addMembers),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AddGroupMembersScreen(controller: controller),
                ),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: const Text(GroupCopy.groupPermissions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => GroupPermissionsScreen(controller: controller),
              ),
            ),
          ),
          if (controller.perspective.active && !controller.left)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text(GroupCopy.leaveGroup),
              onTap: () => _leave(context),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text(ChatCopy.deleteConversation),
            onTap: () => _delete(context),
          ),
        ],
      ),
    ),
  );
}
