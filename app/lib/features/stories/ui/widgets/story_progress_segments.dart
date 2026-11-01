import 'package:flutter/material.dart';

/// The completed, active and upcoming segments of one viewer queue.
class StoryProgressSegments extends StatelessWidget {
  const StoryProgressSegments({
    super.key,
    required this.count,
    required this.index,
    required this.progress,
  }) : assert(count > 0),
       assert(index >= 0 && index < count);

  final int count;
  final int index;
  final double progress;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    child: Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LinearProgressIndicator(
                value: i < index
                    ? 1
                    : i == index
                    ? progress
                    : 0,
                minHeight: 3,
                backgroundColor: Colors.white38,
                color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  );
}
