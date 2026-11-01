import '../../../copy/onboarding_copy.dart';

import 'package:flutter/material.dart';

class ProfilePhotoLibrarySheet extends StatelessWidget {
  const ProfilePhotoLibrarySheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              OnboardingCopy.chooseAPhoto,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final sample in [
            OnboardingCopy.studioPortrait,
            OnboardingCopy.outdoorPortrait,
          ])
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(sample),
              onTap: () => Navigator.pop(context, sample),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
