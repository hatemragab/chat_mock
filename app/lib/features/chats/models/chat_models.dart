import 'chat_file_metadata.dart';
import 'chat_media_edits.dart';

enum ChatKind { contact, group, business }

enum DeliveryStatus { queued, sending, sent, delivered, read, failed }

enum MessageKind { text, photo, video, document, audio, contact, system }

enum UploadState { none, queued, uploading, failed, complete }

enum RecipientDeliveryStatus { pending, delivered, read }

/// A snapshot of a recipient at the time a group message was sent.
class MessageRecipientReceipt {
  MessageRecipientReceipt({
    required this.memberId,
    required this.memberName,
    this.status = RecipientDeliveryStatus.pending,
    this.deliveredAt,
    this.readAt,
  });

  final String memberId;
  final String memberName;
  RecipientDeliveryStatus status;
  DateTime? deliveredAt;
  DateTime? readAt;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.time,
    required this.isMine,
    this.kind = MessageKind.text,
    this.status = DeliveryStatus.read,
    this.quote,
    this.starred = false,
    this.pinned = false,
    this.deleted = false,
    this.reaction,
    this.authorId,
    this.uploadState = UploadState.none,
    this.uploadProgress = 0,
    this.assetPath,
    this.mediaEdits,
    this.fileMetadata,
    this.deliveredAt,
    this.readAt,
    List<MessageRecipientReceipt>? recipients,
    List<String>? mentionedMemberIds,
  }) : recipients = recipients ?? [],
       mentionedMemberIds = List.unmodifiable(mentionedMemberIds ?? const []);

  final String id;
  final String author;
  final String? authorId;
  String text;
  final DateTime time;
  final bool isMine;
  final MessageKind kind;
  DeliveryStatus status;
  final String? quote;
  bool starred;
  bool pinned;
  bool deleted;
  String? reaction;
  UploadState uploadState;
  double uploadProgress;

  /// Bundled sample visual associated with this item; never a network URL.
  final String? assetPath;
  final ChatMediaEdits? mediaEdits;
  final ChatFileMetadata? fileMetadata;
  DateTime? deliveredAt;
  DateTime? readAt;
  final List<MessageRecipientReceipt> recipients;
  final List<String> mentionedMemberIds;
}

class ChatConversation {
  ChatConversation({
    required this.id,
    required this.name,
    required this.kind,
    required this.messages,
    this.sourceStoryId,
    this.subtitle = 'Available',
    this.unread = 0,
    this.archived = false,
    this.pinned = false,
    bool muted = false,
    this.blocked = false,
    this.hidden = false,
    this.mutuallyMatched = true,
    this.phone,
    this.avatarAsset,
    // The public named argument preserves the existing constructor API.
    // ignore: prefer_initializing_formals
  }) : _muted = muted;

  final String id;
  String name;
  final ChatKind kind;

  /// The originating public Story for a Business conversation.
  final String? sourceStoryId;
  final List<ChatMessage> messages;
  String subtitle;

  /// Phone number stored only in the current mock session.
  String? phone;

  /// Bundled identity artwork selected only for this mock session.
  String? avatarAsset;
  int unread;
  bool archived;
  bool pinned;
  bool _muted;
  DateTime? _mutedUntil;
  DateTime? get mutedUntil => _mutedUntil;
  bool get muted =>
      _muted && (_mutedUntil == null || DateTime.now().isBefore(_mutedUntil!));
  set muted(bool value) {
    _muted = value;
    _mutedUntil = null;
  }

  void muteFor(Duration? duration) {
    _muted = true;
    _mutedUntil = duration == null ? null : DateTime.now().add(duration);
  }

  bool hidden;
  bool blocked;

  /// Whether the local mock relationship is a mutual address-book match.
  final bool mutuallyMatched;
}
