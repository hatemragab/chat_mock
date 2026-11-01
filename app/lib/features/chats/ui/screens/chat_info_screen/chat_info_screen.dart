import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../safety/ui/dialogs/account_block_dialog/account_block_dialog.dart';
import '../../../../safety/models/report_submission.dart';
import '../../../../safety/ui/screens/report_screen/report_screen.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';
import '../../dialogs/clear_conversation_dialog/clear_conversation_dialog.dart';
import '../../dialogs/delete_contact_dialog/delete_contact_dialog.dart';
import '../../sheets/mute_duration_sheet/mute_duration_sheet.dart';
import '../chat_search_screen/chat_search_screen.dart';
import '../edit_contact_screen/edit_contact_screen.dart';
import '../shared_media_screen/shared_media_screen.dart';
import '../starred_messages_screen/starred_messages_screen.dart';

class ChatInfoScreen extends StatelessWidget {
  const ChatInfoScreen({
    super.key,
    required this.controller,
    required this.chat,
    this.submitReport,
  });
  final ChatsController controller;
  final ChatConversation chat;
  final Future<ReportOutcome> Function(ReportSubmission submission)?
  submitReport;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(
      title: Text(
        chat.kind == ChatKind.group ? ChatCopy.groupInfo : ChatCopy.contactInfo,
      ),
    ),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) => ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AppAvatar(
              name: chat.name,
              image: chat.avatarAsset == null
                  ? null
                  : AssetImage(chat.avatarAsset!),
              radius: 42,
              textStyle: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              chat.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Center(child: Text(chat.subtitle)),
          if (chat.phone != null && chat.phone != chat.subtitle)
            Column(
              children: [const Text(ChatCopy.demoPhone), Text(chat.phone!)],
            ),
          const SizedBox(height: 20),
          const Divider(),
          if (chat.kind == ChatKind.contact && controller.onStartCall != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: !controller.canCommunicateWithContact(chat)
                      ? null
                      : () => controller.onStartCall!(chat, false),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text(ChatCopy.audioCall),
                ),
                TextButton.icon(
                  onPressed: !controller.canCommunicateWithContact(chat)
                      ? null
                      : () => controller.onStartCall!(chat, true),
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text(ChatCopy.videoCall),
                ),
              ],
            ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text(ChatCopy.mediaFilesAndLinks),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    SharedMediaScreen(chat: chat, controller: controller),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text(ChatCopy.starredMessages),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    StarredMessagesScreen(controller: controller, chat: chat),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text(ChatCopy.searchConversation),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    ChatSearchScreen(controller: controller, chat: chat),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_off_outlined),
            title: const Text(ChatCopy.muteNotifications),
            value: chat.muted,
            onChanged: (_) async {
              final choice = await showModalBottomSheet<MuteChoice>(
                context: context,
                showDragHandle: true,
                builder: (_) =>
                    MuteDurationSheet(name: chat.name, isMuted: chat.muted),
              );
              if (choice == null) return;
              switch (choice) {
                case MuteChoice.eightHours:
                  controller.muteFor(chat, const Duration(hours: 8));
                case MuteChoice.oneWeek:
                  controller.muteFor(chat, const Duration(days: 7));
                case MuteChoice.always:
                  controller.muteFor(chat, null);
                case MuteChoice.unmute:
                  controller.unmute(chat);
              }
            },
          ),
          ListTile(
            leading: Icon(chat.blocked ? Icons.lock_open : Icons.block),
            title: Text(chat.blocked ? ChatCopy.unblock : ChatCopy.block),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) =>
                    AccountBlockDialog(name: chat.name, unblock: chat.blocked),
              );
              if (confirmed == true) controller.toggleBlocked(chat);
            },
          ),
          if (chat.kind == ChatKind.contact)
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(ChatCopy.reportContact(chat.name)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReportScreen(
                    target: chat.name,
                    targetId: chat.id,
                    submit: submitReport,
                  ),
                ),
              ),
            ),
          if (chat.kind == ChatKind.contact)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text(ChatCopy.editContact),
              onTap: () async {
                final edited = await Navigator.push<ChatConversation>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactScreen(
                      controller: controller,
                      contact: chat,
                    ),
                  ),
                );
                if (edited != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(ChatCopy.contactUpdated)),
                  );
                }
              },
            ),
          if (chat.kind == ChatKind.contact)
            ListTile(
              leading: const Icon(Icons.contacts_outlined),
              title: const Text(ChatCopy.deleteDeviceContact),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteContactDialog(name: chat.name),
                );
                if (confirmed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(ChatCopy.deviceContactsOpened),
                    ),
                  );
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text(ChatCopy.clearConversation),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => ClearConversationDialog(name: chat.name),
              );
              if (confirmed == true) {
                for (final message in List<ChatMessage>.of(chat.messages)) {
                  controller.delete(chat, message);
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}
