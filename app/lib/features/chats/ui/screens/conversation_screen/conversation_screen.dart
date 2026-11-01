import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/conversation_layout.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_mention_candidate.dart';
import '../../../models/chat_attachment_draft.dart';
import '../../../models/chat_media_edits.dart';
import '../../../models/chat_models.dart';
import '../../dialogs/delete_message_dialog/delete_message_dialog.dart';
import '../../navigation/chat_destination.dart';
import '../../sheets/attachment_sheet/attachment_sheet.dart';
import '../../sheets/message_actions_sheet/message_actions_sheet.dart';
import '../../sheets/reaction_picker_sheet/reaction_picker_sheet.dart';
import '../../utils/chat_timeline.dart';
import '../../widgets/chat_composer.dart';
import '../../widgets/chat_day_separator.dart';
import '../../widgets/message_bubble.dart';
import '../attachment_preview_screen/attachment_preview_screen.dart';
import '../chat_info_screen/chat_info_screen.dart';
import '../chat_search_screen/chat_search_screen.dart';
import '../media_viewer_screen/media_viewer_screen.dart';
import '../message_details_screen/message_details_screen.dart';
import '../recipient_picker_screen/recipient_picker_screen.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.controller,
    required this.chat,
    this.initialMessageId,
    this.composerEnabled = true,
    this.composerDisabledReason,
    this.onGroupSend,
    this.onInfo,
    this.specialMessageScreenBuilder,
    this.isOwnMessage,
    this.mentionCandidates = const [],
    this.initialDraft,
    this.draftId,
    this.initialReply,
    this.initialEdit,
    this.initialRecording = false,
    this.initialRecordingLocked = false,
  });
  final ChatsController controller;
  final ChatConversation chat;
  final String? initialMessageId;
  final bool composerEnabled;
  final String? composerDisabledReason;
  final ChatMessage? Function(String text, ChatMessage? reply)? onGroupSend;
  final VoidCallback? onInfo;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  final bool Function(ChatMessage message)? isOwnMessage;
  final List<ChatMentionCandidate> mentionCandidates;
  final String? initialDraft;

  /// Allows simulated group perspectives to retain separate session drafts.
  final String? draftId;
  final ChatMessage? initialReply;
  final ChatMessage? initialEdit;
  final bool initialRecording;
  final bool initialRecordingLocked;
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  ChatMessage? _reply;
  ChatMessage? _editing;
  final _scroll = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};
  bool get _canSend =>
      widget.composerEnabled && widget.controller.canSendTo(widget.chat);
  String get _draftId => widget.draftId ?? widget.chat.id;

  @override
  void didUpdateWidget(covariant ConversationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.draftId ?? oldWidget.chat.id) != _draftId) {
      _reply = null;
      _editing = null;
    }
  }

  @override
  void initState() {
    super.initState();
    final reply = widget.initialReply;
    final edit = widget.initialEdit;
    if (_canSend &&
        reply != null &&
        widget.chat.messages.contains(reply) &&
        !reply.deleted) {
      _reply = reply;
    }
    if (_canSend &&
        edit != null &&
        widget.chat.messages.contains(edit) &&
        !edit.deleted &&
        (widget.isOwnMessage?.call(edit) ?? edit.isMine)) {
      _editing = edit;
      _reply = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keyContext = _messageKeys[widget.initialMessageId]?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(keyContext, alignment: .4);
      } else if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _send(String value) {
    if (!_canSend) return false;
    bool sent;
    if (_editing != null) {
      sent = widget.controller.edit(
        _editing!,
        value,
        ownOverride: widget.isOwnMessage?.call(_editing!),
      );
    } else if (widget.onGroupSend != null) {
      sent = widget.onGroupSend!(value, _reply) != null;
    } else {
      sent = widget.controller.send(widget.chat, value, reply: _reply) != null;
    }
    if (!sent) return false;
    setState(() {
      _reply = null;
      _editing = null;
    });
    _scrollToBottom();
    return true;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendAttachment(
    MessageKind kind,
    String name, {
    String? assetPath,
    ChatMediaEdits? mediaEdits,
  }) {
    if (!_canSend) return;
    final message = widget.controller.send(
      widget.chat,
      name,
      reply: _reply,
      kind: kind,
      upload: true,
      assetPath: assetPath,
      mediaEdits: mediaEdits,
    );
    if (message == null) return;
    setState(() {
      _reply = null;
      _editing = null;
    });
    _scrollToBottom();
  }

  void _sendVoice(Duration duration) {
    final seconds = duration.inSeconds;
    _sendAttachment(MessageKind.audio, ChatCopy.voiceNote(seconds));
  }

  Future<void> _delete(ChatMessage message) async {
    final option = await showDialog<DeleteMessageChoice>(
      context: context,
      builder: (_) => DeleteMessageDialog(
        canDeleteForEveryone:
            (widget.isOwnMessage?.call(message) ?? message.isMine) &&
            !message.deleted &&
            _canSend,
      ),
    );
    if (option != null &&
        (option != DeleteMessageChoice.forEveryone || _canSend)) {
      widget.controller.delete(
        widget.chat,
        message,
        forEveryone: option == DeleteMessageChoice.forEveryone,
        ownOverride: widget.isOwnMessage?.call(message),
      );
    }
  }

  Future<void> _actions(ChatMessage message) async {
    final choice = await showModalBottomSheet<MessageActionSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => MessageActionsSheet(
        message: message,
        canSend: _canSend,
        isOwn: widget.isOwnMessage?.call(message) ?? message.isMine,
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice.$1) {
      case MessageAction.react:
        if (_canSend && !message.deleted) {
          widget.controller.react(
            message,
            message.reaction == choice.$2 ? null : choice.$2,
          );
        }
      case MessageAction.moreReactions:
        final selected = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (_) =>
              ReactionPickerSheet(currentReaction: message.reaction),
        );
        if (selected != null && mounted && _canSend && !message.deleted) {
          widget.controller.react(
            message,
            selected.isEmpty || selected == message.reaction ? null : selected,
          );
        }
      case MessageAction.reply:
        if (_canSend && !message.deleted) {
          setState(() {
            _reply = message;
            _editing = null;
          });
        }
      case MessageAction.copy:
        if (!message.deleted) {
          await Clipboard.setData(ClipboardData(text: message.text));
        }
      case MessageAction.edit:
        if (_canSend &&
            !message.deleted &&
            (widget.isOwnMessage?.call(message) ?? message.isMine)) {
          setState(() {
            _editing = message;
            _reply = null;
          });
        }
      case MessageAction.forward:
        if (message.deleted) return;
        final recipients = await Navigator.push<List<ChatConversation>>(
          context,
          MaterialPageRoute(
            builder: (_) => RecipientPickerScreen(
              controller: widget.controller,
              multiSelect: true,
              includeGroups: true,
            ),
          ),
        );
        if (recipients != null && mounted) {
          widget.controller.forward(message, recipients);
        }
      case MessageAction.star:
        widget.controller.toggleStar(message);
      case MessageAction.pin:
        widget.controller.togglePin(message);
      case MessageAction.retry:
        widget.controller.retry(message);
      case MessageAction.info:
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MessageDetailsScreen(
              message: message,
              group: widget.chat.kind == ChatKind.group,
              canSeeGroupReceipts:
                  widget.isOwnMessage?.call(message) ?? message.isMine,
              updates: widget.controller,
            ),
          ),
        );
      case MessageAction.delete:
        await _delete(message);
    }
  }

  Future<void> _attachments() async {
    final selected = await showModalBottomSheet<(MessageKind, String)>(
      context: context,
      showDragHandle: true,
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
          canSend: () => _canSend,
        ),
      ),
    );
    if (mounted && confirmed != null) {
      _sendAttachment(
        confirmed.kind,
        confirmed.name,
        assetPath: confirmed.assetPath,
        mediaEdits: confirmed.mediaEdits,
      );
    }
  }

  Widget _messageAt(BuildContext context, int index) {
    final messages = widget.chat.messages;
    final message = messages[index];
    final previous = index == 0 ? null : messages[index - 1];
    final next = index + 1 == messages.length ? null : messages[index + 1];
    bool grouped(ChatMessage first, ChatMessage second) =>
        ChatTimeline.groupsTogether(
          first,
          second,
          group: widget.chat.kind == ChatKind.group,
          firstIsMine: widget.isOwnMessage?.call(first),
          secondIsMine: widget.isOwnMessage?.call(second),
        );
    final bubble = MessageBubble(
      key: _messageKeys.putIfAbsent(message.id, GlobalKey.new),
      message: message,
      group: widget.chat.kind == ChatKind.group,
      isMine: widget.isOwnMessage?.call(message),
      groupedWithPrevious: previous != null && grouped(previous, message),
      groupedWithNext: next != null && grouped(message, next),
      highlight: widget.initialMessageId == message.id,
      onLongPress: () => _actions(message),
      onTap:
          message.kind == MessageKind.text ||
              message.kind == MessageKind.system ||
              message.uploadState == UploadState.uploading ||
              message.uploadState == UploadState.queued ||
              message.uploadState == UploadState.failed
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (viewerContext) => MediaViewerScreen(
                  message: message,
                  onShowSource: () => Navigator.pop(viewerContext),
                ),
              ),
            ),
      onRetry: () => widget.controller.retry(message),
    );
    if (previous != null && ChatTimeline.sameDay(previous.time, message.time)) {
      return bubble;
    }
    return Column(
      children: [
        ChatDaySeparator(time: message.time),
        bubble,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      return ConversationLayout(
        header: AppHeader(
          toolbarHeight: AppGeometry.conversationHeaderHeight,
          titleSpacing: 0,
          title: InkWell(
            onTap:
                widget.onInfo ??
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChatInfoScreen(
                      controller: widget.controller,
                      chat: widget.chat,
                    ),
                  ),
                ),
            child: Row(
              children: [
                AppAvatar(
                  name: widget.chat.name,
                  radius: 18,
                  image: widget.chat.avatarAsset == null
                      ? null
                      : AssetImage(widget.chat.avatarAsset!),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.chat.blocked
                            ? ChatCopy.blocked
                            : widget.chat.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (widget.chat.kind == ChatKind.contact &&
                widget.controller.onStartCall != null) ...[
              IconButton(
                tooltip: ChatCopy.audioCall,
                onPressed:
                    !widget.controller.canCommunicateWithContact(widget.chat)
                    ? null
                    : () => widget.controller.onStartCall!(widget.chat, false),
                icon: const Icon(Icons.call_outlined),
              ),
              IconButton(
                tooltip: ChatCopy.videoCall,
                onPressed:
                    !widget.controller.canCommunicateWithContact(widget.chat)
                    ? null
                    : () => widget.controller.onStartCall!(widget.chat, true),
                icon: const Icon(Icons.videocam_outlined),
              ),
            ],
            IconButton(
              tooltip: ChatCopy.searchConversation,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChatSearchScreen(
                    controller: widget.controller,
                    chat: widget.chat,
                    specialMessageScreenBuilder:
                        widget.specialMessageScreenBuilder,
                  ),
                ),
              ),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: ChatCopy.conversationInfo,
              onPressed:
                  widget.onInfo ??
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ChatInfoScreen(
                        controller: widget.controller,
                        chat: widget.chat,
                      ),
                    ),
                  ),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        contextBanner: !widget.controller.online
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Text(
                  ChatCopy.offlineQueueDescription,
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        messageCount: widget.chat.messages.length,
        messageBuilder: _messageAt,
        scrollController: _scroll,
        buildAllMessages: widget.initialMessageId != null,
        composerNotice:
            (!widget.composerEnabled &&
                    widget.composerDisabledReason != null) ||
                (widget.chat.kind == ChatKind.contact &&
                    !widget.chat.mutuallyMatched)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  !widget.chat.mutuallyMatched &&
                          widget.chat.kind == ChatKind.contact
                      ? ChatCopy.waitingForMutualContact
                      : widget.composerDisabledReason!,
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        composer: ChatComposer(
          key: ValueKey(_draftId),
          onSend: _send,
          onSendVoice: _sendVoice,
          onAttachment: _attachments,
          editText: _editing?.text,
          replyLabel: _reply == null
              ? null
              : ChatCopy.quote(_reply!.author, _reply!.text),
          onCancelContext: () => setState(() {
            _reply = null;
            _editing = null;
          }),
          enabled: _canSend,
          mentionCandidates: widget.mentionCandidates,
          initialDraft:
              widget.initialDraft ?? widget.controller.draftFor(_draftId),
          focusInitialDraft: widget.initialDraft != null,
          onDraftChanged: (text) => widget.controller.setDraft(_draftId, text),
          initialRecording: widget.initialRecording,
          initialRecordingLocked: widget.initialRecordingLocked,
        ),
      );
    },
  );
}
