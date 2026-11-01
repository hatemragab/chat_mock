import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../copy/chats_copy.dart';
import '../../../copy/chat_media_copy.dart';
import '../../../models/chat_attachment_draft.dart';
import '../../../models/chat_media_edits.dart';
import '../../../models/chat_media_samples.dart';
import '../../../models/chat_models.dart';
import '../../widgets/chat_media_visual.dart';

class AttachmentPreviewScreen extends StatefulWidget {
  const AttachmentPreviewScreen({
    super.key,
    required this.kind,
    required this.name,
    this.canSend,
  });
  final MessageKind kind;
  final String name;
  final bool Function()? canSend;

  @override
  State<AttachmentPreviewScreen> createState() =>
      _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  late String name = widget.name;
  final caption = TextEditingController();
  int rotation = 0;
  double cropScale = 1;
  double trimStart = 0;
  double trimEnd = 1;
  bool artworkCover = false;
  bool playing = false;
  double playback = 0;
  bool sendUnavailable = false;
  Timer? timer;

  bool get isVisual =>
      widget.kind == MessageKind.photo || widget.kind == MessageKind.video;
  bool get isVideo => widget.kind == MessageKind.video;
  ChatMediaEdits get edits => ChatMediaEdits(
    caption: caption.text.trim(),
    rotation: rotation,
    cropScale: cropScale,
    trimStart: trimStart,
    trimEnd: trimEnd,
    artworkCover: artworkCover,
  );
  String? get assetPath =>
      ChatMediaSamples.assetFor(widget.kind, name, artworkCover: artworkCover);

  void togglePlayback() {
    timer?.cancel();
    if (playing) {
      setState(() => playing = false);
      return;
    }
    if (playback < trimStart || playback >= trimEnd) playback = trimStart;
    setState(() => playing = true);
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        playback = (playback + 1 / 300).clamp(trimStart, trimEnd);
        if (playback >= trimEnd) {
          playing = false;
          timer?.cancel();
        }
      });
    });
  }

  Future<void> replaceMedia() async {
    timer?.cancel();
    setState(() => playing = false);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text(ChatMediaCopy.chooseSample)),
              for (final sample in ChatMediaSamples.replacementNamesFor(
                widget.kind,
              ))
                ListTile(
                  title: Text(sample),
                  onTap: () => Navigator.pop(context, sample),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted && selected != null) {
      setState(() {
        name = selected;
        playback = trimStart;
      });
    }
  }

  void send() {
    if (!(widget.canSend?.call() ?? true)) {
      setState(() => sendUnavailable = true);
      return;
    }
    Navigator.pop(
      context,
      ChatAttachmentDraft(
        kind: widget.kind,
        name: name,
        assetPath: assetPath,
        mediaEdits: isVisual ? edits : null,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.kind) {
      MessageKind.photo => Icons.photo_outlined,
      MessageKind.video => Icons.videocam_outlined,
      MessageKind.document => Icons.description_outlined,
      MessageKind.audio => Icons.audiotrack,
      MessageKind.contact => Icons.person_outline,
      _ => Icons.attachment,
    };
    return AppScaffold(
      appBar: AppHeader(title: const Text(ChatCopy.previewAttachment)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isVisual
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        ChatMediaVisual(assetPath: assetPath!, edits: edits),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: caption,
                          maxLength: 250,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: ChatMediaCopy.caption,
                            hintText: ChatMediaCopy.addCaption,
                          ),
                        ),
                        if (!isVideo) ...[
                          OutlinedButton.icon(
                            onPressed: () =>
                                setState(() => rotation = (rotation + 1) % 4),
                            icon: const Icon(Icons.rotate_right),
                            label: Text(ChatMediaCopy.rotate(rotation * 90)),
                          ),
                          Text(
                            ChatMediaCopy.cropZoom((cropScale * 100).round()),
                          ),
                          Slider(
                            value: cropScale,
                            min: 1,
                            max: 2,
                            divisions: 10,
                            onChanged: (value) =>
                                setState(() => cropScale = value),
                          ),
                        ] else ...[
                          Text(
                            ChatMediaCopy.trim(
                              (trimStart * 100).round(),
                              (trimEnd * 100).round(),
                            ),
                          ),
                          RangeSlider(
                            values: RangeValues(trimStart, trimEnd),
                            divisions: 20,
                            onChanged: (range) {
                              if (range.end - range.start < .049) return;
                              timer?.cancel();
                              setState(() {
                                trimStart = range.start;
                                trimEnd = range.end;
                                playback = playback.clamp(trimStart, trimEnd);
                                playing = false;
                              });
                            },
                          ),
                          LinearProgressIndicator(value: playback),
                          Text(
                            ChatCopy.playbackProgress(
                              ChatCopy.duration((playback * 30).round()),
                              ChatCopy.duration((trimEnd * 30).round()),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: togglePlayback,
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(
                              playing ? ChatCopy.pause : ChatCopy.play,
                            ),
                          ),
                        ],
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(ChatMediaCopy.cover),
                          subtitle: Text(
                            artworkCover
                                ? ChatMediaCopy.artworkCover
                                : ChatMediaCopy.originalCover,
                          ),
                          trailing: TextButton(
                            onPressed: () =>
                                setState(() => artworkCover = !artworkCover),
                            child: const Text(ChatMediaCopy.changeCover),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: replaceMedia,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text(ChatMediaCopy.replaceMedia),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            ChatCopy.sampleContentForThisDemonstration,
                          ),
                        ],
                      ),
                    ),
            ),
            if (sendUnavailable)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  ChatMediaCopy.unavailable,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: send,
                  icon: const Icon(Icons.send),
                  label: const Text(ChatCopy.sendAttachment),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
