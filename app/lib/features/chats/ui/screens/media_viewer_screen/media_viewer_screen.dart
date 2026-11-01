import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_file_metadata.dart';
import '../../../models/chat_media_samples.dart';
import '../../../models/chat_models.dart';
import '../../widgets/chat_media_visual.dart';

/// Presents only the selected bundled sample. Playback and downloads are local simulations.
class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({
    super.key,
    required this.message,
    this.onShowSource,
  });
  final ChatMessage message;
  final VoidCallback? onShowSource;

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  bool playing = false;
  bool saved = false;
  bool opened = false;
  int elapsedMilliseconds = 0;
  Timer? timer;

  int get durationMilliseconds {
    final base = ChatMediaSamples.durationFor(widget.message).inMilliseconds;
    final edits = widget.message.mediaEdits;
    if (widget.message.kind != MessageKind.video || edits == null) return base;
    final start = edits.trimStart.clamp(0.0, 1.0);
    final end = edits.trimEnd.clamp(start, 1.0);
    return (base * (end - start)).round().clamp(1, base);
  }

  void _togglePlayback() {
    if (playing) {
      timer?.cancel();
      setState(() => playing = false);
      return;
    }
    if (elapsedMilliseconds >= durationMilliseconds) elapsedMilliseconds = 0;
    setState(() => playing = true);
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      final next = elapsedMilliseconds + 250;
      setState(() {
        elapsedMilliseconds = next.clamp(0, durationMilliseconds);
        if (elapsedMilliseconds == durationMilliseconds) {
          playing = false;
          timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    return ChatCopy.duration(seconds);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final document = message.kind == MessageKind.document;
    final file = document
        ? message.fileMetadata ?? ChatFileMetadata.sample(message.text)
        : null;
    final supportedDocument = file?.supportsPreview ?? false;
    final caption = message.mediaEdits?.caption ?? '';
    final playable =
        message.kind == MessageKind.audio || message.kind == MessageKind.video;
    final visual =
        message.assetPath ??
        ChatMediaSamples.assetFor(message.kind, message.text);
    return AppScaffold(
      appBar: AppHeader(
        title: Text(document ? ChatCopy.filePreview : ChatCopy.media),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (visual != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              child: ChatMediaVisual(
                                assetPath: visual,
                                edits: message.mediaEdits,
                                height: 240,
                              ),
                            ),
                          )
                        else
                          Icon(
                            document
                                ? Icons.description_outlined
                                : message.kind == MessageKind.contact
                                ? Icons.person_outline
                                : Icons.audiotrack,
                            size: 96,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        const SizedBox(height: 20),
                        Text(
                          file?.fileName ?? message.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (caption.trim().isNotEmpty) ...[
                          Text(caption, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                        ],
                        if (document) ...[
                          Text(ChatCopy.fileType(file!.mimeType)),
                          Text(ChatCopy.fileSize(file.byteLength)),
                          const SizedBox(height: 12),
                          Text(
                            supportedDocument
                                ? ChatCopy.documentSamplePreview(
                                    file.mimeType == 'application/pdf'
                                        ? 'PDF'
                                        : 'TXT',
                                  )
                                : ChatCopy.unsupportedFilePreview,
                          ),
                          if (supportedDocument)
                            Text(
                              opened
                                  ? ChatCopy.openedInSimulation
                                  : ChatCopy.thisSampleCanBeOpenedInSimulation,
                            ),
                        ] else
                          Text(
                            message.kind == MessageKind.contact
                                ? ChatCopy.sampleContactCard
                                : ChatCopy.localSampleMedia,
                          ),
                        if (playable) ...[
                          const SizedBox(height: 12),
                          Slider(
                            value: elapsedMilliseconds.toDouble(),
                            max: durationMilliseconds.toDouble(),
                            semanticFormatterCallback: (value) =>
                                ChatCopy.playbackPosition(
                                  _formatTime(value.round()),
                                  _formatTime(durationMilliseconds),
                                ),
                            onChanged: (value) => setState(() {
                              elapsedMilliseconds = value.round().clamp(
                                0,
                                durationMilliseconds,
                              );
                              if (elapsedMilliseconds == durationMilliseconds) {
                                playing = false;
                                timer?.cancel();
                              }
                            }),
                          ),
                          Text(
                            ChatCopy.playbackProgress(
                              _formatTime(elapsedMilliseconds),
                              _formatTime(durationMilliseconds),
                            ),
                          ),
                          IconButton(
                            tooltip: playing ? ChatCopy.pause : ChatCopy.play,
                            onPressed: _togglePlayback,
                            icon: Icon(
                              playing ? Icons.pause_circle : Icons.play_circle,
                              size: 48,
                            ),
                          ),
                          Text(
                            playing ? ChatCopy.playingSample : ChatCopy.paused,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.onShowSource != null)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: widget.onShowSource,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text(ChatCopy.showInChat),
                  ),
                ),
              if (document)
                Row(
                  children: [
                    if (supportedDocument)
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => opened = true),
                          child: const Text(ChatCopy.openSample),
                        ),
                      ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => saved = true),
                        icon: const Icon(Icons.download_outlined),
                        label: Text(
                          saved
                              ? ChatCopy.savedInDemo
                              : ChatCopy.downloadSample,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
