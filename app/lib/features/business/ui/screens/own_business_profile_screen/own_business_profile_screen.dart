import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../../settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import '../../../../stories/controllers/stories_controller.dart';
import '../../../../stories/models/story.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../copy/business_copy.dart';
import '../own_business_story_screen/own_business_story_screen.dart';

class OwnBusinessProfileScreen extends StatelessWidget {
  const OwnBusinessProfileScreen({
    super.key,
    required this.settings,
    required this.stories,
  });
  final SettingsController settings;
  final StoriesController stories;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([settings, stories]),
    builder: (context, _) {
      final profile = settings.businessProfile;
      final available = stories.allStories
          .where(
            (story) =>
                story.kind == StoryKind.own &&
                (story.boosted || story.sponsored),
          )
          .toList();
      final linked = available
          .where((story) => settings.businessStoryIds.contains(story.id))
          .toList();
      final unlinked = available
          .where((story) => !settings.businessStoryIds.contains(story.id))
          .toList();
      return AppScaffold(
        appBar: AppHeader(
          title: const Text(BusinessCopy.publicBusinessProfile),
          actions: [
            IconButton(
              tooltip: BusinessCopy.editBusinessProfile,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      EditBusinessProfileScreen(controller: settings),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!profile.isComplete) ...[
              Text(
                BusinessCopy.completePublicProfile,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(BusinessCopy.completePublicProfileExplanation),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        EditBusinessProfileScreen(controller: settings),
                  ),
                ),
                child: const Text(BusinessCopy.editBusinessProfile),
              ),
            ] else ...[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: switch (profile.coverAssetPath) {
                  final path? => Image.asset(
                    path,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: BusinessCopy.publicCoverSemantics,
                  ),
                  null => const Icon(Icons.storefront_outlined, size: 48),
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (profile.logoAssetPath case final path?) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        path,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        semanticLabel: BusinessCopy.publicLogoSemantics,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(profile.description),
              if (profile.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(profile.location),
              ],
              const SizedBox(height: 24),
              Text(
                BusinessCopy.activeStories,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (linked.isEmpty)
                const Text(BusinessCopy.noLinkedActiveStories),
              for (final source in linked) ...[
                StoryCover(
                  story: _publicStory(source, profile.name),
                  height: 145,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => OwnBusinessStoryScreen(
                        story: _publicStory(source, profile.name),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => settings.unlinkBusinessStory(source.id),
                    child: const Text(BusinessCopy.unlinkStory),
                  ),
                ),
              ],
              if (unlinked.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (sheetContext) => SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          const ListTile(
                            title: Text(BusinessCopy.choosePromotedStory),
                          ),
                          for (final story in unlinked)
                            ListTile(
                              title: Text(story.title),
                              subtitle: Text(story.category),
                              onTap: () {
                                settings.linkBusinessStory(story);
                                Navigator.pop(sheetContext);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(BusinessCopy.linkStory),
                ),
              ],
            ],
          ],
        ),
      );
    },
  );

  Story _publicStory(Story source, String publicName) => Story(
    id: source.id,
    author: publicName,
    title: source.title,
    category: source.category,
    kind: StoryKind.own,
    media: source.media,
    colors: source.colors,
    sponsored: source.sponsored,
    boosted: source.boosted,
    popular: source.popular,
    assetPath: source.assetPath,
    sampleLabel: source.sampleLabel,
    rotation: source.rotation,
    cropScale: source.cropScale,
    trimStart: source.trimStart,
    trimEnd: source.trimEnd,
    coverLabel: source.coverLabel,
  );
}
