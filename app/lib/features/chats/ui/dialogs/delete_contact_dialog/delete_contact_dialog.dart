import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';

class DeleteContactDialog extends StatelessWidget {
  const DeleteContactDialog({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(ChatCopy.deleteDeviceContactTitle(name)),
    content: const Text(ChatCopy.deleteDeviceContactDescription),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(ChatCopy.openContacts),
      ),
    ],
  );
}
