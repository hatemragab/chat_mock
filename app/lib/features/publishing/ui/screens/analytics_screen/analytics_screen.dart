import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import 'widgets/qualified_views_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.controller,
    required this.publication,
  });
  final PublishingController controller;
  final Publication publication;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.promotionAnalytics)),
    body: ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        if (controller.contactActivity case final activity?) activity.changes,
      ]),
      builder: (context, _) {
        final threshold = controller.config.popularThreshold;
        final activity = controller.contactActivity;
        final room = activity?.roomFor(publication);
        final calls = activity?.callsFor(publication);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              PublishingCopy.aggregateInsights,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(PublishingCopy.anonymousAnalyticsDescription),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(PublishingCopy.totalViews),
              trailing: Text('${publication.totalViews}'),
            ),
            ListTile(
              title: const Text(PublishingCopy.qualifiedUniqueViews),
              trailing: Text('${publication.qualifiedViews}'),
            ),
            ListTile(
              title: const Text(PublishingCopy.viewsHeldForReview),
              trailing: Text('${publication.heldViews}'),
            ),
            ListTile(
              title: const Text(PublishingCopy.pendingDiamondRewards),
              subtitle: Text(
                PublishingCopy.rewardTerms(
                  publication.diamondsPerReward,
                  publication.qualifiedViewsPerDiamond,
                ),
              ),
              trailing: Text('${publication.pendingDiamondRewards}'),
            ),
            const SizedBox(height: 16),
            Text(
              PublishingCopy.popularProgress(
                publication.qualifiedViews,
                threshold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: threshold > 0
                  ? (publication.qualifiedViews / threshold).clamp(0, 1)
                  : 0,
            ),
            const SizedBox(height: 8),
            if (threshold > 0 && publication.qualifiedViews >= threshold)
              const Text(PublishingCopy.popularThresholdReached)
            else
              const Text(
                PublishingCopy.qualifiedViewsCountTowardPopularPlacement,
              ),
            const SizedBox(height: 24),
            Text(
              PublishingCopy.qualifiedViewsLast7Days,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            QualifiedViewsChart(
              now: controller.now,
              viewsByDay: publication.qualifiedViewsByDay,
            ),
            const SizedBox(height: 24),
            Text(
              PublishingCopy.contactEngagement,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(PublishingCopy.activityStartedFromThisStory),
            if (activity == null)
              const Text(PublishingCopy.contactActivityUnavailable)
            else ...[
              ListTile(
                title: const Text(PublishingCopy.conversations),
                trailing: Text(room == null ? '0' : '1'),
              ),
              ListTile(
                title: const Text(PublishingCopy.messages),
                trailing: Text('${room?.messages.length ?? 0}'),
              ),
              ListTile(
                title: const Text(PublishingCopy.calls),
                trailing: Text('${calls!.length}'),
              ),
            ],
          ],
        );
      },
    ),
  );
}
