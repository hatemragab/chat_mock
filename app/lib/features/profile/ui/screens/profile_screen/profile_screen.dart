import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_section_heading.dart';

import '../../../copy/profile_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../wallet/controllers/wallet_controller.dart';
import '../../widgets/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onWallet,
    required this.onAppearance,
    required this.onSignOut,
    required this.onPrototypeTools,
    required this.onPublishing,
    required this.onSettings,
    this.wallet,
    this.onBusinessTools,
    this.onPublications,
    this.onEarnings,
    this.onSupport,
    this.name = 'Alex Morgan',
    this.about = ProfileCopy.helloThereIAmUsingWhizpee,
    this.photoLabel,
  });
  final VoidCallback onWallet;
  final VoidCallback onAppearance;
  final VoidCallback onSignOut;
  final VoidCallback onPrototypeTools;
  final VoidCallback onPublishing;
  final VoidCallback onSettings;
  final WalletController? wallet;
  final VoidCallback? onBusinessTools;
  final VoidCallback? onPublications;
  final VoidCallback? onEarnings;
  final VoidCallback? onSupport;
  final String name;
  final String about;
  final String? photoLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppHeader(title: const Text(ProfileCopy.profile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                ProfileAvatar(name: name, photoLabel: photoLabel),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  about,
                  style: TextStyle(color: color.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: onWallet,
              leading: Icon(
                Icons.account_balance_wallet_outlined,
                color: color.primary,
              ),
              title: const Text(
                ProfileCopy.myWallet,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: wallet == null
                  ? const Text(ProfileCopy.creditsDiamondsAndCash)
                  : ListenableBuilder(
                      listenable: wallet!,
                      builder: (context, _) => Text(
                        ProfileCopy.walletSummary(
                          wallet!.credits,
                          wallet!.diamonds,
                          wallet!.cash,
                        ),
                      ),
                    ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onPublishing,
            leading: const Icon(Icons.add_box_outlined),
            title: const Text(ProfileCopy.publishing),
            subtitle: const Text(ProfileCopy.createAndManageYourPublications),
            trailing: const Icon(Icons.chevron_right),
          ),
          if (onBusinessTools != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onBusinessTools,
              leading: const Icon(Icons.storefront_outlined),
              title: const Text(ProfileCopy.businessTools),
              trailing: const Icon(Icons.chevron_right),
            ),
          if (onPublications != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onPublications,
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: const Text(ProfileCopy.myPublications),
              trailing: const Icon(Icons.chevron_right),
            ),
          if (onEarnings != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onEarnings,
              leading: const Icon(Icons.diamond_outlined),
              title: const Text(ProfileCopy.earnings),
              subtitle: const Text(ProfileCopy.viewDiamondActivity),
              trailing: const Icon(Icons.chevron_right),
            ),
          if (onSupport != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onSupport,
              leading: const Icon(Icons.help_outline),
              title: const Text(ProfileCopy.helpSupport),
              trailing: const Icon(Icons.chevron_right),
            ),
          AppSectionHeading(
            title: ProfileCopy.preferences,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onPrototypeTools,
            leading: const Icon(Icons.tune),
            title: const Text(ProfileCopy.prototypeTools),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onSettings,
            leading: const Icon(Icons.settings_outlined),
            title: const Text(ProfileCopy.settings),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onAppearance,
            leading: const Icon(Icons.palette_outlined),
            title: const Text(ProfileCopy.appearance),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onSignOut,
            leading: const Icon(Icons.logout),
            title: const Text(ProfileCopy.signOut),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
