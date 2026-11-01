import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../category_screen/category_screen.dart';
import '../publications_screen/publications_screen.dart';

class PublishingScreen extends StatelessWidget {
  const PublishingScreen({super.key, required this.controller, this.settings});
  final PublishingController controller;
  final SettingsController? settings;
  @override
  Widget build(BuildContext context) {
    void start(PublicationType type) => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CategoryScreen(
          controller: controller,
          draft: controller.createDraft(type),
          settings: settings,
        ),
      ),
    );
    return AppScaffold(
      appBar: AppHeader(title: const Text(PublishingCopy.publishing)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            PublishingCopy.shareWhatMatters,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(PublishingCopy.publishingDescription),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text(PublishingCopy.createStatus),
              subtitle: const Text(
                PublishingCopy.shareAPhotoVideoOrAudioUpdate,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => start(PublicationType.status),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text(PublishingCopy.createAdvertisement),
              subtitle: const Text(PublishingCopy.reachAnAudienceYouChoose),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => start(PublicationType.advertisement),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: const Text(PublishingCopy.myPublications),
              subtitle: const Text(PublishingCopy.manageYourPostsAndInsights),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PublicationsScreen(
                    controller: controller,
                    settings: settings,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
