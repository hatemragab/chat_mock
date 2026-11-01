import 'package:flutter/material.dart';

import '../../../copy/publishing_copy.dart';

enum AudioSourceAction { record, library, remove }

/// Chooses a local audio simulation without changing the draft on dismissal.
class AudioSourceSheet extends StatelessWidget {
  const AudioSourceSheet({super.key, required this.hasAudio});

  final bool hasAudio;

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
              hasAudio ? PublishingCopy.replaceAudio : PublishingCopy.addAudio,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mic_none),
            title: const Text(PublishingCopy.recordAudio),
            subtitle: const Text(PublishingCopy.useASimulatedRecording),
            onTap: () => Navigator.pop(context, AudioSourceAction.record),
          ),
          ListTile(
            leading: const Icon(Icons.library_music_outlined),
            title: const Text(PublishingCopy.importSample),
            subtitle: const Text(PublishingCopy.chooseABundledSample),
            onTap: () => Navigator.pop(context, AudioSourceAction.library),
          ),
          if (hasAudio)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text(PublishingCopy.removeAudio),
              onTap: () => Navigator.pop(context, AudioSourceAction.remove),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
