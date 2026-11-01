import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_search_field.dart';

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

class DiscoverSearchScreen extends StatefulWidget {
  const DiscoverSearchScreen({
    super.key,
    required this.controller,
    this.initialCategory,
    this.onBusinessProfile,
    this.discover,
    this.businessController,
    this.settings,
  });
  final StoriesController controller;
  final String? initialCategory;
  final ValueChanged<Story>? onBusinessProfile;
  final DiscoverController? discover;
  final BusinessController? businessController;
  final SettingsController? settings;
  @override
  State<DiscoverSearchScreen> createState() => _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends State<DiscoverSearchScreen> {
  final query = TextEditingController();
  String? category;
  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.controller,
        ?widget.discover,
        ?widget.businessController,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final results = widget.controller.allStories
        .where(
          (story) =>
              (story.boosted || story.sponsored || story.popular) &&
              (story.kind != StoryKind.business ||
                  !(widget.businessController?.isBlocked(story) ?? false)) &&
              (category == null || story.category == category) &&
              '${story.author} ${story.title} ${story.category}'
                  .toLowerCase()
                  .contains(query.text.toLowerCase()),
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(DiscoverCopy.searchDiscover)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.discover != null)
            DiscoverConnectivityBanner(
              connectivity: widget.discover!.connectivity,
            ),
          AppSearchField(
            controller: query,
            onChanged: (_) => setState(() {}),
            hintText: DiscoverCopy.searchStoriesAndBusinesses,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: ['Design', 'Food & drink', 'Shopping', 'Lifestyle']
                .map(
                  (item) => FilterChip(
                    label: Text(DiscoverCopy.categoryLabel(item)),
                    selected: category == item,
                    onSelected: (selected) =>
                        setState(() => category = selected ? item : null),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          if (widget.discover?.state == DiscoverLoadState.loading)
            const DiscoverLoadingView()
          else if (widget.discover?.state == DiscoverLoadState.error)
            DiscoverErrorView(onRetry: widget.discover!.load)
          else if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text(DiscoverCopy.noSearchResults)),
            ),
          if (widget.discover == null ||
              widget.discover!.state == DiscoverLoadState.ready)
            ...results.map(
              (story) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StoryCover(
                  story: story,
                  height: 150,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => StoryViewerScreen(
                        controller: widget.controller,
                        story: story,
                        storyQueue: results,
                        onBusinessProfile: widget.onBusinessProfile,
                        businessController: widget.businessController,
                        settings: widget.settings,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
