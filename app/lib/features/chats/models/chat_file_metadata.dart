/// In-session metadata for a simulated file; no disk or network access occurs.
class ChatFileMetadata {
  const ChatFileMetadata({
    required this.fileName,
    required this.mimeType,
    required this.byteLength,
  }) : assert(byteLength >= 0);

  factory ChatFileMetadata.sample(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    final (mimeType, byteLength) = switch (extension) {
      'pdf' => ('application/pdf', 256 * 1024),
      'txt' => ('text/plain', 4 * 1024),
      'sketch' => ('application/x-sketch', 2 * 1024 * 1024),
      _ => ('application/octet-stream', 512 * 1024),
    };
    return ChatFileMetadata(
      fileName: fileName,
      mimeType: mimeType,
      byteLength: byteLength,
    );
  }

  final String fileName;
  final String mimeType;
  final int byteLength;

  bool get supportsPreview =>
      mimeType == 'application/pdf' || mimeType == 'text/plain';
}
