import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../actions/publication_actions.dart';
import '../publication_details_screen/publication_details_screen.dart';
import '../publishing_screen/publishing_screen.dart';

enum _PublicationFilter { all, statuses, advertisements }

class PublicationsScreen extends StatefulWidget {
  const PublicationsScreen({
    super.key,
    required this.controller,
    this.settings,
  });
  final PublishingController controller;
  final SettingsController? settings;
  @override
  State<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
  _PublicationFilter filter = _PublicationFilter.all;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.myPublications)),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final items = widget.controller.publications
            .where(
              (p) => switch (filter) {
                _PublicationFilter.all => true,
                _PublicationFilter.statuses => p.type == PublicationType.status,
                _PublicationFilter.advertisements =>
                  p.type == PublicationType.advertisement,
              },
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PublishingScreen(
                    controller: widget.controller,
                    settings: widget.settings,
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(PublishingCopy.createPublication),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _PublicationFilter.values
                  .map(
                    (v) => ChoiceChip(
                      label: Text(switch (v) {
                        _PublicationFilter.all => CommonCopy.all,
                        _PublicationFilter.statuses => PublishingCopy.statuses,
                        _PublicationFilter.advertisements =>
                          PublishingCopy.advertisements,
                      }),
                      selected: filter == v,
                      onSelected: (_) => setState(() => filter = v),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(PublishingCopy.noPublicationsInThisViewYet),
                ),
              ),
            ...items.map(
              (p) => Card(
                child: ListTile(
                  leading: Icon(
                    p.media == PublicationMedia.photo
                        ? Icons.image_outlined
                        : p.media == PublicationMedia.video
                        ? Icons.videocam_outlined
                        : Icons.graphic_eq,
                  ),
                  title: Text(
                    p.caption.isEmpty ? p.sample : p.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    PublishingCopy.publicationState(p.type.name, p.status.name),
                  ),
                  trailing: IconButton(
                    tooltip: PublishingCopy.publicationOptions,
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => showPublicationActions(
                      context,
                      controller: widget.controller,
                      publication: p,
                      settings: widget.settings,
                    ),
                  ),
                  onLongPress: () => showPublicationActions(
                    context,
                    controller: widget.controller,
                    publication: p,
                    settings: widget.settings,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PublicationDetailsScreen(
                        controller: widget.controller,
                        publication: p,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
