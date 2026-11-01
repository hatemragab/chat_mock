import 'chat_media_edits.dart';
import 'chat_models.dart';

/// A confirmed local selection; closing its editor never mutates a conversation.
class ChatAttachmentDraft {
  const ChatAttachmentDraft({
    required this.kind,
    required this.name,
    this.assetPath,
    this.mediaEdits,
  });

  final MessageKind kind;
  final String name;
  final String? assetPath;
  final ChatMediaEdits? mediaEdits;
}
