import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../navigation/chat_destination.dart';
import '../../widgets/conversation_list_row.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({
    super.key,
    required this.controller,
    this.specialScreenBuilder,
    this.specialMessageScreenBuilder,
  });
  final ChatsController controller;
  final SpecialChatScreenBuilder? specialScreenBuilder;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(ChatCopy.archivedChats)),
    body: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final chats = controller.conversations
            .where((chat) => chat.archived && !chat.hidden)
            .toList();
        if (chats.isEmpty) {
          return const AppStateView(title: ChatCopy.noArchivedChats);
        }
        return ListView(
          children: chats
              .map(
                (chat) => ConversationListRow(
                  chat: chat,
                  trailing: IconButton(
                    tooltip: ChatCopy.unarchive,
                    icon: const Icon(Icons.unarchive_outlined),
                    onPressed: () => controller.archive(chat),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => chatDestination(
                        controller: controller,
                        chat: chat,
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
