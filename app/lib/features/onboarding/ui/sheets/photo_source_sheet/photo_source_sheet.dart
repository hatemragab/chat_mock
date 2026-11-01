import '../../../copy/onboarding_copy.dart';

import 'package:flutter/material.dart';

enum PhotoSourceAction { camera, library, remove }

/// Selects a simulated source; dismissing the sheet leaves the draft unchanged.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({
    super.key,
    required this.hasPhoto,
    this.label = OnboardingCopy.photo,
  });

  final bool hasPhoto;
  final String label;

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
              hasPhoto
                  ? OnboardingCopy.replaceMedia(label)
                  : OnboardingCopy.addMedia(label),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text(OnboardingCopy.camera),
            subtitle: const Text(OnboardingCopy.useASimulatedCapture),
            onTap: () => Navigator.pop(context, PhotoSourceAction.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text(OnboardingCopy.libraryLabel),
            subtitle: const Text(OnboardingCopy.chooseABundledSample),
            onTap: () => Navigator.pop(context, PhotoSourceAction.library),
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(OnboardingCopy.removeMedia(label)),
              onTap: () => Navigator.pop(context, PhotoSourceAction.remove),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
