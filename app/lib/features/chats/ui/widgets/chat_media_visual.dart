import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/chat_media_edits.dart';

/// Uses the same local artwork and visible crop/rotation in editor and viewer.
class ChatMediaVisual extends StatelessWidget {
  const ChatMediaVisual({
    super.key,
    required this.assetPath,
    this.edits,
    this.height = 200,
  });

  final String assetPath;
  final ChatMediaEdits? edits;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rotation = edits?.rotation ?? 0;
          final crop = edits?.cropScale ?? 1;
          final size = constraints.biggest;
          final rotationScale = rotation.isOdd
              ? math.max(size.width / size.height, size.height / size.width)
              : 1.0;
          return Transform.scale(
            scale: rotationScale * crop,
            child: Transform.rotate(
              angle: rotation * math.pi / 2,
              child: Image.asset(
                assetPath,
                key: ValueKey('media-asset-$assetPath'),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined, size: 64),
              ),
            ),
          );
        },
      ),
    ),
  );
}
