import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/stories_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../business/controllers/business_controller.dart';
import '../../../../chats/controllers/chats_controller.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/stories_controller.dart';
import '../../../models/story.dart';
import '../../../ui/widgets/story_cover.dart';
import '../story_viewer_screen/story_viewer_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
    required this.controller,
    required this.onDiscover,
    required this.onCreate,
    this.chatsController,
    this.businessController,
    this.onBusinessProfile,
    this.settings,
  });
  final StoriesController controller;
  final VoidCallback onDiscover;
  final VoidCallback onCreate;
  final ChatsController? chatsController;
  final BusinessController? businessController;
  final ValueChanged<Story>? onBusinessProfile;
  final SettingsController? settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        chatsController,
        businessController,
      ]),
      builder: (context, _) {
        final own = controller.allStories
            .where((story) => story.kind == StoryKind.own && !story.sponsored)
            .toList();
        final contacts = <Story>[];
        for (final story in controller.allStories.where(
          (story) => story.kind == StoryKind.contact,
        )) {
          final chats = chatsController;
          if (chats == null) {
            contacts.add(story);
            continue;
          }
          final contact = chats.conversations
              .where(
                (chat) => chat.id == story.id && chat.kind == ChatKind.contact,
              )
              .firstOrNull;
          if (contact != null && chats.canCommunicateWithContact(contact)) {
            contacts.add(story.withAuthor(contact.name));
          }
        }
        final recent = contacts.where((story) => !controller.isSeen(story.id));
        final seen = contacts.where((story) => controller.isSeen(story.id));
        final promoted = controller.allStories
            .where(
              (story) =>
                  (story.boosted || story.sponsored || story.popular) &&
                  (story.kind != StoryKind.business ||
                      !(businessController?.isBlocked(story) ?? false)),
            )
            .toList();
        void open(Story story) => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => StoryViewerScreen(
              controller: controller,
              story: story,
              storyQueue: story.kind == StoryKind.own ? own : contacts,
              chatsController: chatsController,
              settings: settings,
              businessController: businessController,
            ),
          ),
        );
        void openPromoted(Story story) => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => StoryViewerScreen(
              controller: controller,
              story: story,
              storyQueue: promoted,
              businessController: businessController,
              onBusinessProfile: onBusinessProfile,
              settings: settings,
            ),
          ),
        );
        return AppScaffold(
          appBar: AppHeader(title: const Text(StoriesCopy.status)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                StoriesCopy.yourStatus,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (own.isEmpty)
                const Text(StoriesCopy.noOwnStatus)
              else
                ...own.map(
                  (story) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StoryCover(
                      story: story,
                      height: 130,
                      onTap: () => open(story),
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text(StoriesCopy.createStatus),
              ),
              const SizedBox(height: 24),
              Text(
                StoriesCopy.recentUpdates,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (contacts.isEmpty) const Text(StoriesCopy.noContactStories),
              ...recent.map(
                (story) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StoryCover(
                    story: story,
                    height: 140,
                    seen: false,
                    onTap: () => open(story),
                  ),
                ),
              ),
              if (seen.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  StoriesCopy.seenUpdates,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...seen.map(
                  (story) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StoryCover(
                      story: story,
                      height: 140,
                      seen: true,
                      onTap: () => open(story),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onDiscover,
                icon: const Icon(Icons.explore_outlined),
                label: const Text(StoriesCopy.exploreDiscover),
              ),
              const SizedBox(height: 24),
              Text(
                StoriesCopy.discoverPreview,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (promoted.isEmpty)
                const Text(StoriesCopy.noPromotedStories)
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: promoted.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final story = promoted[index];
                      return SizedBox(
                        width: 180,
                        child: StoryCover(
                          story: story,
                          height: 150,
                          onTap: () => openPromoted(story),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
