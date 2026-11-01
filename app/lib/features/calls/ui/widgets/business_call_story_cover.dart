import 'package:flutter/material.dart';

import '../../../stories/models/story.dart';
import '../../copy/calls_copy.dart';

/// Public Story imagery retained with a Business call; never a personal avatar.
class BusinessCallStoryCover extends StatelessWidget {
  const BusinessCallStoryCover({
    super.key,
    required this.story,
    this.size = 120,
  });

  final Story story;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: CallsCopy.storySemantics(story.author, story.title),
      image: true,
      child: Container(
        key: ValueKey('call-story-${story.id}'),
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size < 60 ? 9 : 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: story.colors,
          ),
        ),
        child: story.assetPath == null
            ? const Icon(Icons.auto_stories_outlined, color: Colors.white70)
            : Image.asset(
                story.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.auto_stories_outlined,
                  color: Colors.white70,
                ),
              ),
      ),
    );
  }
}
