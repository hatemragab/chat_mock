import 'package:flutter/material.dart';

import '../../copy/discover_copy.dart';

import '../../controllers/discover_controller.dart';

class DiscoverConnectivityBanner extends StatelessWidget {
  const DiscoverConnectivityBanner({super.key, required this.connectivity});
  final DiscoverConnectivity connectivity;

  @override
  Widget build(BuildContext context) {
    if (connectivity == DiscoverConnectivity.online) {
      return const SizedBox.shrink();
    }
    final message = connectivity == DiscoverConnectivity.offline
        ? DiscoverCopy.offlineShowingAvailableStories
        : DiscoverCopy.reconnecting;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
