import 'dart:async';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../actions/mock_media_permissions.dart';
import '../../sheets/sample_media_picker_sheet/sample_media_picker_sheet.dart';
import '../editor_screen/editor_screen.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.returnSelection = false,
    this.settings,
    this.permissions,
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final bool returnSelection;
  final SettingsController? settings;
  final MockMediaPermissions? permissions;
  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  Timer? timer;
  Timer? playbackTimer;
  int seconds = 0;
  bool recording = false;
  bool stopped = false;
  bool playing = false;
  double playbackSeconds = 0;
  void toggleRecording() {
    if (recording) {
      timer?.cancel();
      setState(() => recording = false);
      return;
    }
    setState(() {
      recording = true;
      stopped = false;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  void stop() {
    timer?.cancel();
    setState(() {
      recording = false;
      stopped = true;
      playing = false;
      playbackSeconds = 0;
    });
  }

  void togglePlayback() {
    if (playing) {
      playbackTimer?.cancel();
      setState(() => playing = false);
      return;
    }
    if (playbackSeconds >= seconds) playbackSeconds = 0;
    setState(() => playing = true);
    playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {
        playbackSeconds = (playbackSeconds + .2).clamp(0, seconds.toDouble());
        if (playbackSeconds >= seconds) {
          playbackTimer?.cancel();
          playing = false;
        }
      });
    });
  }

  void useSample(String sample) {
    timer?.cancel();
    playbackTimer?.cancel();
    setState(() {
      recording = false;
      playing = false;
    });
    if (widget.returnSelection) {
      Navigator.pop(context, sample);
      return;
    }
    widget.draft.sample = sample;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EditorScreen(
          controller: widget.controller,
          draft: widget.draft,
          settings: widget.settings,
          permissions: widget.permissions,
        ),
      ),
    );
  }

  Future<void> importSample() async {
    final sample = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) =>
          const SampleMediaPickerSheet(media: PublicationMedia.audio),
    );
    if (mounted && sample != null) useSample(sample);
  }

  @override
  void dispose() {
    timer?.cancel();
    playbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.recordAudio)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.graphic_eq,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        Center(
          child: Text(
            PublishingCopy.recordingTime(seconds),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            recording
                ? PublishingCopy.recordingSample
                : stopped
                ? PublishingCopy.recordingReady
                : PublishingCopy.noMicrophoneIsUsedInThisDemo,
          ),
        ),
        const SizedBox(height: 30),
        if (!stopped)
          FilledButton.icon(
            onPressed: toggleRecording,
            icon: Icon(recording ? Icons.pause : Icons.mic),
            label: Text(
              recording
                  ? PublishingCopy.pause
                  : seconds == 0
                  ? PublishingCopy.record
                  : PublishingCopy.resume,
            ),
          ),
        if (seconds > 0 && !stopped)
          OutlinedButton(
            onPressed: stop,
            child: const Text(PublishingCopy.stop),
          ),
        if (stopped) ...[
          LinearProgressIndicator(
            value: seconds == 0 ? 0 : playbackSeconds / seconds,
          ),
          const SizedBox(height: 8),
          Text(PublishingCopy.playbackProgress(playbackSeconds, seconds)),
          OutlinedButton.icon(
            onPressed: togglePlayback,
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
            label: Text(
              playing
                  ? PublishingCopy.pausePlayback
                  : PublishingCopy.playSample,
            ),
          ),
          TextButton(
            onPressed: () {
              playbackTimer?.cancel();
              setState(() {
                seconds = 0;
                stopped = false;
                playing = false;
                playbackSeconds = 0;
              });
            },
            child: const Text(PublishingCopy.reRecord),
          ),
          FilledButton(
            onPressed: () => useSample(PublishingCopy.audioRecording(seconds)),
            child: const Text(PublishingCopy.useRecording),
          ),
        ],
        TextButton.icon(
          onPressed: recording ? null : importSample,
          icon: const Icon(Icons.library_music_outlined),
          label: const Text(PublishingCopy.importSample),
        ),
      ],
    ),
  );
}
