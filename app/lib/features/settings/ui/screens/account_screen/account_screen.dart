import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../onboarding/controllers/onboarding_controller.dart';
import '../delete_account_screen/delete_account_screen.dart';
import '../../dialogs/sign_out_dialog/sign_out_dialog.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.profile,
    required this.onSignOut,
  });
  final OnboardingController profile;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(SettingsCopy.account)),
    body: ListView(
      children: [
        const ListTile(
          title: Text(SettingsCopy.linkedSignIn),
          subtitle: Text(SettingsCopy.simulatedSignIn),
        ),
        ListTile(
          title: const Text(SettingsCopy.phoneNumber),
          subtitle: Text(
            profile.phone.local.isEmpty
                ? SettingsCopy.notSet
                : profile.phone.international,
          ),
        ),
        ListTile(
          title: const Text(SettingsCopy.signOutAction),
          leading: const Icon(Icons.logout),
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => const SignOutDialog(),
            );
            if (result == true && context.mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
              onSignOut();
            }
          },
        ),
        ListTile(
          title: const Text(SettingsCopy.deleteAccountAction),
          leading: const Icon(Icons.delete_outline),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => DeleteAccountScreen(onDelete: onSignOut),
            ),
          ),
        ),
      ],
    ),
  );
}
