import 'package:flutter/material.dart';

import '../../chats/models/chat_models.dart';
import '../../chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import '../../chats/ui/screens/conversation_screen/conversation_screen.dart';
import '../../groups/controllers/group_controller.dart';
import '../../groups/ui/screens/group_details_screen/group_details_screen.dart';
import '../../groups/ui/screens/group_members_screen/group_members_screen.dart';
import 'review_actions.dart';

ChatConversation? _voiceConversation(ReviewActions actions) => actions
    .chats
    .conversations
    .where(
      (chat) =>
          chat.id == 'sarah' && !chat.hidden && actions.chats.canSendTo(chat),
    )
    .firstOrNull;

/// Whether the requested real feature state can be shown in the current session.
bool canOpenChatMissing(ReviewActions actions, String id) => switch (id) {
  'V022' || 'V023' => _voiceConversation(actions) != null,
  'V026' || 'V036' => true,
  'V039' || 'V040' =>
    actions.group.canEdit &&
        actions.group.updateStatus != GroupUpdateStatus.submitting,
  _ => false,
};

String _nonMatchingQuery(Iterable<String> values) {
  var query = 'no-match-0';
  var suffix = 0;
  while (values.any((value) => value.toLowerCase().contains(query))) {
    query = 'no-match-${++suffix}';
  }
  return query;
}

/// Opens the production screen in the requested state; users can interact normally.
Future<void> openChatMissing(
  ReviewActions actions,
  BuildContext context,
  String id,
) async {
  if (!canOpenChatMissing(actions, id)) return;
  Widget screen;
  switch (id) {
    case 'V022':
    case 'V023':
      screen = ConversationScreen(
        controller: actions.chats,
        chat: _voiceConversation(actions)!,
        initialRecording: true,
        initialRecordingLocked: id == 'V023',
      );
    case 'V026':
      screen = ChatSearchScreen(
        controller: actions.chats,
        initialQuery: _nonMatchingQuery(
          actions.chats.conversations.expand(
            (chat) => [
              chat.name,
              ...chat.messages.map((message) => message.text),
            ],
          ),
        ),
      );
    case 'V036':
      screen = GroupMembersScreen(
        controller: actions.group,
        initialQuery: _nonMatchingQuery(
          actions.group.activeMembers.map((member) => member.name),
        ),
      );
    case 'V039':
    case 'V040':
      screen = GroupDetailsScreen(
        controller: actions.group,
        reviewState: id == 'V039'
            ? GroupUpdateReviewState.submitting
            : GroupUpdateReviewState.failed,
      );
    default:
      return;
  }
  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}
