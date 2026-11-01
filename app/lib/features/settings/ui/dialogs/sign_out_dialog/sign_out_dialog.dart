import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(SettingsCopy.signOutTitle),
    content: const Text(SettingsCopy.signOutDescription),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(SettingsCopy.signOutAction),
      ),
    ],
  );
}
