import 'package:flutter/foundation.dart';

import '../copy/publishing_copy.dart';

import '../../creator_tools/controllers/creator_activity_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../models/publication.dart';

enum PublishResult {
  success,
  changedPrice,
  insufficientCredits,
  noSlots,
  failed,
  restricted,
  missingMedia,
  inProgress,
}

class PublishingController extends ChangeNotifier {
  PublishingController({
    required this.wallet,
    this.config = const PublishingConfig(),
    this.canPublish,
    this.canShareStatusWith,
    this.seedPublications = false,
    this.authorName,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _initialConfig = config {
    if (seedPublications) _seedPublications();
  }
  final WalletController wallet;
  final bool Function()? canPublish;
  final bool Function(String contactId)? canShareStatusWith;
  final bool seedPublications;
  final String Function()? authorName;
  String get currentAuthorName {
    final value = authorName?.call().trim();
    return value == null || value.isEmpty ? 'Alex Morgan' : value;
  }

  CreatorActivityController? _contactActivity;
  CreatorActivityController? get contactActivity => _contactActivity;

  void attachContactActivity(CreatorActivityController controller) {
    _contactActivity = controller;
    notifyListeners();
  }

  final DateTime Function() _clock;
  DateTime get now => _clock();
  PublishingConfig config;
  final PublishingConfig _initialConfig;
  int _revision = 0;
  int _sequence = 0;
  final List<Publication> _publications = [];
  final Set<String> _publishingIds = {};
  final Set<String> _rewardingIds = {};
  List<Publication> get publications =>
      List.unmodifiable(_publications.reversed);
  int get usedPhotoSlots => _publications
      .where(
        (p) =>
            p.consumesSlot &&
            p.status == PublicationStatus.active &&
            p.expiresAt.isAfter(_clock()),
      )
      .length;
  int get availablePhotoSlots =>
      (config.photoSlots - usedPhotoSlots).clamp(0, config.photoSlots);
  bool failNextPublish = false;

  void _seedPublications() {
    final now = _clock();
    const price = PriceReview(
      category: 0,
      boost: 0,
      advertisement: 0,
      revision: 0,
    );
    for (final fixture in [
      (id: 'seed-status-1', title: 'Morning light', ageHours: 6),
      (id: 'seed-status-2', title: 'A little moment', ageHours: 2),
    ]) {
      final created = now.subtract(Duration(hours: fixture.ageHours));
      _publications.add(
        Publication(
          id: fixture.id,
          type: PublicationType.status,
          category: 'Everyday',
          media: PublicationMedia.photo,
          caption: fixture.title,
          sample: fixture.title,
          boosted: false,
          price: price,
          createdAt: created,
          expiresAt: created.add(const Duration(hours: 24)),
          consumesSlot: true,
          qualifiedViewsPerDiamond: config.qualifiedViewsPerDiamond,
          diamondsPerReward: config.diamondsPerReward,
        ),
      );
    }
  }

  PublicationDraft createDraft(PublicationType type) =>
      PublicationDraft(id: 'publication-${++_sequence}', type: type);
  void updateConfig(PublishingConfig config) {
    this.config = config;
    _revision++;
    notifyListeners();
  }

  PriceReview review(PublicationDraft draft) => PriceReview(
    category: draft.paidCategory ? config.categoryFee : 0,
    boost: draft.effectiveBoost ? config.boostFee : 0,
    advertisement: draft.type == PublicationType.advertisement
        ? config.advertisementFee
        : 0,
    revision: _revision,
  );
  PublishResult publish(PublicationDraft draft, PriceReview reviewed) {
    if (_publications.any((p) => p.id == draft.id)) {
      return PublishResult.success;
    }
    if (_publishingIds.contains(draft.id)) return PublishResult.inProgress;
    if (draft.sample.trim().isEmpty) return PublishResult.missingMedia;
    if (!(canPublish?.call() ?? true)) return PublishResult.restricted;
    final current = review(draft);
    if (current.revision != reviewed.revision ||
        current.category != reviewed.category ||
        current.boost != reviewed.boost ||
        current.advertisement != reviewed.advertisement) {
      return PublishResult.changedPrice;
    }
    if (draft.consumesSlot && availablePhotoSlots == 0) {
      return PublishResult.noSlots;
    }
    if (current.total > wallet.credits) {
      return PublishResult.insufficientCredits;
    }
    if (failNextPublish) {
      failNextPublish = false;
      return PublishResult.failed;
    }
    _publishingIds.add(draft.id);
    try {
      if (current.total > 0 &&
          !wallet.spendCredits(
            id: draft.id,
            amount: current.total,
            description: PublishingCopy.publishedActivity(draft.type.name),
          )) {
        return PublishResult.insufficientCredits;
      }
      final now = _clock();
      _publications.add(
        Publication(
          id: draft.id,
          type: draft.type,
          category: draft.category,
          media: draft.media,
          caption: draft.caption,
          sample: draft.sample,
          boosted: draft.effectiveBoost,
          price: current,
          createdAt: now,
          expiresAt: now.add(Duration(hours: draft.effectiveBoost ? 48 : 24)),
          consumesSlot: draft.consumesSlot,
          rotation: draft.rotation,
          cropScale: draft.cropScale,
          trimStart: draft.trimStart,
          trimEnd: draft.trimEnd,
          cover: draft.cover,
          location: draft.location,
          country: draft.country,
          city: draft.city,
          neighbourhood: draft.neighbourhood,
          radiusKm: draft.radiusKm,
          gender: draft.gender,
          interest: draft.interest,
          qualifiedViewsPerDiamond: config.qualifiedViewsPerDiamond,
          diamondsPerReward: config.diamondsPerReward,
        ),
      );
      notifyListeners();
      return PublishResult.success;
    } finally {
      _publishingIds.remove(draft.id);
    }
  }

  /// Records a unique eligible view; owner views are excluded and suspicious
  /// views are held without exposing the viewer's identity.
  void recordView(
    Publication publication, {
    required String viewerId,
    required String viewerName,
    bool isOwner = false,
    bool suspicious = false,
  }) {
    if (publication.type == PublicationType.status &&
        !publication.boosted &&
        !(canShareStatusWith?.call(viewerId) ?? true)) {
      return;
    }
    if (!_publications.contains(publication) ||
        publication.status != PublicationStatus.active ||
        !publication.expiresAt.isAfter(_clock()) ||
        isOwner ||
        viewerId.isEmpty ||
        !publication.countedViewers.add(viewerId)) {
      return;
    }
    publication.totalViews++;
    if (suspicious) {
      publication.heldViews++;
    } else {
      publication.qualifiedViews++;
      final viewedAt = _clock();
      final day =
          '${viewedAt.year.toString().padLeft(4, '0')}-'
          '${viewedAt.month.toString().padLeft(2, '0')}-'
          '${viewedAt.day.toString().padLeft(2, '0')}';
      publication.qualifiedViewsByDay.update(
        day,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      _creditRewards(publication);
      if (!publication.boosted && publication.type == PublicationType.status) {
        publication.contactViewers[viewerId] = PublicationViewer(
          id: viewerId,
          name: viewerName,
          viewedAt: viewedAt,
        );
      }
    }
    notifyListeners();
  }

  void _creditRewards(Publication publication) {
    if ((!publication.boosted &&
            publication.type != PublicationType.advertisement) ||
        publication.qualifiedViewsPerDiamond <= 0 ||
        publication.diamondsPerReward <= 0) {
      return;
    }
    if (!_rewardingIds.add(publication.id)) return;
    try {
      while (publication.pendingDiamondRewards ~/
              publication.diamondsPerReward <
          publication.qualifiedViews ~/ publication.qualifiedViewsPerDiamond) {
        final tier =
            publication.pendingDiamondRewards ~/ publication.diamondsPerReward +
            1;
        final credited = wallet.addPendingPromotionReward(
          id: 'promotion-${publication.id}-tier-$tier',
          amount: publication.diamondsPerReward,
        );
        if (!credited) break;
        publication.pendingDiamondRewards += publication.diamondsPerReward;
      }
    } finally {
      _rewardingIds.remove(publication.id);
    }
  }

  bool extend(Publication publication) {
    if (publication.status != PublicationStatus.active ||
        publication.extended ||
        !publication.expiresAt.isAfter(_clock())) {
      return false;
    }
    publication.expiresAt = publication.expiresAt.add(
      const Duration(hours: 24),
    );
    publication.extended = true;
    notifyListeners();
    return true;
  }

  void remove(Publication publication) {
    if (publication.status != PublicationStatus.removed) {
      publication.status = PublicationStatus.removed;
      notifyListeners();
    }
  }

  void refreshExpiry() {
    for (final p in _publications) {
      if (p.status == PublicationStatus.active &&
          !p.expiresAt.isAfter(_clock())) {
        p.status = PublicationStatus.expired;
      }
    }
    notifyListeners();
  }

  void reset() {
    _publications.clear();
    _revision = 0;
    config = _initialConfig;
    if (seedPublications) _seedPublications();
    failNextPublish = false;
    notifyListeners();
  }
}
