import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';

class DeleteCallDialog extends StatelessWidget {
  const DeleteCallDialog({super.key, required this.call});
  final CallSession call;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(CallsCopy.deleteCallQuestion),
    content: Text(CallsCopy.deleteHistoryQuestion(call.name)),
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
