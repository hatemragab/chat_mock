import 'package:flutter/material.dart';

import '../../../copy/groups_copy.dart';

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key, required this.description});
  final String description;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(GroupCopy.discardChanges),
    content: Text(description),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(GroupCopy.keepEditing),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(GroupCopy.discard),
      ),
    ],
  );
}
