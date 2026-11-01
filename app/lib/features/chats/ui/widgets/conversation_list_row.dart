import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../copy/chats_copy.dart';
import '../../models/chat_models.dart';

/// One conversation identity and preview, reused by active and archived lists.
class ConversationListRow extends StatelessWidget {
  const ConversationListRow({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final ChatConversation chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    onLongPress: onLongPress,
    leading: AppAvatar(
      name: chat.name,
      image: chat.avatarAsset == null ? null : AssetImage(chat.avatarAsset!),
    ),
    title: Row(
      children: [
        Expanded(
          child: Text(
            chat.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        if (chat.pinned) const Icon(Icons.push_pin, size: 16),
      ],
    ),
    subtitle: Text(
      chat.messages.isEmpty ? ChatCopy.noMessagesYet : chat.messages.last.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing:
        trailing ??
        (chat.unread > 0
            ? CircleAvatar(
                radius: 11,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  '${chat.unread}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : chat.muted
            ? const Icon(Icons.notifications_off_outlined, size: 17)
            : null),
  );
}
