import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_section_heading.dart';
import '../../../../creator_tools/ui/screens/promotion_contact_activity_screen/promotion_contact_activity_screen.dart';
import '../../../../stories/models/publication_story.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../copy/publishing_copy.dart';
import '../../../models/publication.dart';
import '../../dialogs/delete_publication_dialog/delete_publication_dialog.dart';
import '../../widgets/publication_price_breakdown.dart';
import '../analytics_screen/analytics_screen.dart';
import '../story_viewers_screen/story_viewers_screen.dart';

class PublicationDetailsScreen extends StatelessWidget {
  const PublicationDetailsScreen({
    super.key,
    required this.controller,
    required this.publication,
  });
  final PublishingController controller;
  final Publication publication;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.publicationDetails)),
    body: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StoryCover(
            story: storyForPublication(
              publication,
              author: controller.currentAuthorName,
            ),
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            publication.caption.isEmpty
                ? publication.sample
                : publication.caption,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            PublishingCopy.publicationSummary(
              publication.type.name,
              publication.category,
              publication.status.name,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            publication.media == PublicationMedia.photo
                ? PublishingCopy.photoEdits(
                    publication.sample,
                    (publication.cropScale * 100).round(),
                    publication.rotation * 90,
                  )
                : PublishingCopy.mediaEdits(
                    publication.sample,
                    publication.cover,
                    (publication.trimStart * 100).round(),
                    (publication.trimEnd * 100).round(),
                  ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const AppSectionHeading(
            title: PublishingCopy.originalPublicationTerms,
          ),
          PublicationPriceBreakdown(
            price: publication.price,
            totalLabel: PublishingCopy.originalTotal,
          ),
          Text(PublishingCopy.lifetime(publication.boosted ? 48 : 24)),
          if (publication.extended) const Text(PublishingCopy.extensionUsed),
          if (publication.type == PublicationType.advertisement)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(PublishingCopy.audience),
              subtitle: Text(
                PublishingCopy.audienceDetails(
                  publication.location,
                  publication.radiusKm.round(),
                  publication.gender,
                  publication.interest,
                ),
              ),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(PublishingCopy.published),
            trailing: Text(
              PublishingCopy.publicationDate(publication.createdAt),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(PublishingCopy.ends),
            trailing: Text(
              PublishingCopy.publicationDate(publication.expiresAt),
            ),
          ),
          if (publication.boosted ||
              publication.type == PublicationType.advertisement)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insights),
              title: const Text(PublishingCopy.promotionAnalytics),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AnalyticsScreen(
                    controller: controller,
                    publication: publication,
                  ),
                ),
              ),
            ),
          if ((publication.boosted ||
                  publication.type == PublicationType.advertisement) &&
              controller.contactActivity != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.forum_outlined),
              title: const Text(PublishingCopy.contactActivity),
              subtitle: const Text(
                PublishingCopy.conversationsAndCallsFromThisStory,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PromotionContactActivityScreen(
                    controller: controller.contactActivity!,
                    publication: publication,
                  ),
                ),
              ),
            ),
          if (!publication.boosted &&
              publication.type == PublicationType.status)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.visibility_outlined),
              title: const Text(PublishingCopy.storyViewers),
              subtitle: Text(
                PublishingCopy.contactViews(publication.contactViewers.length),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => StoryViewersScreen(
                    controller: controller,
                    publication: publication,
                  ),
                ),
              ),
            ),
          if (publication.status == PublicationStatus.active &&
              !publication.extended)
            OutlinedButton(
              onPressed: () {
                if (!controller.extend(publication)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        PublishingCopy.thisPublicationCannotBeExtended,
                      ),
                    ),
                  );
                }
              },
              child: const Text(PublishingCopy.extendBy24Hours),
            ),
          if (publication.status == PublicationStatus.active)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) =>
                      DeletePublicationDialog(publication: publication),
                );
                if (confirmed == true) controller.remove(publication);
              },
              child: const Text(PublishingCopy.deletePublication),
            ),
        ],
      ),
    ),
  );
}
