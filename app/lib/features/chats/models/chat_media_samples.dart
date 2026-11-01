import 'chat_models.dart';

/// Resolves the bundled illustration represented by a mock attachment.
abstract final class ChatMediaSamples {
  static const _images = [
    'assets/story/green_corner.png',
    'assets/story/maison_studio.png',
    'assets/story/daily_brew.png',
  ];

  static String? assetFor(
    MessageKind kind,
    String name, {
    bool artworkCover = false,
  }) {
    if (kind != MessageKind.photo && kind != MessageKind.video) return null;
    final original = _originalAsset(kind, name);
    return artworkCover
        ? (original == _images[1] ? _images[0] : _images[1])
        : original;
  }

  static String _originalAsset(MessageKind kind, String name) {
    final value = name.toLowerCase();
    if (value.contains('garden')) return _images[0];
    if (value.contains('studio')) return _images[1];
    if (kind == MessageKind.video) return _images[2];
    if (value.contains('camera')) return _images[1];
    if (value == 'sample photo' || value == 'photo') return _images[0];
    final index =
        name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % _images.length;
    return _images[index];
  }

  static List<String> replacementNamesFor(MessageKind kind) =>
      kind == MessageKind.video
      ? const ['Sample video', 'Garden video', 'Studio video']
      : const ['Sample photo', 'Garden photo', 'Studio photo'];

  static Duration durationFor(ChatMessage message) {
    final match = RegExp(r'\b(\d{1,2}):(\d{2})\b').firstMatch(message.text);
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final total = minutes * 60 + seconds;
      if (seconds < 60 && total > 0) return Duration(seconds: total);
    }
    return Duration(seconds: message.kind == MessageKind.video ? 30 : 18);
  }
}
