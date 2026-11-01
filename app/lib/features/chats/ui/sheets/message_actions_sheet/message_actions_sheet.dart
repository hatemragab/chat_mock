import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

enum MessageAction {
  react,
  moreReactions,
  reply,
  copy,
  edit,
  forward,
  star,
  pin,
  retry,
  info,
  delete,
}

typedef MessageActionSelection = (MessageAction, String?);

/// Returns an action to its caller without losing the selected message context.
class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.canSend,
    required this.isOwn,
    this.canForward = true,
    this.canRetry = true,
  });
  final ChatMessage message;
  final bool canSend;
  final bool isOwn;
  final bool canForward;
  final bool canRetry;

  @override
  Widget build(BuildContext context) {
    void select(MessageAction action, [String? value]) =>
        Navigator.pop(context, (action, value));
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.deleted && canSend)
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final emoji in ['👍', '❤️', '😂', '😮', '😢', '🙏'])
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(36, 44),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => select(MessageAction.react, emoji),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    IconButton(
                      tooltip: ChatCopy.moreReactions,
                      onPressed: () => select(MessageAction.moreReactions),
                      icon: const Icon(Icons.add_reaction_outlined),
                    ),
                  ],
                ),
              ),
            if (!message.deleted && canSend)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text(ChatCopy.reply),
                onTap: () => select(MessageAction.reply),
              ),
            if (!message.deleted)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text(ChatCopy.copy),
                onTap: () => select(MessageAction.copy),
              ),
            if (!message.deleted && isOwn && canSend)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text(CommonCopy.edit),
                onTap: () => select(MessageAction.edit),
              ),
            if (!message.deleted && canForward)
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text(ChatCopy.forward),
                onTap: () => select(MessageAction.forward),
              ),
            if (!message.deleted)
              ListTile(
                leading: Icon(
                  message.starred ? Icons.star : Icons.star_outline,
                ),
                title: Text(message.starred ? ChatCopy.unstar : ChatCopy.star),
                onTap: () => select(MessageAction.star),
              ),
            if (!message.deleted)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: Text(message.pinned ? ChatCopy.unpin : ChatCopy.pin),
                onTap: () => select(MessageAction.pin),
              ),
            if (canRetry &&
                (message.status == DeliveryStatus.failed ||
                    message.status == DeliveryStatus.queued))
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text(CommonCopy.retry),
                onTap: () => select(MessageAction.retry),
              ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(ChatCopy.messageInfo),
              onTap: () => select(MessageAction.info),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text(CommonCopy.delete),
              onTap: () => select(MessageAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}
