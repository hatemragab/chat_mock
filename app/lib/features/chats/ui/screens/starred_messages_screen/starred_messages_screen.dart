import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_state_view.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';
import '../../navigation/chat_destination.dart';

class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({
    super.key,
    required this.controller,
    this.chat,
    this.specialScreenBuilder,
    this.specialMessageScreenBuilder,
  });
  final ChatsController controller;
  final ChatConversation? chat;
  final SpecialChatScreenBuilder? specialScreenBuilder;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(ChatCopy.starredMessages)),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = <(ChatConversation, ChatMessage)>[];
        for (final conversation
            in chat == null ? controller.conversations : [chat!]) {
          for (final message in conversation.messages.where(
            (message) => message.starred && !message.deleted,
          )) {
            entries.add((conversation, message));
          }
        }
        if (entries.isEmpty) {
          return const AppStateView(title: ChatCopy.noStarredMessages);
        }
        return ListView(
          children: entries
              .map(
                (entry) => ListTile(
                  title: Text(entry.$1.name),
                  subtitle: Text(entry.$2.text),
                  trailing: IconButton(
                    tooltip: ChatCopy.unstar,
                    icon: const Icon(Icons.star),
                    onPressed: () => controller.toggleStar(entry.$2),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => chatDestination(
                        controller: controller,
                        chat: entry.$1,
                        messageId: entry.$2.id,
                        specialScreenBuilder: specialScreenBuilder,
                        specialMessageScreenBuilder:
                            specialMessageScreenBuilder,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
