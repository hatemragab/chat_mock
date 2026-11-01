import 'package:flutter/material.dart';

import '../../../../chats/models/chat_mention_candidate.dart';
import '../../../../chats/ui/screens/conversation_screen/conversation_screen.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../group_info_screen/group_info_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({
    super.key,
    required this.controller,
    this.initialMessageId,
    this.initialDraft,
  });
  final GroupController controller;
  final String? initialMessageId;
  final String? initialDraft;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => ConversationScreen(
      controller: controller.chats,
      chat: controller.conversation,
      draftId:
          '${controller.conversation.id}:member:${controller.perspectiveId}',
      initialMessageId: initialMessageId,
      initialDraft: initialDraft,
      composerEnabled: controller.canSend,
      composerDisabledReason: controller.left
          ? GroupCopy.leftGroupReadOnly
          : controller.removed || !controller.perspective.active
          ? GroupCopy.removedGroupReadOnly
          : GroupCopy.onlyAdminsCanSendDescription,
      onGroupSend: (text, reply) => controller.send(text, reply: reply),
      isOwnMessage: controller.isOwnMessage,
      mentionCandidates: controller.activeMembers
          .where((member) => member.id != controller.perspectiveId)
          .map(
            (member) => ChatMentionCandidate(id: member.id, name: member.name),
          )
          .toList(growable: false),
      onInfo: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => GroupInfoScreen(controller: controller),
        ),
      ),
      specialMessageScreenBuilder: (chat, messageId) =>
          chat.id == controller.conversation.id
          ? GroupScreen(controller: controller, initialMessageId: messageId)
          : null,
    ),
  );
}
