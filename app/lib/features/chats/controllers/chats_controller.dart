import 'dart:async';

import 'package:flutter/foundation.dart';

import '../copy/chats_copy.dart';
import '../models/chat_media_samples.dart';
import '../models/chat_media_edits.dart';
import '../models/chat_file_metadata.dart';
import '../models/chat_models.dart';

class ChatsController extends ChangeNotifier {
  ChatsController() {
    reset();
  }

  final List<ChatConversation> conversations = [];
  final Map<String, bool Function()> _sendGuards = {};
  final Map<String, (String, String) Function()> _sendIdentities = {};
  final Map<String, List<MessageRecipientReceipt> Function(String?)>
  _groupRecipientProviders = {};
  final Map<String, Timer> _uploadTimers = {};
  final Map<String, Timer> _muteTimers = {};
  final Map<String, String> _drafts = {};
  bool online = true;
  bool failNextUpload = false;

  /// An optional app-wide restriction in addition to per-room permissions.
  bool Function()? canMessage;

  /// Reads the session privacy preference when a conversation is opened.
  bool Function()? readReceiptsEnabled;
  void Function(ChatConversation chat, bool video)? onStartCall;
  void Function(ChatConversation chat, ChatMessage message)? onIncomingMessage;
  int _nextId = 0;

  String draftFor(String conversationId) => _drafts[conversationId] ?? '';

  /// Draft updates do not notify the whole conversation on every keystroke.
  void setDraft(String conversationId, String text) {
    if (text.isEmpty) {
      _drafts.remove(conversationId);
    } else {
      _drafts[conversationId] = text;
    }
  }

  void reset() {
    // Remove room callbacks before replacing the conversation fixtures.
    removeBusinessConversations();
    for (final timer in _muteTimers.values) {
      timer.cancel();
    }
    _muteTimers.clear();
    for (final timer in _uploadTimers.values) {
      timer.cancel();
    }
    _uploadTimers.clear();
    _drafts.clear();
    failNextUpload = false;
    _nextId = 0;
    final now = DateTime.now();
    ChatMessage message(
      String author,
      String text,
      int minutes, {
      bool mine = false,
      MessageKind kind = MessageKind.text,
      String? authorId,
    }) => ChatMessage(
      id: 'm${_nextId++}',
      author: author,
      authorId: authorId,
      text: text,
      time: now.subtract(Duration(minutes: minutes)),
      isMine: mine,
      kind: kind,
      assetPath: ChatMediaSamples.assetFor(kind, text),
      status: mine ? DeliveryStatus.read : DeliveryStatus.delivered,
    );
    conversations
      ..clear()
      ..addAll([
        ChatConversation(
          id: 'sarah',
          name: 'Sarah Wilson',
          kind: ChatKind.contact,
          phone: '+1 202 555 0101',
          subtitle: 'Online',
          unread: 2,
          messages: [
            message('Sarah', 'Hey Alex! How did the meeting go?', 45),
            message(
              'Alex',
              'It went really well! I’ll share the details with you.',
              42,
              mine: true,
            ),
            message('Sarah', 'That’s great news ✨', 20),
            message('Sarah', 'Are we still meeting later?', 18),
          ],
        ),
        ChatConversation(
          id: 'design',
          name: 'Design Team',
          kind: ChatKind.group,
          subtitle: 'Sarah, Amira, John and you',
          unread: 3,
          messages: [
            message(
              'Amira',
              'The new concepts are ready for review.',
              120,
              authorId: 'amira',
            ),
            message(
              'Alex',
              'Looking good! Thanks for sharing.',
              110,
              mine: true,
              authorId: 'alex',
            ),
            message(
              'Alex',
              'I will review the final details today.',
              90,
              mine: true,
              authorId: 'alex',
            ),
            message(
              'Sarah',
              'Design review.pdf',
              65,
              kind: MessageKind.document,
              authorId: 'sarah',
            ),
          ],
        ),
        ChatConversation(
          id: 'amira',
          name: 'Amira Hassan',
          kind: ChatKind.contact,
          phone: '+1 202 555 0102',
          subtitle: 'Hey there! I’m using Whizpee.',
          messages: [
            message('Amira', 'Thanks for the lovely afternoon 💛', 150),
          ],
        ),
        ChatConversation(
          id: 'john',
          name: 'John Davis',
          kind: ChatKind.contact,
          phone: '+1 202 555 0103',
          messages: [message('John', 'See you soon!', 1440)],
        ),
        ChatConversation(
          id: 'karim',
          name: 'Karim Diallo',
          kind: ChatKind.contact,
          phone: '+1 202 555 0104',
          messages: [message('Karim', 'Let’s catch up this week.', 2880)],
        ),
        ChatConversation(
          id: 'maya',
          name: 'Maya Chen',
          kind: ChatKind.contact,
          phone: '+1 202 555 0105',
          messages: [message('Maya', 'Photo', 4320, kind: MessageKind.photo)],
        ),
        ChatConversation(
          id: 'leo',
          name: 'Leo Martin',
          kind: ChatKind.contact,
          phone: '+1 202 555 0106',
          messages: [
            message('Leo', 'Voice note · 0:18', 6000, kind: MessageKind.audio),
          ],
        ),
      ]);
    online = true;
    notifyListeners();
  }

  ChatConversation byId(String id) =>
      conversations.firstWhere((chat) => chat.id == id);

  ChatConversation? businessConversation(String storyId) {
    for (final chat in conversations) {
      if (chat.kind == ChatKind.business && chat.sourceStoryId == storyId) {
        return chat;
      }
    }
    return null;
  }

  ChatConversation ensureBusinessConversation(String storyId, String name) {
    final existing = businessConversation(storyId);
    if (existing != null) return existing;
    final chat = ChatConversation(
      id: 'business-${_nextId++}',
      name: name,
      kind: ChatKind.business,
      sourceStoryId: storyId,
      subtitle: ChatCopy.businessStoryConversation,
      messages: [],
    );
    conversations.add(chat);
    return chat;
  }

  /// Used after mutations by the owner of a shared conversation's messages.
  void refreshConversations() => notifyListeners();

  void removeBusinessConversations() {
    for (final chat in conversations.where(
      (chat) => chat.kind == ChatKind.business,
    )) {
      for (final message in chat.messages) {
        _uploadTimers.remove(message.id)?.cancel();
      }
    }
    final ids = conversations
        .where((chat) => chat.kind == ChatKind.business)
        .map((chat) => chat.id)
        .toList();
    for (final id in ids) {
      _sendGuards.remove(id);
      _sendIdentities.remove(id);
      _drafts.remove(id);
    }
    conversations.removeWhere((chat) => chat.kind == ChatKind.business);
  }

  void setSendGuard(String chatId, bool Function()? guard) {
    if (guard == null) {
      _sendGuards.remove(chatId);
    } else {
      _sendGuards[chatId] = guard;
    }
  }

  void setSendIdentity(String chatId, (String, String) Function()? identity) {
    if (identity == null) {
      _sendIdentities.remove(chatId);
    } else {
      _sendIdentities[chatId] = identity;
    }
  }

  void setGroupRecipientProvider(
    String chatId,
    List<MessageRecipientReceipt> Function(String? authorId)? provider,
  ) {
    if (provider == null) {
      _groupRecipientProviders.remove(chatId);
    } else {
      _groupRecipientProviders[chatId] = provider;
    }
  }

  /// Contact communication is available only for mutual, unblocked fixtures.
  bool canCommunicateWithContact(ChatConversation chat) =>
      conversations.contains(chat) &&
      chat.kind == ChatKind.contact &&
      chat.mutuallyMatched &&
      !chat.blocked;

  bool canSendTo(ChatConversation chat) =>
      conversations.contains(chat) &&
      !chat.blocked &&
      (chat.kind != ChatKind.contact || canCommunicateWithContact(chat)) &&
      (canMessage?.call() ?? true) &&
      (_sendGuards[chat.id]?.call() ?? true);

  void renameConversation(String id, String name) {
    final chat = byId(id);
    if (chat.name == name) return;
    chat.name = name;
    notifyListeners();
  }

  void updateSubtitle(String id, String subtitle) {
    final chat = byId(id);
    if (chat.subtitle == subtitle) return;
    chat.subtitle = subtitle;
    notifyListeners();
  }

  void setConversationAvatar(String id, String? asset) {
    final chat = byId(id);
    if (chat.avatarAsset == asset) return;
    chat.avatarAsset = asset;
    notifyListeners();
  }

  ChatConversation addContact(String name, String phone) {
    final contact = ChatConversation(
      id: 'contact${_nextId++}',
      name: name.trim(),
      subtitle: phone.trim(),
      phone: phone.trim(),
      kind: ChatKind.contact,
      messages: [],
      mutuallyMatched: false,
      hidden: true,
    );
    conversations.add(contact);
    notifyListeners();
    return contact;
  }

  bool updateContact(ChatConversation contact, String name, String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (!conversations.contains(contact) ||
        contact.kind != ChatKind.contact ||
        name.trim().isEmpty ||
        digits.length < 7 ||
        digits.length > 15 ||
        conversations.any(
          (other) =>
              other != contact &&
              other.kind == ChatKind.contact &&
              (other.phone ?? '').replaceAll(RegExp(r'\D'), '') == digits,
        )) {
      return false;
    }
    if (contact.subtitle == contact.phone) contact.subtitle = phone.trim();
    contact.name = name.trim();
    contact.phone = phone.trim();
    notifyListeners();
    return true;
  }

  ChatConversation addGroup(String name) {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError(ChatCopy.groupNameRequired);
    final group = ChatConversation(
      id: 'group${_nextId++}',
      name: value,
      kind: ChatKind.group,
      messages: [],
    );
    conversations.add(group);
    notifyListeners();
    return group;
  }

  void markRead(ChatConversation chat) {
    if (chat.unread == 0 && !chat.hidden) return;
    chat.hidden = false;
    chat.unread = 0;
    if (readReceiptsEnabled?.call() ?? true) {
      for (final message in chat.messages) {
        if (!message.isMine &&
            (message.status == DeliveryStatus.sent ||
                message.status == DeliveryStatus.delivered)) {
          message.status = DeliveryStatus.read;
        }
      }
    }
    notifyListeners();
  }

  /// Advances a single outgoing direct message without duplicating it.
  /// Receipt progression is deliberately controlled by the demo clock/tools.
  bool advanceDirectReceipt(
    ChatConversation chat,
    ChatMessage message,
    DeliveryStatus next, {
    DateTime? at,
  }) {
    if (!online ||
        !conversations.contains(chat) ||
        !canCommunicateWithContact(chat) ||
        !chat.messages.contains(message) ||
        !message.isMine ||
        message.deleted) {
      return false;
    }
    final time = at ?? DateTime.now();
    if (next == DeliveryStatus.delivered &&
        message.status == DeliveryStatus.sent) {
      message.status = DeliveryStatus.delivered;
      message.deliveredAt = time;
    } else if (next == DeliveryStatus.read &&
        message.status == DeliveryStatus.delivered &&
        (readReceiptsEnabled?.call() ?? true)) {
      message.status = DeliveryStatus.read;
      message.readAt = time;
    } else {
      return false;
    }
    notifyListeners();
    return true;
  }

  ChatMessage? send(
    ChatConversation chat,
    String text, {
    ChatMessage? reply,
    String? author,
    String? authorId,
    MessageKind kind = MessageKind.text,
    bool upload = false,
    List<String>? mentionedMemberIds,
    String? assetPath,
    ChatMediaEdits? mediaEdits,
    ChatFileMetadata? fileMetadata,
  }) {
    final value = text.trim();
    if (value.isEmpty || !canSendTo(chat)) return null;
    chat.hidden = false;
    final identity = _sendIdentities[chat.id]?.call();
    final message = ChatMessage(
      id: 'm${_nextId++}',
      author: author ?? identity?.$2 ?? 'Alex',
      authorId: authorId ?? identity?.$1,
      recipients: _groupRecipientProviders[chat.id]?.call(
        authorId ?? identity?.$1,
      ),
      mentionedMemberIds: mentionedMemberIds,
      text: value,
      time: DateTime.now(),
      isMine: true,
      quote: reply == null ? null : ChatCopy.quote(reply.author, reply.text),
      kind: kind,
      assetPath: assetPath ?? ChatMediaSamples.assetFor(kind, value),
      mediaEdits: mediaEdits,
      fileMetadata:
          fileMetadata ??
          (kind == MessageKind.document
              ? ChatFileMetadata.sample(value)
              : null),
      uploadState: upload
          ? (online ? UploadState.uploading : UploadState.queued)
          : UploadState.none,
      status: online
          ? (upload ? DeliveryStatus.sending : DeliveryStatus.sent)
          : DeliveryStatus.queued,
    );
    chat.messages.add(message);
    if (upload && online) _scheduleUpload(message);
    notifyListeners();
    return message;
  }

  /// Adds a local incoming contact message for the demo session.
  ChatMessage? receiveContactMessage(ChatConversation chat, String text) {
    final value = text.trim();
    if (!online ||
        value.isEmpty ||
        !canCommunicateWithContact(chat) ||
        !(canMessage?.call() ?? true)) {
      return null;
    }
    final message = ChatMessage(
      id: 'm${_nextId++}',
      author: chat.name,
      text: value,
      time: DateTime.now(),
      isMine: false,
      status: DeliveryStatus.delivered,
    );
    chat.messages.add(message);
    chat.unread++;
    chat.hidden = false;
    onIncomingMessage?.call(chat, message);
    notifyListeners();
    return message;
  }

  void setOnline(bool value) {
    online = value;
    for (final chat in conversations) {
      for (final message in chat.messages) {
        if (!value && message.uploadState == UploadState.uploading) {
          _uploadTimers.remove(message.id)?.cancel();
          message.uploadState = UploadState.queued;
          message.status = DeliveryStatus.queued;
        } else if (value &&
            message.uploadState == UploadState.queued &&
            canSendTo(chat)) {
          message.uploadState = UploadState.uploading;
          message.status = DeliveryStatus.sending;
          _scheduleUpload(message);
        } else if (value &&
            message.status == DeliveryStatus.queued &&
            canSendTo(chat)) {
          message.status = DeliveryStatus.sent;
        }
      }
    }
    notifyListeners();
  }

  void retry(ChatMessage message) {
    if (message.status != DeliveryStatus.failed &&
        message.status != DeliveryStatus.queued) {
      return;
    }
    final chat = _chatForMessage(message);
    if (chat == null || !canSendTo(chat)) return;
    if (message.uploadState == UploadState.failed ||
        message.uploadState == UploadState.queued) {
      if (message.uploadState == UploadState.failed) message.uploadProgress = 0;
      message.uploadState = online ? UploadState.uploading : UploadState.queued;
      message.status = online ? DeliveryStatus.sending : DeliveryStatus.queued;
      if (online) _scheduleUpload(message);
    } else {
      message.status = online ? DeliveryStatus.sent : DeliveryStatus.queued;
    }
    notifyListeners();
  }

  void _scheduleUpload(ChatMessage message) {
    _uploadTimers.remove(message.id)?.cancel();
    _uploadTimers[message.id] = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => advanceUpload(message),
    );
  }

  ChatConversation? _chatForMessage(ChatMessage message) {
    for (final chat in conversations) {
      if (chat.messages.contains(message)) return chat;
    }
    return null;
  }

  /// Advances a mock upload; also usable by deterministic prototype tests.
  void advanceUpload(ChatMessage message) {
    if (message.uploadState != UploadState.uploading) return;
    final chat = _chatForMessage(message);
    if (chat == null || !canSendTo(chat)) {
      _uploadTimers.remove(message.id)?.cancel();
      message.uploadState = UploadState.queued;
      message.status = DeliveryStatus.queued;
      notifyListeners();
      return;
    }
    message.uploadProgress = (message.uploadProgress + .25).clamp(0, 1);
    if (message.uploadProgress >= 1) {
      _uploadTimers.remove(message.id)?.cancel();
      if (failNextUpload) {
        failNextUpload = false;
        message.uploadState = UploadState.failed;
        message.status = DeliveryStatus.failed;
      } else {
        message.uploadState = UploadState.complete;
        message.status = DeliveryStatus.sent;
      }
    }
    notifyListeners();
  }

  bool edit(ChatMessage message, String text, {bool? ownOverride}) {
    if (!(ownOverride ?? message.isMine) ||
        message.deleted ||
        text.trim().isEmpty) {
      return false;
    }
    message.text = text.trim();
    notifyListeners();
    return true;
  }

  void delete(
    ChatConversation chat,
    ChatMessage message, {
    bool forEveryone = false,
    bool? ownOverride,
  }) {
    if (!forEveryone || (ownOverride ?? message.isMine)) {
      _uploadTimers.remove(message.id)?.cancel();
    }
    if (forEveryone) {
      if (!(ownOverride ?? message.isMine) || message.deleted) return;
      message.deleted = true;
      message.uploadState = UploadState.none;
      message.text = ChatCopy.messageDeleted;
      message.reaction = null;
      message.starred = false;
      message.pinned = false;
    } else {
      chat.messages.remove(message);
    }
    notifyListeners();
  }

  void toggleStar(ChatMessage message) {
    if (!message.deleted) {
      message.starred = !message.starred;
      notifyListeners();
    }
  }

  void togglePin(ChatMessage message) {
    if (!message.deleted) {
      message.pinned = !message.pinned;
      notifyListeners();
    }
  }

  void react(ChatMessage message, String? reaction) {
    if (!message.deleted) {
      message.reaction = reaction;
      notifyListeners();
    }
  }

  void archive(ChatConversation chat) {
    chat.archived = !chat.archived;
    notifyListeners();
  }

  void togglePinned(ChatConversation chat) {
    chat.pinned = !chat.pinned;
    notifyListeners();
  }

  void toggleMuted(ChatConversation chat) {
    _muteTimers.remove(chat.id)?.cancel();
    chat.muted = !chat.muted;
    notifyListeners();
  }

  void muteFor(ChatConversation chat, Duration? duration) {
    _muteTimers.remove(chat.id)?.cancel();
    chat.muteFor(duration);
    if (duration != null) {
      _muteTimers[chat.id] = Timer(duration, () {
        _muteTimers.remove(chat.id);
        if (conversations.contains(chat)) {
          chat.muted = false;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void unmute(ChatConversation chat) {
    _muteTimers.remove(chat.id)?.cancel();
    chat.muted = false;
    notifyListeners();
  }

  /// Deletes local chat history while preserving contact and room identities.
  void deleteConversation(ChatConversation chat) {
    _drafts.removeWhere(
      (id, _) => id == chat.id || id.startsWith('${chat.id}:member:'),
    );
    for (final message in chat.messages) {
      _uploadTimers.remove(message.id)?.cancel();
    }
    chat.messages.clear();
    chat.unread = 0;
    chat.archived = false;
    chat.hidden = true;
    notifyListeners();
  }

  void toggleBlocked(ChatConversation chat) {
    chat.blocked = !chat.blocked;
    notifyListeners();
  }

  void setUnread(ChatConversation chat, bool unread) {
    chat.unread = unread ? 1 : 0;
    notifyListeners();
  }

  void forward(ChatMessage message, Iterable<ChatConversation> recipients) {
    if (message.deleted) return;
    for (final chat in recipients) {
      send(
        chat,
        message.text,
        kind: message.kind,
        assetPath: message.assetPath,
        mediaEdits: message.mediaEdits,
        fileMetadata: message.fileMetadata,
        upload:
            message.kind != MessageKind.text &&
            message.kind != MessageKind.system,
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _muteTimers.values) {
      timer.cancel();
    }
    _muteTimers.clear();
    for (final timer in _uploadTimers.values) {
      timer.cancel();
    }
    _uploadTimers.clear();
    super.dispose();
  }
}
