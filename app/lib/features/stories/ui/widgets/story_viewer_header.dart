import 'package:flutter/material.dart';

import '../../../../shared/copy/common_copy.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../copy/stories_copy.dart';
import '../../models/story.dart';

/// Identity and playback actions; queue and playback state stay with the viewer.
class StoryViewerHeader extends StatelessWidget {
  const StoryViewerHeader({
    super.key,
    required this.author,
    required this.media,
    required this.blocked,
    required this.paused,
    required this.muted,
    required this.onBack,
    required this.onToggleMuted,
    required this.onTogglePaused,
    this.onOptions,
  });

  final String author;
  final StoryMedia media;
  final bool blocked;
  final bool paused;
  final bool muted;
  final VoidCallback onBack;
  final VoidCallback onToggleMuted;
  final VoidCallback onTogglePaused;
  final VoidCallback? onOptions;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: CommonCopy.back,
      ),
      AppAvatar(
        name: author,
        backgroundColor: Colors.white24,
        textStyle: const TextStyle(color: Colors.white),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              StoriesCopy.today,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      if (!blocked && media != StoryMedia.photo)
        IconButton(
          onPressed: onToggleMuted,
          icon: Icon(
            muted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
          ),
          tooltip: muted ? StoriesCopy.unmute : StoriesCopy.mute,
        ),
      if (!blocked)
        IconButton(
          onPressed: onTogglePaused,
          icon: Icon(
            paused ? Icons.play_arrow : Icons.pause,
            color: Colors.white,
          ),
          tooltip: paused ? StoriesCopy.play : StoriesCopy.pause,
        ),
      if (onOptions != null)
        IconButton(
          onPressed: onOptions,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: StoriesCopy.storyOptions,
        ),
    ],
  );
}
