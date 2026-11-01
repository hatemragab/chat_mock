import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import '../../../../chats/ui/screens/shared_media_screen/shared_media_screen.dart';
import '../../../../chats/ui/screens/starred_messages_screen/starred_messages_screen.dart';
import '../../../../stories/models/story.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';
import '../../../models/business_room.dart';
import '../../sheets/business_contact_sheet/business_contact_sheet.dart';
import '../../widgets/business_safety_actions.dart';
import '../business_conversation_screen/business_conversation_screen.dart';

class BusinessInfoScreen extends StatelessWidget {
  const BusinessInfoScreen({
    super.key,
    required this.controller,
    required this.story,
  });
  final BusinessController controller;
  final Story story;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final room = controller.roomFor(story.id);
      final active = room != null && controller.isActive(room);
      final chats = controller.chats;
      final chat = chats?.businessConversation(story.id);
      Widget? businessDestination(
        ChatConversation selected,
        String? messageId,
      ) {
        final source = controller.storyForChat(selected);
        if (source == null || source.id != story.id) return null;
        return BusinessConversationScreen(
          controller: controller,
          story: source,
          initialMessageId: messageId,
        );
      }

      return AppScaffold(
        appBar: AppHeader(title: const Text(BusinessCopy.conversationInfo)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            StoryCover(story: story, height: 160),
            const SizedBox(height: 16),
            Text(
              story.author,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(BusinessCopy.storyCategoryTitle(story.category, story.title)),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(
                active ? BusinessCopy.roomActive : BusinessCopy.roomExpired,
              ),
              subtitle: Text(
                room == null
                    ? BusinessCopy.noRoomOpened
                    : BusinessCopy.expiresAt(room.expiresAt),
              ),
            ),
            if (chat != null && chats != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(BusinessCopy.mediaFilesLinks),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SharedMediaScreen(
                      chat: chat,
                      controller: chats,
                      specialMessageScreenBuilder: businessDestination,
                    ),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_border),
                title: const Text(BusinessCopy.starredMessages),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => StarredMessagesScreen(
                      controller: chats,
                      chat: chat,
                      specialMessageScreenBuilder: businessDestination,
                    ),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.search),
                title: const Text(BusinessCopy.searchMessages),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChatSearchScreen(
                      controller: chats,
                      chat: chat,
                      specialMessageScreenBuilder: businessDestination,
                    ),
                  ),
                ),
              ),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.toll_outlined),
              title: Text(
                BusinessCopy.roomPrice24Hours(controller.config.roomCredits),
              ),
              subtitle: const Text(BusinessCopy.noPerMessageFee),
            ),
            if (!active &&
                controller.perspective == BusinessPerspective.customer &&
                controller.sourceEligible(story) &&
                !controller.isBlocked(story))
              FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => BusinessContactSheet(
                    controller: controller,
                    story: story,
                  ),
                ),
                child: const Text(BusinessCopy.reopenRoom),
              ),
            BusinessSafetyActions(controller: controller, story: story),
            if (!controller.sourceEligible(story))
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(BusinessCopy.expiredSourceCannotReopen),
              ),
          ],
        ),
      );
    },
  );
}
