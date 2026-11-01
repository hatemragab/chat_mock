import 'package:flutter/material.dart';

import '../../copy/stories_copy.dart';

import '../../models/story.dart';
import 'story_media_background.dart';

class StoryCover extends StatelessWidget {
  const StoryCover({
    super.key,
    required this.story,
    this.height = 210,
    this.onTap,
    this.seen,
  });
  final Story story;
  final double height;
  final VoidCallback? onTap;

  /// Status previews distinguish new updates from those already viewed.
  final bool? seen;

  @override
  Widget build(BuildContext context) {
    final tag = story.sponsored
        ? StoriesCopy.sponsored
        : story.popular
        ? StoriesCopy.popular
        : story.boosted
        ? StoriesCopy.boosted
        : '';
    return Semantics(
      button: onTap != null,
      label: StoriesCopy.coverSemantics(story.author, story.title, seen),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: story.colors,
            ),
          ),
          child: Stack(
            children: [
              if (story.assetPath != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        StoryMediaBackground(story: story, dim: .12),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black12,
                                Colors.transparent,
                                Colors.black87,
                              ],
                              stops: [0, .45, 1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: -25,
                top: 15,
                child: Icon(
                  story.media == StoryMedia.audio
                      ? Icons.graphic_eq_rounded
                      : story.media == StoryMedia.video
                      ? Icons.play_circle_outline_rounded
                      : Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: .14),
                  size: 130,
                ),
              ),
              if (tag.isNotEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (seen != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          width: 2,
                          color: seen!
                              ? Theme.of(context).colorScheme.outlineVariant
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
