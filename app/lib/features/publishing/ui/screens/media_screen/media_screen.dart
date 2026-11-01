import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../actions/mock_media_permissions.dart';
import '../audio_recorder_screen/audio_recorder_screen.dart';
import '../capture_screen/capture_screen.dart';
import '../editor_screen/editor_screen.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.settings,
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final SettingsController? settings;
  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late final permissions = MockMediaPermissions(settings: widget.settings);

  Future<void> _importMedia() async {
    if (!await permissions.request(context, 'Media') || !mounted) return;
    final sample = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(PublishingCopy.simulatedImport),
                subtitle: Text(PublishingCopy.mockImportDescription),
              ),
              for (final name in [
                'Morning light',
                'City moments',
                'Creative studio',
              ])
                ListTile(
                  leading: const Icon(Icons.collections_outlined),
                  title: Text(name),
                  onTap: () => Navigator.pop(context, name),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || sample == null) return;
    widget.draft.sample = sample;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EditorScreen(
          controller: widget.controller,
          draft: widget.draft,
          permissions: permissions,
        ),
      ),
    );
  }

  Future<void> _captureOrRecord() async {
    final audio = widget.draft.media == PublicationMedia.audio;
    if (!await permissions.request(context, audio ? 'Microphone' : 'Camera') ||
        !mounted) {
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => audio
            ? AudioRecorderScreen(
                controller: widget.controller,
                draft: widget.draft,
                permissions: permissions,
              )
            : CaptureScreen(
                controller: widget.controller,
                draft: widget.draft,
                permissions: permissions,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.chooseMedia)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SegmentedButton<PublicationMedia>(
          segments: const [
            ButtonSegment(
              value: PublicationMedia.photo,
              label: Text(PublishingCopy.photo),
              icon: Icon(Icons.image_outlined),
            ),
            ButtonSegment(
              value: PublicationMedia.video,
              label: Text(PublishingCopy.video),
              icon: Icon(Icons.videocam_outlined),
            ),
            ButtonSegment(
              value: PublicationMedia.audio,
              label: Text(PublishingCopy.audio),
              icon: Icon(Icons.graphic_eq),
            ),
          ],
          selected: {widget.draft.media},
          onSelectionChanged: (value) =>
              setState(() => widget.draft.media = value.first),
        ),
        const SizedBox(height: 18),
        Text(
          PublishingCopy.chooseASample,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final sample in [
          'Morning light',
          'City moments',
          'Creative studio',
        ])
          Card(
            child: ListTile(
              leading: const Icon(Icons.collections_outlined),
              title: Text(sample),
              subtitle: Text(
                PublishingCopy.mediaLabel(widget.draft.media.name),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                widget.draft.sample = sample;
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => EditorScreen(
                      controller: widget.controller,
                      draft: widget.draft,
                      permissions: permissions,
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _importMedia,
          icon: const Icon(Icons.file_upload_outlined),
          label: const Text(PublishingCopy.importMedia),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _captureOrRecord,
          icon: Icon(
            widget.draft.media == PublicationMedia.audio
                ? Icons.mic_none
                : Icons.camera_alt_outlined,
          ),
          label: Text(
            widget.draft.media == PublicationMedia.audio
                ? PublishingCopy.recordAudio
                : PublishingCopy.captureSample,
          ),
        ),
        if (widget.draft.media != PublicationMedia.photo)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(PublishingCopy.mandatoryBoostDescription),
          ),
      ],
    ),
  );
}
