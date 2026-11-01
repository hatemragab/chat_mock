import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

class DeleteConversationDialog extends StatelessWidget {
  const DeleteConversationDialog({
    super.key,
    required this.chat,
    this.groupMembershipActive = true,
  });
  final ChatConversation chat;
  final bool groupMembershipActive;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(ChatCopy.deleteConversationTitle(chat.name)),
    content: Text(
      chat.kind == ChatKind.group && groupMembershipActive
          ? ChatCopy.deleteGroupConversationDescription
          : ChatCopy.deleteConversationDescription,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(CommonCopy.delete),
      ),
    ],
  );
}
