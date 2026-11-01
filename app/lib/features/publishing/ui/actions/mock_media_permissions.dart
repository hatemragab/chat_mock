import 'package:flutter/material.dart';

import '../../../../shared/copy/common_copy.dart';
import '../../copy/publishing_copy.dart';

import '../../../settings/controllers/settings_controller.dart';
import '../../../settings/models/settings_models.dart';
import '../../../settings/ui/dialogs/permission_recovery_dialog/permission_recovery_dialog.dart';

/// Keeps simulated permission decisions consistent throughout a media flow.
class MockMediaPermissions {
  MockMediaPermissions({this.settings});

  final SettingsController? settings;
  final Map<String, MockPermission> _local = {
    'Media': MockPermission.denied,
    'Camera': MockPermission.denied,
    'Microphone': MockPermission.denied,
  };

  Future<bool> request(BuildContext context, String key) async {
    final permission = settings?.permissions[key] ?? _local[key];
    if (permission == null) return false;
    if (permission == MockPermission.allowed) return true;
    final allow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => permission == MockPermission.permanentlyDenied
          ? PermissionRecoveryDialog(permission: key)
          : AlertDialog(
              title: Text(PublishingCopy.permissionAccess(key)),
              content: Text(switch (key) {
                'Camera' => PublishingCopy.cameraPermissionDescription,
                'Microphone' => PublishingCopy.microphonePermissionDescription,
                _ => PublishingCopy.mediaPermissionDescription,
              }),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(CommonCopy.notNow),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(CommonCopy.allowInDemo),
                ),
              ],
            ),
    );
    if (!context.mounted || allow != true) return false;
    if (settings case final settings?) {
      settings.setPermission(key, MockPermission.allowed);
    } else {
      _local[key] = MockPermission.allowed;
    }
    return context.mounted;
  }
}
