import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_list_filter.dart';
import '../../../models/chat_models.dart';
import '../../dialogs/delete_conversation_dialog/delete_conversation_dialog.dart';
import '../../navigation/chat_destination.dart';
import '../../sheets/chat_actions_sheet/chat_actions_sheet.dart';
import '../../sheets/mute_duration_sheet/mute_duration_sheet.dart';
import '../../widgets/conversation_list_row.dart';
import '../archived_chats_screen/archived_chats_screen.dart';
import '../chat_search_screen/chat_search_screen.dart';
import '../recipient_picker_screen/recipient_picker_screen.dart';
import '../starred_messages_screen/starred_messages_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    super.key,
    required this.controller,
    this.specialScreenBuilder,
    this.specialMessageScreenBuilder,
    this.onCreateGroup,
  });
  final ChatsController controller;
  final SpecialChatScreenBuilder? specialScreenBuilder;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  final VoidCallback? onCreateGroup;
  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  ChatListFilter _filter = ChatListFilter.all;
  void _open(ChatConversation chat) {
    widget.controller.markRead(chat);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => chatDestination(
          controller: widget.controller,
          chat: chat,
          specialScreenBuilder: widget.specialScreenBuilder,
          specialMessageScreenBuilder: widget.specialMessageScreenBuilder,
        ),
      ),
    );
  }

  Future<void> _actions(ChatConversation chat) async {
    final action = await showModalBottomSheet<ChatListAction>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ChatActionsSheet(chat: chat),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case ChatListAction.pin:
        widget.controller.togglePinned(chat);
      case ChatListAction.archive:
        widget.controller.archive(chat);
      case ChatListAction.unread:
        widget.controller.setUnread(chat, chat.unread == 0);
      case ChatListAction.mute:
        final choice = await showModalBottomSheet<MuteChoice>(
          context: context,
          showDragHandle: true,
          builder: (_) =>
              MuteDurationSheet(name: chat.name, isMuted: chat.muted),
        );
        if (!mounted || choice == null) return;
        switch (choice) {
          case MuteChoice.eightHours:
            widget.controller.muteFor(chat, const Duration(hours: 8));
          case MuteChoice.oneWeek:
            widget.controller.muteFor(chat, const Duration(days: 7));
          case MuteChoice.always:
            widget.controller.muteFor(chat, null);
          case MuteChoice.unmute:
            widget.controller.unmute(chat);
        }
      case ChatListAction.starred:
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => StarredMessagesScreen(
              controller: widget.controller,
              chat: chat,
              specialScreenBuilder: widget.specialScreenBuilder,
              specialMessageScreenBuilder: widget.specialMessageScreenBuilder,
            ),
          ),
        );
      case ChatListAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => DeleteConversationDialog(chat: chat),
        );
        if (confirmed == true && mounted) {
          widget.controller.deleteConversation(chat);
        }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final chats =
          widget.controller.conversations
              .where(
                (chat) =>
                    !chat.archived &&
                    !chat.hidden &&
                    switch (_filter) {
                      ChatListFilter.unread => chat.unread > 0,
                      ChatListFilter.contacts => chat.kind == ChatKind.contact,
                      ChatListFilter.groups => chat.kind == ChatKind.group,
                      ChatListFilter.business => chat.kind == ChatKind.business,
                      ChatListFilter.all => true,
                    },
              )
              .toList()
            ..sort((a, b) => (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0));
      return AppScaffold(
        appBar: AppHeader(
          title: const Text(ChatCopy.chats),
          actions: [
            IconButton(
              tooltip: ChatCopy.searchChats,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChatSearchScreen(
                    controller: widget.controller,
                    specialScreenBuilder: widget.specialScreenBuilder,
                    specialMessageScreenBuilder:
                        widget.specialMessageScreenBuilder,
                  ),
                ),
              ),
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              tooltip: ChatCopy.moreOptions,
              onSelected: (value) {
                if (value == 'new_group') widget.onCreateGroup?.call();
                if (value == 'archive') {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ArchivedChatsScreen(
                        controller: widget.controller,
                        specialScreenBuilder: widget.specialScreenBuilder,
                        specialMessageScreenBuilder:
                            widget.specialMessageScreenBuilder,
                      ),
                    ),
                  );
                }
                if (value == 'starred') {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => StarredMessagesScreen(
                        controller: widget.controller,
                        specialScreenBuilder: widget.specialScreenBuilder,
                        specialMessageScreenBuilder:
                            widget.specialMessageScreenBuilder,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                if (widget.onCreateGroup != null)
                  const PopupMenuItem(
                    value: 'new_group',
                    child: Text(ChatCopy.newGroup),
                  ),
                const PopupMenuItem(
                  value: 'archive',
                  child: Text(ChatCopy.archivedChats),
                ),
                const PopupMenuItem(
                  value: 'starred',
                  child: Text(ChatCopy.starredMessages),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: ChatCopy.newChat,
          onPressed: () async {
            final selected = await Navigator.push<List<ChatConversation>>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RecipientPickerScreen(controller: widget.controller),
              ),
            );
            if (mounted && selected != null && selected.isNotEmpty) {
              _open(selected.first);
            }
          },
          child: const Icon(Icons.chat_outlined),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: ChatListFilter.values
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter.label),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (!widget.controller.online)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Text(
                  ChatCopy.offlineQueueDescription,
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: chats.isEmpty
                  ? const AppStateView(title: ChatCopy.noChatsToShow)
                  : ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ConversationListRow(
                          chat: chat,
                          onTap: () => _open(chat),
                          onLongPress: () => _actions(chat),
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
