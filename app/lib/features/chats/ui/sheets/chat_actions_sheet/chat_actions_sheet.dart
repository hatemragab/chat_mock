import 'package:flutter/material.dart';

import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

enum ChatListAction { pin, archive, mute, unread, starred, delete }

/// Actions return to the caller so navigation and confirmations keep context.
class ChatActionsSheet extends StatelessWidget {
  const ChatActionsSheet({super.key, required this.chat});
  final ChatConversation chat;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(chat.name),
            subtitle: const Text(ChatCopy.chatOptions),
          ),
          ListTile(
            leading: Icon(
              chat.pinned ? Icons.push_pin_outlined : Icons.push_pin,
            ),
            title: Text(chat.pinned ? ChatCopy.unpin : ChatCopy.pin),
            onTap: () => Navigator.pop(context, ChatListAction.pin),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(chat.archived ? ChatCopy.unarchive : ChatCopy.archive),
            onTap: () => Navigator.pop(context, ChatListAction.archive),
          ),
          ListTile(
            leading: Icon(
              chat.muted
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
            ),
            title: Text(chat.muted ? ChatCopy.muteOptions : ChatCopy.mute),
            onTap: () => Navigator.pop(context, ChatListAction.mute),
          ),
          ListTile(
            leading: const Icon(Icons.mark_email_unread_outlined),
            title: Text(
              chat.unread > 0 ? ChatCopy.markRead : ChatCopy.markUnread,
            ),
            onTap: () => Navigator.pop(context, ChatListAction.unread),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text(ChatCopy.starredMessages),
            onTap: () => Navigator.pop(context, ChatListAction.starred),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text(ChatCopy.deleteConversation),
            onTap: () => Navigator.pop(context, ChatListAction.delete),
          ),
        ],
      ),
    ),
  );
}
