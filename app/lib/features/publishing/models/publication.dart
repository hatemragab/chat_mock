enum PublicationType { status, advertisement }

enum PublicationMedia { photo, video, audio }

enum PublicationStatus { active, expired, removed }

class PublicationViewer {
  const PublicationViewer({
    required this.id,
    required this.name,
    required this.viewedAt,
  });
  final String id;
  final String name;
  final DateTime viewedAt;
}

class PublishingConfig {
  const PublishingConfig({
    this.categoryFee = 5,
    this.boostFee = 50,
    this.advertisementFee = 100,
    this.photoSlots = 3,
    this.popularThreshold = 50,
    this.qualifiedViewsPerDiamond = 50,
    this.diamondsPerReward = 1,
  });
  final int categoryFee;
  final int boostFee;
  final int advertisementFee;
  final int photoSlots;
  final int popularThreshold;

  /// Mock-only reward terms, captured when a publication is created.
  final int qualifiedViewsPerDiamond;
  final int diamondsPerReward;
}

class PriceReview {
  const PriceReview({
    required this.category,
    required this.boost,
    required this.advertisement,
    required this.revision,
  });
  final int category;
  final int boost;
  final int advertisement;
  final int revision;
  int get total => category + boost + advertisement;
}

class PublicationDraft {
  PublicationDraft({required this.id, required this.type});
  final String id;
  final PublicationType type;
  String category = 'Everyday';
  bool paidCategory = false;
  PublicationMedia media = PublicationMedia.photo;
  String sample = 'Morning light';
  String caption = '';
  bool boosted = false;
  int rotation = 0;
  double cropScale = 1;
  double trimStart = 0;
  double trimEnd = 1;
  String cover = 'Default';
  String location = 'Cameroon';
  String country = 'Cameroon';
  String city = '';
  String neighbourhood = '';
  double radiusKm = 10;
  String gender = 'Everyone';
  String interest = 'Lifestyle';
  bool get requiresBoost => media != PublicationMedia.photo;
  bool get effectiveBoost => requiresBoost || boosted;
  bool get consumesSlot =>
      type == PublicationType.status && media == PublicationMedia.photo;
}

class Publication {
  Publication({
    required this.id,
    required this.type,
    required this.category,
    required this.media,
    required this.caption,
    required this.sample,
    required this.boosted,
    required this.price,
    required this.createdAt,
    required this.expiresAt,
    required this.consumesSlot,
    this.rotation = 0,
    this.cropScale = 1,
    this.trimStart = 0,
    this.trimEnd = 1,
    this.cover = 'Default',
    this.location = 'Cameroon',
    this.country = 'Cameroon',
    this.city = '',
    this.neighbourhood = '',
    this.radiusKm = 10,
    this.gender = 'Everyone',
    this.interest = 'Lifestyle',
    this.qualifiedViewsPerDiamond = 50,
    this.diamondsPerReward = 1,
  });
  final String id;
  final PublicationType type;
  final String category;
  final PublicationMedia media;
  final String caption;
  final String sample;
  final bool boosted;
  final PriceReview price;
  final DateTime createdAt;
  DateTime expiresAt;
  final bool consumesSlot;
  final int rotation;
  final double cropScale;
  final double trimStart;
  final double trimEnd;
  final String cover;
  final String location;
  final String country;
  final String city;
  final String neighbourhood;
  final double radiusKm;
  final String gender;
  final String interest;
  final int qualifiedViewsPerDiamond;
  final int diamondsPerReward;
  final Map<String, PublicationViewer> contactViewers = {};
  final Set<String> countedViewers = {};

  /// Qualified views grouped by local calendar day, without viewer identities.
  final Map<String, int> qualifiedViewsByDay = {};
  PublicationStatus status = PublicationStatus.active;
  bool extended = false;
  int totalViews = 0;
  int qualifiedViews = 0;
  int heldViews = 0;
  int pendingDiamondRewards = 0;
}
