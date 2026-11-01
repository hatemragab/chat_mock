import 'dart:async';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../actions/mock_media_permissions.dart';
import '../editor_screen/editor_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
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
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool front = false;
  bool captured = false;
  bool recording = false;
  int seconds = 0;
  Timer? timer;

  void capture() {
    if (captured) {
      setState(() {
        captured = false;
        seconds = 0;
      });
    } else if (widget.draft.media == PublicationMedia.video) {
      if (recording) {
        timer?.cancel();
        setState(() {
          recording = false;
          captured = true;
        });
      } else {
        setState(() {
          seconds = 0;
          recording = true;
        });
        timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => seconds++);
        });
      }
    } else {
      setState(() => captured = true);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.capture)),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        captured
                            ? Icons.check_circle_outline
                            : Icons.camera_alt_outlined,
                        size: 64,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        captured
                            ? PublishingCopy.sampleCaptured
                            : recording
                            ? PublishingCopy.recordingVideo(seconds)
                            : PublishingCopy.cameraPreview(front),
                      ),
                      const SizedBox(height: 8),
                      const Text(PublishingCopy.cameraSimulation),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              IconButton(
                onPressed: captured || recording
                    ? null
                    : () => setState(() => front = !front),
                icon: const Icon(Icons.cameraswitch_outlined),
                tooltip: PublishingCopy.switchCamera,
              ),
              FilledButton.icon(
                onPressed: capture,
                icon: Icon(
                  captured
                      ? Icons.replay
                      : recording
                      ? Icons.stop
                      : widget.draft.media == PublicationMedia.video
                      ? Icons.videocam
                      : Icons.camera_alt,
                ),
                label: Text(
                  captured
                      ? PublishingCopy.retake
                      : recording
                      ? PublishingCopy.stopRecording
                      : widget.draft.media == PublicationMedia.video
                      ? PublishingCopy.recordVideo
                      : PublishingCopy.capture,
                ),
              ),
              IconButton(
                onPressed: captured
                    ? () {
                        final sample = PublishingCopy.capturedSample(
                          front,
                          widget.draft.media == PublicationMedia.video,
                          seconds,
                        );
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
                    : null,
                icon: const Icon(Icons.check),
                tooltip: PublishingCopy.useCapture,
              ),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    ),
  );
}
