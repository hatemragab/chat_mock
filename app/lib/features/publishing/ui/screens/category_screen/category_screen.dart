import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../copy/publishing_copy.dart';
import '../../../models/publication.dart';
import '../media_screen/media_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.settings,
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final SettingsController? settings;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.chooseACategory)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(PublishingCopy.categoryDescription),
        const SizedBox(height: 16),
        for (final item in [
          (
            'Everyday',
            Icons.wb_sunny_outlined,
            false,
            PublishingCopy.everydayCategoryDescription,
          ),
          (
            'Lifestyle',
            Icons.favorite_outline,
            false,
            PublishingCopy.lifestyleCategoryDescription,
          ),
          (
            'Design',
            Icons.palette_outlined,
            true,
            PublishingCopy.designCategoryDescription,
          ),
          (
            'Business',
            Icons.storefront_outlined,
            true,
            PublishingCopy.businessCategoryDescription,
          ),
        ])
          Card(
            child: ListTile(
              leading: Icon(item.$2),
              title: Text(PublishingCopy.categoryLabel(item.$1)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$4),
                  const SizedBox(height: 4),
                  Text(
                    item.$3
                        ? PublishingCopy.categoryFee(
                            controller.config.categoryFee,
                          )
                        : PublishingCopy.freeCategory,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                draft.category = item.$1;
                draft.paidCategory = item.$3;
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => MediaScreen(
                      controller: controller,
                      draft: draft,
                      settings: settings,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
