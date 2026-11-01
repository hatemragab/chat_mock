enum PhotoVisibility { everyone, contacts, nobody }

enum StatusAudience { contacts, except, only }

enum MockPermission { allowed, denied, permanentlyDenied }

enum ContactMatchingState { idle, matching, matched, empty, denied, failed }

enum RestrictionLevel { warning, suspension, permanentBan }

enum NotificationKind { message, group, call }

/// The private identity details available to a particular viewer.
class PrivateProfilePresentation {
  const PrivateProfilePresentation({
    required this.displayName,
    required this.photoVisible,
  });
  final String displayName;
  final bool photoVisible;
}

class BusinessProfile {
  static const demoLogoAssetPath = 'assets/story/green_corner.png';
  static const demoCoverAssetPath = 'assets/story/maison_studio.png';
  const BusinessProfile({
    this.name = '',
    this.category = '',
    this.description = '',
    this.location = '',
    this.logoSelected = false,
    this.coverSelected = false,
  });

  final String name;
  final String category;
  final String description;
  final String location;
  final bool logoSelected;
  final bool coverSelected;

  /// Bundled illustrations used by the mock image selection flow.
  String? get logoAssetPath => logoSelected ? demoLogoAssetPath : null;
  String? get coverAssetPath => coverSelected ? demoCoverAssetPath : null;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      category.trim().isNotEmpty &&
      description.trim().isNotEmpty;
}
