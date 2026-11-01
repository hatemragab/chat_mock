import 'package:flutter/material.dart';

import '../../copy/discover_copy.dart';

class DiscoverLoadingView extends StatelessWidget {
  const DiscoverLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Semantics(
      label: DiscoverCopy.loadingStories,
      liveRegion: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text(
            DiscoverCopy.loadingStoriesStatus,
            style: TextStyle(color: color.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Container(
            width: 160,
            height: 18,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 0 ? 12 : 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
