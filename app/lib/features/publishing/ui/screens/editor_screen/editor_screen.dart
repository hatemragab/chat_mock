import 'dart:async';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../onboarding/ui/sheets/photo_source_sheet/photo_source_sheet.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../../stories/models/publication_story.dart';
import '../../../../stories/ui/widgets/story_media_background.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../actions/mock_media_permissions.dart';
import '../../sheets/audio_source_sheet/audio_source_sheet.dart';
import '../../sheets/boost_options_sheet/boost_options_sheet.dart';
import '../../sheets/sample_media_picker_sheet/sample_media_picker_sheet.dart';
import '../audio_recorder_screen/audio_recorder_screen.dart';
import '../audience_screen/audience_screen.dart';
import '../capture_screen/capture_screen.dart';
import '../price_review_screen/price_review_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.settings,
    this.permissions,
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final SettingsController? settings;
  final MockMediaPermissions? permissions;
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Timer? playbackTimer;
  bool playing = false;
  double playback = 0;
  late final MockMediaPermissions? permissions =
      widget.permissions ??
      (widget.settings == null
          ? null
          : MockMediaPermissions(settings: widget.settings));

  Future<void> chooseMedia() async {
    if (widget.draft.media == PublicationMedia.audio) {
      final action = await showModalBottomSheet<AudioSourceAction>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) =>
            AudioSourceSheet(hasAudio: widget.draft.sample.isNotEmpty),
      );
      if (!mounted || action == null) return;
      if (action == AudioSourceAction.remove) {
        _replaceSample('');
        return;
      }
      if (action == AudioSourceAction.record &&
          permissions != null &&
          !await permissions!.request(context, 'Microphone')) {
        return;
      }
      if (!mounted) return;
      final sample = action == AudioSourceAction.record
          ? await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => AudioRecorderScreen(
                  controller: widget.controller,
                  draft: widget.draft,
                  returnSelection: true,
                  permissions: permissions,
                ),
              ),
            )
          : await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) =>
                  const SampleMediaPickerSheet(media: PublicationMedia.audio),
            );
      if (mounted && sample != null) _replaceSample(sample);
      return;
    }
    final action = await showModalBottomSheet<PhotoSourceAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PhotoSourceSheet(
        hasPhoto: widget.draft.sample.isNotEmpty,
        label: widget.draft.media.name,
      ),
    );
    if (!mounted || action == null) return;
    if (action == PhotoSourceAction.remove) {
      _replaceSample('');
      return;
    }
    final String? sample;
    if (action == PhotoSourceAction.camera) {
      if (permissions != null &&
          !await permissions!.request(context, 'Camera')) {
        return;
      }
      if (!mounted) return;
      sample = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => CaptureScreen(
            controller: widget.controller,
            draft: widget.draft,
            returnSelection: true,
            permissions: permissions,
          ),
        ),
      );
    } else {
      sample = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => SampleMediaPickerSheet(media: widget.draft.media),
      );
    }
    final selected = sample;
    if (mounted && selected != null) _replaceSample(selected);
  }

  void _replaceSample(String value) {
    playbackTimer?.cancel();
    setState(() {
      widget.draft.sample = value;
      playing = false;
      playback = 0;
    });
  }

  late final TextEditingController caption = TextEditingController(
    text: widget.draft.caption,
  );
  @override
  void dispose() {
    playbackTimer?.cancel();
    caption.dispose();
    super.dispose();
  }

  void togglePlayback() {
    if (playing) {
      playbackTimer?.cancel();
      setState(() => playing = false);
      return;
    }
    final draft = widget.draft;
    if (playback < draft.trimStart || playback >= draft.trimEnd) {
      playback = draft.trimStart;
    }
    setState(() => playing = true);
    playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {
        playback = (playback + .02).clamp(draft.trimStart, draft.trimEnd);
        if (playback >= draft.trimEnd) {
          playing = false;
          playbackTimer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return AppScaffold(
      appBar: AppHeader(
        title: Text(PublishingCopy.editorTitle(draft.media.name)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF87B9AA), Color(0xFF355F53)],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (draft.sample.isNotEmpty)
                  Positioned.fill(
                    child: StoryMediaBackground(
                      story: storyForDraft(draft),
                      dim: .45,
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        draft.media == PublicationMedia.photo
                            ? Icons.image_outlined
                            : draft.media == PublicationMedia.video
                            ? Icons.play_circle_outline
                            : Icons.graphic_eq,
                        size: 58,
                        color: Colors.white,
                      ),
                      Text(
                        draft.sample.isEmpty
                            ? PublishingCopy.noMediaSelected
                            : PublishingCopy.sampleCover(
                                draft.sample,
                                draft.cover,
                              ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (draft.caption.isNotEmpty)
                        Text(
                          draft.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: IconButton.filledTonal(
                    onPressed: chooseMedia,
                    tooltip: draft.sample.isEmpty
                        ? PublishingCopy.chooseMedia
                        : PublishingCopy.replaceOrRemoveMedia,
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: caption,
            maxLength: 250,
            maxLines: 2,
            onChanged: (value) => setState(() => draft.caption = value),
            decoration: const InputDecoration(
              labelText: PublishingCopy.caption,
              hintText: PublishingCopy.addACaption,
            ),
          ),
          if (draft.media == PublicationMedia.photo) ...[
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => draft.rotation = (draft.rotation + 1) % 4),
              icon: const Icon(Icons.rotate_right),
              label: Text(PublishingCopy.rotate(draft.rotation * 90)),
            ),
            Text(PublishingCopy.cropZoom((draft.cropScale * 100).round())),
            Slider(
              value: draft.cropScale,
              min: 1,
              max: 2,
              divisions: 10,
              onChanged: (value) => setState(() => draft.cropScale = value),
            ),
          ],
          if (draft.media == PublicationMedia.video) ...[
            Text(
              PublishingCopy.trim(
                (draft.trimStart * 100).round(),
                (draft.trimEnd * 100).round(),
              ),
            ),
            RangeSlider(
              values: RangeValues(draft.trimStart, draft.trimEnd),
              onChanged: (range) => setState(() {
                draft.trimStart = range.start;
                draft.trimEnd = range.end;
                playback = playback.clamp(range.start, range.end);
              }),
            ),
          ],
          if (draft.media != PublicationMedia.photo) ...[
            LinearProgressIndicator(value: playback),
            OutlinedButton.icon(
              onPressed: draft.sample.isEmpty ? null : togglePlayback,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              label: Text(
                playing
                    ? PublishingCopy.pausePreview
                    : PublishingCopy.playPreview,
              ),
            ),
          ],
          ListTile(
            title: const Text(PublishingCopy.cover),
            subtitle: Text(PublishingCopy.coverLabel(draft.cover)),
            trailing: TextButton(
              onPressed: () => setState(
                () => draft.cover = draft.cover == 'Default'
                    ? 'Artwork'
                    : 'Default',
              ),
              child: const Text(PublishingCopy.change),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(PublishingCopy.boost),
            subtitle: Text(
              draft.requiresBoost
                  ? PublishingCopy.requiredBoost(
                      widget.controller.config.boostFee,
                    )
                  : PublishingCopy.optionalBoost(
                      widget.controller.config.boostFee,
                    ),
            ),
            trailing: Text(
              draft.effectiveBoost ? PublishingCopy.on : PublishingCopy.off,
            ),
            onTap: () async {
              final selected = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => BoostOptionsSheet(
                  draft: draft,
                  fee: widget.controller.config.boostFee,
                ),
              );
              if (mounted && selected != null) {
                setState(() => draft.boosted = selected);
              }
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: draft.sample.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          draft.type == PublicationType.advertisement
                          ? AudienceScreen(
                              controller: widget.controller,
                              draft: draft,
                            )
                          : PriceReviewScreen(
                              controller: widget.controller,
                              draft: draft,
                            ),
                    ),
                  ),
            child: const Text(CommonCopy.continueLabel),
          ),
        ],
      ),
    );
  }
}
