import 'package:flutter/material.dart';

import '../../../copy/publishing_copy.dart';

import '../../../models/publication.dart';

class SampleMediaPickerSheet extends StatelessWidget {
  const SampleMediaPickerSheet({super.key, required this.media});
  final PublicationMedia media;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              PublishingCopy.chooseMediaType(media.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final sample in [
            'Morning light',
            'City moments',
            'Creative studio',
          ])
            ListTile(
              leading: Icon(
                media == PublicationMedia.photo
                    ? Icons.image_outlined
                    : media == PublicationMedia.video
                    ? Icons.videocam_outlined
                    : Icons.graphic_eq,
              ),
              title: Text(sample),
              onTap: () => Navigator.pop(context, sample),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
