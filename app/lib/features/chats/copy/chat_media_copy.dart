/// English copy for editing bundled chat attachments.
abstract final class ChatMediaCopy {
  static const caption = 'Caption';
  static const addCaption = 'Add a caption';
  static const replaceMedia = 'Replace media';
  static const chooseSample = 'Choose a bundled sample';
  static const cover = 'Cover';
  static const originalCover = 'Original';
  static const artworkCover = 'Artwork';
  static const changeCover = 'Change cover';
  static const unavailable =
      'This conversation cannot accept messages right now. Your draft is preserved.';
  static String rotate(int degrees) => 'Rotate ($degrees°)';
  static String cropZoom(int percent) => 'Crop zoom: $percent%';
  static String trim(int start, int end) => 'Trim: $start% – $end%';
}
