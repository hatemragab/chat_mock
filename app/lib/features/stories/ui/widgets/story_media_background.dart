import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/story.dart';

/// Displays the same local sample and edits in every Story presentation.
class StoryMediaBackground extends StatelessWidget {
  const StoryMediaBackground({super.key, required this.story, this.dim = .35});
  final Story story;
  final double dim;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: story.colors,
            ),
          ),
        ),
        if (story.assetPath case final assetPath?)
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              final needsQuarterTurn = story.rotation % 2 != 0;
              final canMeasure =
                  size.width.isFinite &&
                  size.height.isFinite &&
                  size.width > 0 &&
                  size.height > 0;
              final rotationScale = needsQuarterTurn && canMeasure
                  ? math.max(size.width / size.height, size.height / size.width)
                  : 1.0;
              return Transform.scale(
                scale: rotationScale * story.cropScale.clamp(1, 2),
                child: Transform.rotate(
                  angle: (story.rotation % 4) * math.pi / 2,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ColoredBox(color: Colors.black.withValues(alpha: dim.clamp(0, 1))),
      ],
    ),
  );
}
