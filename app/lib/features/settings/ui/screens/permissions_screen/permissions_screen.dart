import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/settings_controller.dart';
import '../../../models/settings_models.dart';
import '../../dialogs/permission_recovery_dialog/permission_recovery_dialog.dart';
import 'widgets/contact_matching_panel.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key, required this.controller});
  final SettingsController controller;
  String _label(MockPermission permission) => switch (permission) {
    MockPermission.allowed => SettingsCopy.allowed,
    MockPermission.denied => SettingsCopy.denied,
    MockPermission.permanentlyDenied => SettingsCopy.permanentlyDenied,
  };
  Future<void> _change(BuildContext context, String name) async {
    final current = controller.permissions[name]!;
    if (current == MockPermission.permanentlyDenied) {
      final open = await showDialog<bool>(
        context: context,
        builder: (_) => PermissionRecoveryDialog(permission: name),
      );
      if (open == true) controller.setPermission(name, MockPermission.allowed);
      return;
    }
    final result = await showModalBottomSheet<MockPermission>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SettingsCopy.permissionControl(name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final option in MockPermission.values)
              ListTile(
                title: Text(_label(option)),
                trailing: current == option ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (result != null) controller.setPermission(name, result);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([controller, controller.chats]),
    builder: (context, _) => AppScaffold(
      appBar: AppHeader(title: const Text(SettingsCopy.permissions)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(SettingsCopy.permissionSimulationDescription),
          const SizedBox(height: 16),
          ContactMatchingPanel(
            controller: controller,
            onReviewPermission: () => _change(context, 'Contacts'),
          ),
          ...controller.permissions.entries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(SettingsCopy.permissionLabel(entry.key)),
              subtitle: Text(
                entry.key == 'Contacts' && entry.value == MockPermission.allowed
                    ? SettingsCopy.allowedContactMatchingAvailable
                    : _label(entry.value),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _change(context, entry.key),
            ),
          ),
        ],
      ),
    ),
  );
}
