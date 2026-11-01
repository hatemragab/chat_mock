import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(SettingsCopy.deleteAccountTitle),
    content: const Text(SettingsCopy.deleteAccountDescription),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(SettingsCopy.deleteAccountAction),
      ),
    ],
  );
}
