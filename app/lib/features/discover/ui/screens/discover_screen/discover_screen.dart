import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/discover_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../business/controllers/business_controller.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../../stories/controllers/stories_controller.dart';
import '../../../../stories/models/story.dart';
import '../../../../stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../controllers/discover_controller.dart';
import '../../widgets/discover_connectivity_banner.dart';
import '../../widgets/discover_error_view.dart';
import '../../widgets/discover_loading_view.dart';
import '../discover_search_screen/discover_search_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({
    super.key,
    required this.controller,
    this.discover,
    this.onBusinessProfile,
    this.businessController,
    this.settings,
  });
  final StoriesController controller;
  final DiscoverController? discover;
  final ValueChanged<Story>? onBusinessProfile;
  final BusinessController? businessController;
  final SettingsController? settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        ?discover,
        ?businessController,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final stories = controller.allStories
        .where(
          (s) =>
              (s.boosted || s.sponsored || s.popular) &&
              (s.kind != StoryKind.business ||
                  !(businessController?.isBlocked(s) ?? false)),
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(
        title: const Text(DiscoverCopy.discover),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => DiscoverSearchScreen(
                  controller: controller,
                  discover: discover,
                  onBusinessProfile: onBusinessProfile,
                  businessController: businessController,
                  settings: settings,
                ),
              ),
            ),
            icon: const Icon(Icons.search),
            tooltip: DiscoverCopy.searchDiscover,
          ),
        ],
      ),
      body: Column(
        children: [
          if (discover != null)
            DiscoverConnectivityBanner(connectivity: discover!.connectivity),
          Expanded(
            child: switch (discover?.state ?? DiscoverLoadState.ready) {
              DiscoverLoadState.loading => ListView(
                children: const [DiscoverLoadingView()],
              ),
              DiscoverLoadState.error => ListView(
                children: [DiscoverErrorView(onRetry: discover!.load)],
              ),
              DiscoverLoadState.ready => ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  Text(
                    DiscoverCopy.aLittleInspirationEveryDay,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          DiscoverCopy.exploreStories,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DiscoverCopy.forYou,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (stories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(DiscoverCopy.noPromotedStories),
                      ),
                    )
                  else
                    SizedBox(
                      height: 238,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return SizedBox(
                            width: 175,
                            child: StoryCover(
                              story: story,
                              height: 238,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => StoryViewerScreen(
                                    controller: controller,
                                    story: story,
                                    storyQueue: stories,
                                    onBusinessProfile: onBusinessProfile,
                                    businessController: businessController,
                                    settings: settings,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 26),
                  Text(
                    DiscoverCopy.browseByCategory,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Design', 'Food & drink', 'Shopping', 'Lifestyle']
                            .map(
                              (category) => ActionChip(
                                label: Text(
                                  DiscoverCopy.categoryLabel(category),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => DiscoverSearchScreen(
                                      controller: controller,
                                      initialCategory: category,
                                      discover: discover,
                                      onBusinessProfile: onBusinessProfile,
                                      businessController: businessController,
                                      settings: settings,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    DiscoverCopy.popularNearYou,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...stories
                      .where((s) => s.popular || s.sponsored)
                      .map(
                        (story) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StoryCover(
                            story: story,
                            height: 150,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => StoryViewerScreen(
                                  controller: controller,
                                  story: story,
                                  storyQueue: stories
                                      .where((s) => s.popular || s.sponsored)
                                      .toList(),
                                  onBusinessProfile: onBusinessProfile,
                                  businessController: businessController,
                                  settings: settings,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            },
          ),
        ],
      ),
    );
  }
}
