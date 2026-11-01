import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';

class ClearConversationDialog extends StatelessWidget {
  const ClearConversationDialog({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(ChatCopy.clearConversationTitle(name)),
    content: const Text(ChatCopy.clearConversationDescription),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(ChatCopy.clear),
      ),
    ],
  );
}
