import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../dialogs/delete_account_dialog/delete_account_dialog.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key, required this.onDelete});
  final VoidCallback onDelete;
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool acknowledged = false;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(SettingsCopy.deleteAccountAction)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          SettingsCopy.beforeYouContinue,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Text(SettingsCopy.deleteAccountConsequences),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: acknowledged,
          onChanged: (value) => setState(() => acknowledged = value ?? false),
          title: const Text(SettingsCopy.iUnderstandTheConsequences),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: !acknowledged
              ? null
              : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => const DeleteAccountDialog(),
                  );
                  if (confirmed == true && context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    widget.onDelete();
                  }
                },
          child: const Text(CommonCopy.continueLabel),
        ),
      ],
    ),
  );
}
