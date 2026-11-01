import '../../copy/chats_copy.dart';
import '../../models/chat_models.dart';

/// Calendar and sender grouping shared by conversation timelines.
abstract final class ChatTimeline {
  static bool sameDay(DateTime first, DateTime second) {
    final a = first.toLocal();
    final b = second.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool groupsTogether(
    ChatMessage first,
    ChatMessage second, {
    required bool group,
    bool? firstIsMine,
    bool? secondIsMine,
  }) {
    if (first.kind == MessageKind.system ||
        second.kind == MessageKind.system ||
        !sameDay(first.time, second.time)) {
      return false;
    }
    if (!group) {
      return (firstIsMine ?? first.isMine) == (secondIsMine ?? second.isMine);
    }
    if (first.authorId != null && second.authorId != null) {
      return first.authorId == second.authorId;
    }
    return first.author == second.author;
  }

  static String dayLabel(DateTime timestamp, {DateTime? now}) {
    final date = timestamp.toLocal();
    final today = (now ?? DateTime.now()).toLocal();
    if (sameDay(date, today)) return ChatCopy.today;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    if (sameDay(date, yesterday)) return ChatCopy.yesterday;
    return ChatCopy.calendarDate(date);
  }
}
