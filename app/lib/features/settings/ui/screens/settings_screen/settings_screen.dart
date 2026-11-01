import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../onboarding/controllers/onboarding_controller.dart';
import '../../../../business/ui/screens/own_business_profile_screen/own_business_profile_screen.dart';
import '../../../../stories/controllers/stories_controller.dart';
import '../../../../profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import '../../../../support/ui/screens/about_screen/about_screen.dart';
import '../../../../support/ui/screens/help_screen/help_screen.dart';
import '../../../controllers/settings_controller.dart';
import '../account_screen/account_screen.dart';
import '../edit_business_profile_screen/edit_business_profile_screen.dart';
import '../notifications_screen/notifications_screen.dart';
import '../permissions_screen/permissions_screen.dart';
import '../privacy_screen/privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.profile,
    required this.onAppearance,
    required this.onSignOut,
    required this.onProfileUpdated,
    this.stories,
  });
  final SettingsController controller;
  final OnboardingController profile;
  final VoidCallback onAppearance;
  final VoidCallback onSignOut;
  final VoidCallback onProfileUpdated;
  final StoriesController? stories;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => AppScaffold(
      appBar: AppHeader(title: const Text(SettingsCopy.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text(SettingsCopy.editProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => EditProfileScreen(
                  profile: profile,
                  settings: controller,
                  onSaved: onProfileUpdated,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text(SettingsCopy.privacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PrivacyScreen(
                  controller: controller,
                  displayName: profile.name.isEmpty
                      ? 'Alex Morgan'
                      : profile.name,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text(SettingsCopy.editBusinessProfile),
            subtitle: Text(
              controller.businessProfile.isComplete
                  ? controller.businessProfile.name
                  : SettingsCopy.completeYourPublicBusinessProfile,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    EditBusinessProfileScreen(controller: controller),
              ),
            ),
          ),
          if (stories != null)
            ListTile(
              leading: const Icon(Icons.public_outlined),
              title: const Text(SettingsCopy.publicBusinessProfile),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => OwnBusinessProfileScreen(
                    settings: controller,
                    stories: stories!,
                  ),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text(SettingsCopy.notifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => NotificationsScreen(controller: controller),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text(SettingsCopy.appearance),
            trailing: const Icon(Icons.chevron_right),
            onTap: onAppearance,
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_setup_outlined),
            title: const Text(SettingsCopy.permissionsAndContactSync),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PermissionsScreen(controller: controller),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text(SettingsCopy.account),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    AccountScreen(profile: profile, onSignOut: onSignOut),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text(SettingsCopy.helpSupport),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(SettingsCopy.aboutWhizpee),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    ),
  );
}
