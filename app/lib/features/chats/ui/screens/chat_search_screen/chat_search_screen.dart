import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_person_row.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_section_heading.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';
import '../../navigation/chat_destination.dart';
import '../../widgets/conversation_list_row.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({
    super.key,
    required this.controller,
    this.chat,
    this.specialScreenBuilder,
    this.specialMessageScreenBuilder,
    this.initialQuery = '',
  });
  final ChatsController controller;
  final ChatConversation? chat;
  final SpecialChatScreenBuilder? specialScreenBuilder;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  final String initialQuery;
  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  late String query = widget.initialQuery;
  late final TextEditingController queryController = TextEditingController(
    text: query,
  );

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => _page(context),
  );

  void _open(ChatConversation chat, [String? messageId]) {
    FocusScope.of(context).unfocus();
    widget.controller.markRead(chat);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => chatDestination(
          controller: widget.controller,
          chat: chat,
          messageId: messageId,
          specialScreenBuilder: widget.specialScreenBuilder,
          specialMessageScreenBuilder: widget.specialMessageScreenBuilder,
        ),
      ),
    );
  }

  Widget _page(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final conversations = widget.chat == null
        ? widget.controller.conversations.where((chat) => !chat.hidden).toList()
        : [widget.chat!];
    final matches = widget.chat == null && normalized.isNotEmpty
        ? conversations
              .where((chat) => chat.name.toLowerCase().contains(normalized))
              .toList()
        : <ChatConversation>[];
    final results = <(ChatConversation, ChatMessage)>[];
    if (normalized.isNotEmpty) {
      for (final chat in conversations) {
        for (final message in chat.messages) {
          if (!message.deleted &&
              (message.text.toLowerCase().contains(normalized) ||
                  (message.mediaEdits?.caption.toLowerCase().contains(
                        normalized,
                      ) ??
                      false) ||
                  (message.fileMetadata?.fileName.toLowerCase().contains(
                        normalized,
                      ) ??
                      false))) {
            results.add((chat, message));
          }
        }
      }
    }
    return AppScaffold(
      appBar: AppHeader(
        title: Text(
          widget.chat == null ? ChatCopy.searchChats : ChatCopy.searchMessages,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              controller: queryController,
              autofocus: true,
              hintText: widget.chat == null
                  ? ChatCopy.searchChats
                  : ChatCopy.searchMessages,
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          Expanded(
            child: results.isEmpty && matches.isEmpty
                ? AppStateView(
                    title: normalized.isEmpty
                        ? ChatCopy.searchYourConversations
                        : widget.chat == null
                        ? ChatCopy.noMatchingConversationsOrMessages
                        : ChatCopy.noMatchingMessages,
                  )
                : ListView(
                    children: [
                      if (matches.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: AppSectionHeading(
                            title: ChatCopy.conversationResults,
                          ),
                        ),
                        for (final chat in matches)
                          ConversationListRow(
                            chat: chat,
                            onTap: () => _open(chat),
                          ),
                      ],
                      if (widget.chat == null && results.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: AppSectionHeading(
                            title: ChatCopy.messageResults,
                          ),
                        ),
                      for (final result in results)
                        AppPersonRow(
                          name: result.$1.name,
                          subtitle:
                              result.$2.mediaEdits?.caption.trim().isNotEmpty ==
                                  true
                              ? '${result.$2.text}\n${result.$2.mediaEdits!.caption}'
                              : result.$2.text,
                          subtitleMaxLines: 2,
                          onTap: () => _open(result.$1, result.$2.id),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
