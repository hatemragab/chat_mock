import 'package:flutter/material.dart';

import '../../../../shared/copy/common_copy.dart';
import '../../copy/discover_copy.dart';

class DiscoverErrorView extends StatelessWidget {
  const DiscoverErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            DiscoverCopy.couldNotLoadStories,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            DiscoverCopy.retryDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(CommonCopy.retry),
          ),
        ],
      ),
    );
  }
}
