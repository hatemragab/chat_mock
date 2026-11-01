/// Public-only profile data used by Story-based Business interactions.
class PublicBusinessProfile {
  const PublicBusinessProfile({
    required this.name,
    required this.category,
    required this.description,
    this.location = '',
    this.coverAssetPath,
    this.logoAssetPath,
  });

  final String name;
  final String category;
  final String description;
  final String location;
  final String? coverAssetPath;
  final String? logoAssetPath;
}
