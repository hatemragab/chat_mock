import 'package:flutter/material.dart';

import '../../../copy/stories_copy.dart';

import '../../../models/story.dart';

enum StoryOption {
  publicProfile,
  report,
  block,
  publicationDetails,
  viewers,
  deletePublication,
  myPublications,
}

/// Contextual options for a single Story. The caller performs the selected action.
class StoryOptionsSheet extends StatelessWidget {
  const StoryOptionsSheet({
    super.key,
    required this.story,
    this.canOpenProfile = false,
    this.canBlock = false,
    this.blocked = false,
    this.hasPublication = false,
    this.hasPublishing = false,
    this.canDeletePublication = false,
  });

  final Story story;
  final bool canOpenProfile;
  final bool canBlock;
  final bool blocked;
  final bool hasPublication;
  final bool hasPublishing;
  final bool canDeletePublication;

  @override
  Widget build(BuildContext context) {
    void select(StoryOption option) => Navigator.pop(context, option);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StoriesCopy.storyOptions,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              story.kind == StoryKind.own
                  ? story.title
                  : StoriesCopy.identityTitle(story.author, story.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (story.kind == StoryKind.business && canOpenProfile)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storefront_outlined),
                title: const Text(StoriesCopy.viewBusinessProfile),
                onTap: () => select(StoryOption.publicProfile),
              ),
            if (story.kind != StoryKind.own) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.flag_outlined),
                title: const Text(StoriesCopy.reportStory),
                onTap: () => select(StoryOption.report),
              ),
              if (canBlock)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(blocked ? Icons.lock_open : Icons.block),
                  title: Text(StoriesCopy.blockAction(blocked, story.author)),
                  onTap: () => select(StoryOption.block),
                ),
            ],
            if (story.kind == StoryKind.own && hasPublication) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: const Text(StoriesCopy.publicationDetails),
                onTap: () => select(StoryOption.publicationDetails),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.visibility_outlined),
                title: Text(
                  story.boosted || story.sponsored
                      ? StoriesCopy.promotionAnalytics
                      : StoriesCopy.storyViewers,
                ),
                onTap: () => select(StoryOption.viewers),
              ),
              if (canDeletePublication)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline),
                  title: const Text(StoriesCopy.deletePublication),
                  onTap: () => select(StoryOption.deletePublication),
                ),
            ] else if (story.kind == StoryKind.own && hasPublishing)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: const Text(StoriesCopy.myPublications),
                onTap: () => select(StoryOption.myPublications),
              ),
          ],
        ),
      ),
    );
  }
}
