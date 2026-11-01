import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

class PermissionRecoveryDialog extends StatelessWidget {
  const PermissionRecoveryDialog({super.key, required this.permission});
  final String permission;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(SettingsCopy.permissionAccess(permission)),
    content: const Text(SettingsCopy.permanentlyDeniedDescription),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(CommonCopy.openSettings),
      ),
    ],
  );
}
