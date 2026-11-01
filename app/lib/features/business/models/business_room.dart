import '../../chats/models/chat_models.dart';
import '../../stories/models/story.dart';

enum BusinessPerspective { customer, recipient }

enum OpenRoomResult {
  opened,
  alreadyActive,
  confirmationRequired,
  inProgress,
  sourceUnavailable,
  limitReached,
  insufficientCredits,
  recipientCannotOpen,
  blocked,
}

class BusinessConfig {
  const BusinessConfig({
    this.roomCredits = 10,
    this.roomDuration = const Duration(hours: 24),
    this.maxOpenings = 3,
    this.audioBlockCredits = 15,
    this.videoBlockCredits = 25,
  });
  final int roomCredits;
  final Duration roomDuration;
  final int maxOpenings;
  final int audioBlockCredits;
  final int videoBlockCredits;
}

class BusinessRoom {
  BusinessRoom({
    required this.story,
    required this.expiresAt,
    required this.openingCount,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
  final Story story;
  DateTime expiresAt;
  int openingCount;
  final List<ChatMessage> messages;
  bool isActiveAt(DateTime time) => time.isBefore(expiresAt);
}
