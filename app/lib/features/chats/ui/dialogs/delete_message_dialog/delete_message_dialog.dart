import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';

enum DeleteMessageChoice { forMe, forEveryone }

class DeleteMessageDialog extends StatelessWidget {
  const DeleteMessageDialog({super.key, required this.canDeleteForEveryone});
  final bool canDeleteForEveryone;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(ChatCopy.deleteMessage),
    content: const Text(ChatCopy.chooseHowToRemoveThisMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, DeleteMessageChoice.forMe),
        child: const Text(ChatCopy.deleteForMe),
      ),
      if (canDeleteForEveryone)
        TextButton(
          onPressed: () =>
              Navigator.pop(context, DeleteMessageChoice.forEveryone),
          child: const Text(ChatCopy.deleteForEveryone),
        ),
    ],
  );
}
