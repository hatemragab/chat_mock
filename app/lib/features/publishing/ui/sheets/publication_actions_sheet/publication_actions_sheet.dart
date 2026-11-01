import 'package:flutter/material.dart';

import '../../../copy/publishing_copy.dart';

import '../../../models/publication.dart';

enum PublicationAction {
  open,
  details,
  viewers,
  analytics,
  contactActivity,
  delete,
}

/// Actions are returned to the owner, which applies them to the current item.
class PublicationActionsSheet extends StatelessWidget {
  const PublicationActionsSheet({
    super.key,
    required this.publication,
    this.hasContactActivity = false,
  });

  final Publication publication;
  final bool hasContactActivity;

  @override
  Widget build(BuildContext context) {
    final promoted =
        publication.boosted ||
        publication.type == PublicationType.advertisement;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                publication.caption.isEmpty
                    ? publication.sample
                    : publication.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text(PublishingCopy.openStory),
              onTap: () => Navigator.pop(context, PublicationAction.open),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(PublishingCopy.details),
              onTap: () => Navigator.pop(context, PublicationAction.details),
            ),
            if (!promoted && publication.type == PublicationType.status)
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text(PublishingCopy.storyViewers),
                onTap: () => Navigator.pop(context, PublicationAction.viewers),
              ),
            if (promoted)
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text(PublishingCopy.promotionAnalytics),
                onTap: () =>
                    Navigator.pop(context, PublicationAction.analytics),
              ),
            if (promoted && hasContactActivity)
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text(PublishingCopy.contactActivity),
                onTap: () =>
                    Navigator.pop(context, PublicationAction.contactActivity),
              ),
            if (publication.status == PublicationStatus.active)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text(PublishingCopy.deletePublication),
                onTap: () => Navigator.pop(context, PublicationAction.delete),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
