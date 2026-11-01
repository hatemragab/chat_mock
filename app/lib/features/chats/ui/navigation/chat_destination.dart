import 'package:flutter/widgets.dart';

import '../../controllers/chats_controller.dart';
import '../../models/chat_models.dart';
import '../screens/conversation_screen/conversation_screen.dart';

typedef SpecialChatScreenBuilder = Widget? Function(ChatConversation chat);
typedef SpecialMessageScreenBuilder = Widget? Function(
  ChatConversation chat,
  String? messageId,
);

/// Resolves all entry points through the same group and Business routing.
Widget chatDestination({
  required ChatsController controller,
  required ChatConversation chat,
  String? messageId,
  SpecialChatScreenBuilder? specialScreenBuilder,
  SpecialMessageScreenBuilder? specialMessageScreenBuilder,
}) =>
    specialMessageScreenBuilder?.call(chat, messageId) ??
    specialScreenBuilder?.call(chat) ??
    ConversationScreen(
      controller: controller,
      chat: chat,
      initialMessageId: messageId,
    );
