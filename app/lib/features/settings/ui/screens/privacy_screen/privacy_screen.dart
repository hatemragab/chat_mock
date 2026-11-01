import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/settings_controller.dart';
import '../../../models/settings_models.dart';
import '../blocked_accounts_screen/blocked_accounts_screen.dart';
import '../status_audience_screen/status_audience_screen.dart';
import '../../widgets/photo_visibility_preview.dart';
import '../../sheets/photo_visibility_sheet/photo_visibility_sheet.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({
    super.key,
    required this.controller,
    this.displayName = 'Alex Morgan',
  });
  final SettingsController controller;
  final String displayName;

  Future<void> _choosePhotoVisibility(BuildContext context) async {
    final result = await showModalBottomSheet<PhotoVisibility>(
      context: context,
      showDragHandle: true,
      builder: (_) => PhotoVisibilitySheet(initial: controller.photoVisibility),
    );
    if (result != null) controller.setPhotoVisibility(result);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([controller, controller.chats]),
    builder: (context, _) => AppScaffold(
      appBar: AppHeader(title: const Text(SettingsCopy.privacy)),
      body: ListView(
        children: [
          ListTile(
            title: const Text(SettingsCopy.profilePhoto),
            subtitle: Text(switch (controller.photoVisibility) {
              PhotoVisibility.everyone => SettingsCopy.everyone,
              PhotoVisibility.contacts => SettingsCopy.myContacts,
              PhotoVisibility.nobody => SettingsCopy.nobody,
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _choosePhotoVisibility(context),
          ),
          ExpansionTile(
            title: const Text(SettingsCopy.previewPhotoVisibility),
            children: [
              PhotoVisibilityPreview(
                controller: controller,
                displayName: displayName,
              ),
            ],
          ),
          ListTile(
            title: const Text(SettingsCopy.statusAudience),
            subtitle: Text(switch (controller.audience) {
              StatusAudience.contacts => SettingsCopy.myContacts,
              StatusAudience.except => SettingsCopy.myContactsExcept,
              StatusAudience.only => SettingsCopy.onlyShareWith,
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StatusAudienceScreen(controller: controller),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(SettingsCopy.readReceipts),
            subtitle: const Text(SettingsCopy.readReceiptDescription),
            value: controller.readReceipts,
            onChanged: controller.setReadReceipts,
          ),
          ListTile(
            title: const Text(SettingsCopy.blockedAccounts),
            subtitle: Text(
              SettingsCopy.blockedCount(controller.blockedAccountCount),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlockedAccountsScreen(controller: controller),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
