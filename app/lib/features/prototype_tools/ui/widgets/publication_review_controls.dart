import 'package:flutter/material.dart';

import '../../copy/prototype_tools_copy.dart';

import '../../../publishing/controllers/publishing_controller.dart';
import '../../../publishing/models/publication.dart';
import '../../../publishing/ui/screens/analytics_screen/analytics_screen.dart';
import '../../../publishing/ui/screens/story_viewers_screen/story_viewers_screen.dart';

class PublicationReviewControls extends StatefulWidget {
  const PublicationReviewControls({super.key, required this.publishing});
  final PublishingController publishing;

  @override
  State<PublicationReviewControls> createState() =>
      _PublicationReviewControlsState();
}

class _PublicationReviewControlsState extends State<PublicationReviewControls> {
  String? selectedId;

  String _nextId(Publication publication, String prefix) {
    var index = 1;
    while (publication.countedViewers.contains('$prefix-$index')) {
      index++;
    }
    return '$prefix-$index';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.publishing;
    final publications = controller.publications;
    if (publications.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PrototypeToolsCopy.publicationViews,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(PrototypeToolsCopy.noPublicationDescription),
        ],
      );
    }
    final selected =
        publications.where((item) => item.id == selectedId).firstOrNull ??
        publications.first;
    final active = selected.status == PublicationStatus.active;
    final promoted =
        selected.boosted || selected.type == PublicationType.advertisement;
    const contacts = {
      'sarah': 'Sarah Wilson',
      'amira': 'Amira Hassan',
      'john': 'John Davis',
      'karim': 'Karim Diallo',
      'maya': 'Maya Chen',
      'leo': 'Leo Martin',
    };
    final nextContact = contacts.entries
        .where(
          (contact) =>
              !selected.countedViewers.contains(contact.key) &&
              (controller.canShareStatusWith?.call(contact.key) ?? true),
        )
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          PrototypeToolsCopy.publicationViews,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('review-publication-${selected.id}'),
          initialValue: selected.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: PrototypeToolsCopy.publication,
          ),
          items: publications
              .map(
                (item) => DropdownMenuItem(
                  value: item.id,
                  child: Text(
                    PrototypeToolsCopy.publicationSummary(
                      item.category,
                      item.sample,
                      item.status.name,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => selectedId = value),
        ),
        const SizedBox(height: 8),
        Text(
          PrototypeToolsCopy.viewCounts(
            selected.qualifiedViews,
            selected.heldViews,
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: active && (promoted || nextContact != null)
                  ? () {
                      final id = promoted
                          ? _nextId(selected, 'review-contact')
                          : nextContact!.key;
                      controller.recordView(
                        selected,
                        viewerId: id,
                        viewerName: promoted
                            ? PrototypeToolsCopy.demoViewer(id.split('-').last)
                            : nextContact!.value,
                      );
                    }
                  : null,
              child: const Text(PrototypeToolsCopy.addContactView),
            ),
            OutlinedButton(
              onPressed: active && (promoted || nextContact != null)
                  ? () {
                      final id = promoted
                          ? _nextId(selected, 'review-held')
                          : nextContact!.key;
                      controller.recordView(
                        selected,
                        viewerId: id,
                        viewerName: 'Held view',
                        suspicious: true,
                      );
                    }
                  : null,
              child: const Text(PrototypeToolsCopy.addHeldView),
            ),
            if (promoted)
              OutlinedButton(
                onPressed:
                    active &&
                        selected.qualifiedViews <
                            controller.config.popularThreshold
                    ? () {
                        final needed =
                            controller.config.popularThreshold -
                            selected.qualifiedViews;
                        for (var i = 0; i < needed; i++) {
                          final id = _nextId(selected, 'review-popular');
                          controller.recordView(
                            selected,
                            viewerId: id,
                            viewerName: PrototypeToolsCopy.demoViewer(
                              id.split('-').last,
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text(PrototypeToolsCopy.reachPopularThreshold),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => promoted
                  ? AnalyticsScreen(
                      controller: controller,
                      publication: selected,
                    )
                  : StoryViewersScreen(
                      controller: controller,
                      publication: selected,
                    ),
            ),
          ),
          icon: const Icon(Icons.insights_outlined),
          label: Text(
            promoted
                ? PrototypeToolsCopy.openAggregateAnalytics
                : PrototypeToolsCopy.openContactViewers,
          ),
        ),
      ],
    );
  }
}
