import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/conversation_layout.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../chats/models/chat_attachment_draft.dart';
import '../../../../chats/ui/dialogs/delete_message_dialog/delete_message_dialog.dart';
import '../../../../chats/ui/screens/attachment_preview_screen/attachment_preview_screen.dart';
import '../../../../chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import '../../../../chats/ui/screens/message_details_screen/message_details_screen.dart';
import '../../../../chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import '../../../../chats/ui/sheets/attachment_sheet/attachment_sheet.dart';
import '../../../../chats/ui/sheets/message_actions_sheet/message_actions_sheet.dart';
import '../../../../chats/ui/sheets/reaction_picker_sheet/reaction_picker_sheet.dart';
import '../../../../chats/ui/utils/chat_timeline.dart';
import '../../../../chats/ui/widgets/chat_composer.dart';
import '../../../../chats/ui/widgets/chat_day_separator.dart';
import '../../../../chats/ui/widgets/message_bubble.dart';
import '../../../../stories/models/story.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';
import '../../../models/business_room.dart';
import '../../sheets/business_contact_sheet/business_contact_sheet.dart';
import '../business_info_screen/business_info_screen.dart';

class BusinessConversationScreen extends StatefulWidget {
  const BusinessConversationScreen({
    super.key,
    required this.controller,
    required this.story,
    this.initialMessageId,
  });
  final BusinessController controller;
  final Story story;
  final String? initialMessageId;

  @override
  State<BusinessConversationScreen> createState() =>
      _BusinessConversationScreenState();
}

class _BusinessConversationScreenState
    extends State<BusinessConversationScreen> {
  BusinessController get controller => widget.controller;
  Story get story => widget.story;
  ChatMessage? reply;
  ChatMessage? editing;
  final _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _targetKey.currentContext;
        if (mounted && target != null) {
          Scrollable.ensureVisible(target, alignment: .4);
        }
      });
    }
  }

  Future<void> _confirmDelete(BusinessRoom room, ChatMessage message) async {
    final choice = await showDialog<DeleteMessageChoice>(
      context: context,
      builder: (_) => DeleteMessageDialog(
        canDeleteForEveryone:
            controller.canInteract(room) &&
            controller.isOwnMessage(room, message) &&
            !message.deleted,
      ),
    );
    if (!mounted || choice == null) return;
    controller.removeMessage(
      story.id,
      message,
      forEveryone: choice == DeleteMessageChoice.forEveryone,
    );
  }

  Future<void> _actions(BusinessRoom room, ChatMessage message) async {
    bool available() =>
        identical(controller.roomFor(story.id), room) &&
        room.messages.contains(message) &&
        !message.deleted;
    final choice = await showModalBottomSheet<MessageActionSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => MessageActionsSheet(
        message: message,
        canSend: controller.canInteract(room),
        isOwn: controller.isOwnMessage(room, message),
        canForward: controller.chats != null,
        canRetry: controller.chats != null && controller.canInteract(room),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice.$1) {
      case MessageAction.react:
        if (available() && choice.$2 != null) {
          controller.react(story.id, message, choice.$2!);
        }
      case MessageAction.moreReactions:
        final reaction = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (_) =>
              ReactionPickerSheet(currentReaction: message.reaction),
        );
        if (!mounted || !available() || reaction == null) return;
        if (reaction.isNotEmpty) {
          controller.react(story.id, message, reaction);
        } else if (message.reaction case final previous?) {
          controller.react(story.id, message, previous);
        }
      case MessageAction.reply:
        if (available() && controller.canInteract(room)) {
          setState(() {
            reply = message;
            editing = null;
          });
        }
      case MessageAction.copy:
        if (available()) {
          await Clipboard.setData(ClipboardData(text: message.text));
        }
      case MessageAction.edit:
        if (available() &&
            controller.canInteract(room) &&
            controller.isOwnMessage(room, message)) {
          setState(() {
            editing = message;
            reply = null;
          });
        }
      case MessageAction.forward:
        final chats = controller.chats;
        if (!available() || chats == null) return;
        final recipients = await Navigator.push<List<ChatConversation>>(
          context,
          MaterialPageRoute(
            builder: (_) => RecipientPickerScreen(
              controller: chats,
              multiSelect: true,
              includeGroups: true,
            ),
          ),
        );
        if (mounted && available() && recipients != null) {
          chats.forward(message, recipients);
        }
      case MessageAction.star:
        controller.toggleStar(story.id, message);
      case MessageAction.pin:
        controller.togglePin(story.id, message);
      case MessageAction.retry:
        if (available() && controller.canInteract(room)) {
          controller.chats?.retry(message);
        }
      case MessageAction.info:
        if (!identical(controller.roomFor(story.id), room) ||
            !room.messages.contains(message)) {
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                MessageDetailsScreen(message: message, updates: controller),
          ),
        );
      case MessageAction.delete:
        await _confirmDelete(room, message);
    }
  }

  Widget _messageItem(BuildContext context, BusinessRoom room, int index) {
    final message = room.messages[index];
    final previous = index > 0 ? room.messages[index - 1] : null;
    final next = index + 1 < room.messages.length
        ? room.messages[index + 1]
        : null;
    final mine = controller.isOwnMessage(room, message);
    bool grouped(ChatMessage first, ChatMessage second) =>
        ChatTimeline.groupsTogether(
          first,
          second,
          group: false,
          firstIsMine: controller.isOwnMessage(room, first),
          secondIsMine: controller.isOwnMessage(room, second),
        );
    return Column(
      children: [
        if (previous == null ||
            !ChatTimeline.sameDay(previous.time, message.time))
          ChatDaySeparator(time: message.time),
        MessageBubble(
          key: message.id == widget.initialMessageId ? _targetKey : null,
          message: message,
          group: false,
          isMine: mine,
          groupedWithPrevious: previous != null && grouped(previous, message),
          groupedWithNext: next != null && grouped(message, next),
          onTap: _mediaTap(context, message),
          onRetry: () => controller.chats?.retry(message),
          highlight: message.id == widget.initialMessageId,
          onLongPress: () => _actions(room, message),
        ),
      ],
    );
  }

  Future<void> _attachments() async {
    final selected = await showModalBottomSheet<(MessageKind, String)>(
      context: context,
      builder: (sheetContext) => AttachmentSheet(
        onSelected: (kind, name) => Navigator.pop(sheetContext, (kind, name)),
      ),
    );
    if (!mounted || selected == null) return;
    final confirmed = await Navigator.push<ChatAttachmentDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => AttachmentPreviewScreen(
          kind: selected.$1,
          name: selected.$2,
          canSend: () {
            final room = controller.roomFor(story.id);
            return room != null && controller.canInteract(room);
          },
        ),
      ),
    );
    if (!mounted || confirmed == null) return;
    final sent = controller.send(
      story.id,
      confirmed.name,
      kind: confirmed.kind,
      reply: reply,
      upload: true,
      assetPath: confirmed.assetPath,
      mediaEdits: confirmed.mediaEdits,
    );
    if (sent) {
      setState(() {
        reply = null;
        editing = null;
      });
    }
  }

  void _sendVoice(Duration duration) {
    final seconds = duration.inSeconds;
    final sent = controller.send(
      story.id,
      BusinessCopy.voiceNote(seconds),
      kind: MessageKind.audio,
      reply: reply,
      upload: true,
    );
    if (sent) {
      setState(() {
        reply = null;
        editing = null;
      });
    }
  }

  VoidCallback? _mediaTap(BuildContext context, ChatMessage message) {
    if (message.deleted ||
        message.kind == MessageKind.text ||
        message.kind == MessageKind.system ||
        message.uploadState == UploadState.uploading ||
        message.uploadState == UploadState.queued ||
        message.uploadState == UploadState.failed) {
      return null;
    }
    return () => Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (viewerContext) => MediaViewerScreen(
          message: message,
          onShowSource: () => Navigator.pop(viewerContext),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final room = controller.roomFor(story.id);
      final blocked = controller.isBlocked(story);
      final active = room != null && controller.canInteract(room);
      final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
      return ConversationLayout(
        header: AppHeader(
          toolbarHeight: AppGeometry.conversationHeaderHeight,
          titleSpacing: 0,
          title: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    BusinessInfoScreen(controller: controller, story: story),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: story.colors.first,
                    child: story.assetPath == null
                        ? Center(
                            child: Text(
                              story.author.substring(0, 1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : Image.asset(story.assetPath!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        blocked
                            ? BusinessCopy.blockedRoomStatus
                            : room != null && controller.isActive(room)
                            ? active
                                  ? BusinessCopy.activeRoomStatus
                                  : BusinessCopy.unavailableRoomStatus
                            : BusinessCopy.expiredRoomStatus,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: BusinessCopy.conversationInfo,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      BusinessInfoScreen(controller: controller, story: story),
                ),
              ),
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        contextBanner: Container(
          width: double.infinity,
          padding: keyboardOpen
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
              : const EdgeInsets.all(10),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Text(
                BusinessCopy.storyContext(story.title, story.author),
                textAlign: TextAlign.center,
                maxLines: keyboardOpen ? 1 : null,
                overflow: keyboardOpen ? TextOverflow.ellipsis : null,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (room != null && !keyboardOpen)
                Text(
                  BusinessCopy.viewExpiry(
                    controller.perspective == BusinessPerspective.customer,
                    controller.isActive(room),
                    room.expiresAt,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
        messageCount: room?.messages.length ?? 0,
        messageBuilder: (context, index) => _messageItem(context, room!, index),
        buildAllMessages: widget.initialMessageId != null,
        emptyState: const Center(child: Text(BusinessCopy.startConversation)),
        composer: active
            ? ChatComposer(
                key: ValueKey((story.id, controller.perspective)),
                initialDraft: controller.draftFor(story.id),
                focusInitialDraft: false,
                onDraftChanged: (text) => controller.setDraft(story.id, text),
                onSend: (text) {
                  final bool sent;
                  if (editing case final message?) {
                    sent = controller.editMessage(story.id, message, text);
                  } else {
                    sent = controller.send(
                      story.id,
                      text,
                      reply: reply,
                      quote: reply?.text,
                    );
                  }
                  if (!sent) return false;
                  setState(() {
                    editing = null;
                    reply = null;
                  });
                  return true;
                },
                onAttachment: _attachments,
                onSendVoice: _sendVoice,
                editText: editing?.text,
                replyLabel: reply == null
                    ? null
                    : BusinessCopy.replyQuote(reply!.author, reply!.text),
                onCancelContext: () => setState(() {
                  editing = null;
                  reply = null;
                }),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      blocked
                          ? BusinessCopy.unblockToContinue
                          : room != null && controller.isActive(room)
                          ? BusinessCopy.messagingUnavailable
                          : BusinessCopy.expiredReadOnly,
                    ),
                    if (!blocked &&
                        room != null &&
                        !controller.isActive(room) &&
                        !controller.sourceEligible(story))
                      const Text(BusinessCopy.unavailableCannotReopen),
                    if (!blocked &&
                        room != null &&
                        !controller.isActive(room) &&
                        controller.perspective ==
                            BusinessPerspective.customer &&
                        controller.sourceEligible(story))
                      TextButton(
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (_) => BusinessContactSheet(
                            controller: controller,
                            story: story,
                          ),
                        ),
                        child: const Text(BusinessCopy.reopenRoom),
                      ),
                  ],
                ),
              ),
      );
    },
  );
}
