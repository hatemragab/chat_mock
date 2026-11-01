import '../../../copy/safety_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

class AccountBlockDialog extends StatelessWidget {
  const AccountBlockDialog({
    super.key,
    required this.name,
    required this.unblock,
    this.business = false,
  });
  final String name;
  final bool unblock;
  final bool business;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(SafetyCopy.blockQuestion(name, unblock: unblock)),
    content: Text(
      unblock
          ? business
                ? SafetyCopy.youCanContactThisBusinessAgain
                : SafetyCopy.theyCanContactYouAgain
          : business
          ? SafetyCopy.blockBusinessDescription
          : SafetyCopy.blockPersonalDescription,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(unblock ? SafetyCopy.unblock : SafetyCopy.block),
      ),
    ],
  );
}
