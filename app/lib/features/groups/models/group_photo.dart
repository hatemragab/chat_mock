/// Bundled artwork available for a group's session-only photo.
enum GroupPhoto {
  none(null),
  garden('assets/story/green_corner.png'),
  studio('assets/story/maison_studio.png'),
  cafe('assets/story/daily_brew.png');

  const GroupPhoto(this.assetPath);
  final String? assetPath;

  static GroupPhoto fromAsset(String? asset) => values.firstWhere(
    (photo) => photo.assetPath == asset,
    orElse: () => none,
  );
}
