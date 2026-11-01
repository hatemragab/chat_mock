/// Immutable local edits copied from an attachment draft into a sent message.
class ChatMediaEdits {
  const ChatMediaEdits({
    this.caption = '',
    this.rotation = 0,
    this.cropScale = 1,
    this.trimStart = 0,
    this.trimEnd = 1,
    this.artworkCover = false,
  }) : assert(rotation >= 0 && rotation < 4),
       assert(cropScale >= 1 && cropScale <= 2),
       assert(trimStart >= 0 && trimStart < trimEnd && trimEnd <= 1);

  final String caption;
  final int rotation;
  final double cropScale;
  final double trimStart;
  final double trimEnd;
  final bool artworkCover;
}
