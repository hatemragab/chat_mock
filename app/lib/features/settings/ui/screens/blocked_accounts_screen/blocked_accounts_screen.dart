import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_state_view.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../chats/models/chat_models.dart';
import '../../../../safety/ui/dialogs/account_block_dialog/account_block_dialog.dart';
import '../../../controllers/settings_controller.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key, required this.controller});
  final SettingsController controller;
  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, widget.controller.chats]),
    builder: (context, _) {
      final items = widget.controller.blockedAccounts
          .where(
            (account) =>
                account.kind != ChatKind.business &&
                account.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      final businesses =
          widget.controller.blockedBusinessNames
              .where((name) => name.toLowerCase().contains(query.toLowerCase()))
              .toList()
            ..sort();
      return AppScaffold(
        appBar: AppHeader(title: const Text(SettingsCopy.blockedAccounts)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSearchField(
              query: query,
              hintText: SettingsCopy.searchBlockedAccounts,
              onChanged: (value) => setState(() => query = value),
            ),
            if (items.isEmpty && businesses.isEmpty)
              AppStateView(
                title: query.isEmpty
                    ? SettingsCopy.noBlockedAccounts
                    : SettingsCopy.noBlockedAccountsMatchYourSearch,
              ),
            ...items.map(
              (account) => ListTile(
                leading: CircleAvatar(
                  child: Text(account.name.substring(0, 1)),
                ),
                title: Text(account.name),
                subtitle: Text(account.kind.name),
                trailing: TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          AccountBlockDialog(name: account.name, unblock: true),
                    );
                    if (confirmed == true) widget.controller.unblock(account);
                  },
                  child: const Text(SettingsCopy.unblock),
                ),
              ),
            ),
            ...businesses.map(
              (name) => ListTile(
                leading: CircleAvatar(child: Text(name.substring(0, 1))),
                title: Text(name),
                subtitle: const Text(SettingsCopy.business),
                trailing: TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AccountBlockDialog(
                        name: name,
                        unblock: true,
                        business: true,
                      ),
                    );
                    if (confirmed == true) {
                      widget.controller.setBusinessBlocked(name, false);
                    }
                  },
                  child: const Text(SettingsCopy.unblock),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
