import '../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../controllers/settings_controller.dart';

enum _Viewer { contact, other, blocked }

/// Shows the private profile information available to different viewers.
class PhotoVisibilityPreview extends StatefulWidget {
  const PhotoVisibilityPreview({
    super.key,
    required this.controller,
    this.displayName = 'Alex Morgan',
  });
  final SettingsController controller;
  final String displayName;

  @override
  State<PhotoVisibilityPreview> createState() => _PhotoVisibilityPreviewState();
}

class _PhotoVisibilityPreviewState extends State<PhotoVisibilityPreview> {
  _Viewer viewer = _Viewer.contact;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final presentation = widget.controller.privateProfileFor(
        displayName: widget.displayName,
        isContact: viewer == _Viewer.contact,
        blocked: viewer == _Viewer.blocked,
      );
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(SettingsCopy.previewYourProfileAs),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final option in [
                  (_Viewer.contact, SettingsCopy.contact),
                  (_Viewer.other, SettingsCopy.otherPerson),
                  (_Viewer.blocked, SettingsCopy.blocked),
                ])
                  ChoiceChip(
                    label: Text(option.$2),
                    selected: viewer == option.$1,
                    onSelected: (_) => setState(() => viewer = option.$1),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: presentation.photoVisible
                    ? Text(
                        presentation.displayName.isEmpty
                            ? '?'
                            : presentation.displayName.substring(0, 1),
                        key: const ValueKey('visible-private-photo'),
                      )
                    : const Icon(
                        Icons.person_outline,
                        key: ValueKey('hidden-private-photo'),
                      ),
              ),
              title: Text(presentation.displayName),
              subtitle: Text(
                presentation.photoVisible
                    ? SettingsCopy.profilePhotoVisible
                    : SettingsCopy.profilePhotoHidden,
              ),
            ),
          ],
        ),
      );
    },
  );
}
