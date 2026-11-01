import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';

void main() {
  late WalletController wallet;
  late PublishingController publishing;
  setUp(() {
    wallet = WalletController();
    publishing = PublishingController(
      wallet: wallet,
      clock: () => DateTime(2026, 1, 1),
    );
  });
  tearDown(() {
    publishing.dispose();
    wallet.dispose();
  });

  test('reentrant publishing creates one publication and one debit', () {
    final draft = publishing.createDraft(PublicationType.advertisement);
    final review = publishing.review(draft);
    PublishResult? reentrantResult;
    wallet.addListener(() {
      reentrantResult ??= publishing.publish(draft, review);
    });
    expect(publishing.publish(draft, review), PublishResult.success);
    expect(reentrantResult, PublishResult.inProgress);
    expect(publishing.publications, hasLength(1));
    expect(wallet.credits, 2900);
    expect(wallet.activity, hasLength(1));
  });

  test('reentrant views credit each earned reward tier once', () {
    publishing.dispose();
    publishing = PublishingController(
      wallet: wallet,
      config: const PublishingConfig(qualifiedViewsPerDiamond: 2),
    );
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final item = publishing.publications.single;
    var addedViews = false;
    wallet.addListener(() {
      if (addedViews) return;
      addedViews = true;
      publishing.recordView(item, viewerId: 'three', viewerName: 'Three');
      publishing.recordView(item, viewerId: 'four', viewerName: 'Four');
    });
    publishing.recordView(item, viewerId: 'one', viewerName: 'One');
    publishing.recordView(item, viewerId: 'two', viewerName: 'Two');
    expect(item.qualifiedViews, 4);
    expect(item.pendingDiamondRewards, 2);
    expect(wallet.pendingDiamonds, 42);
  });

  test('paid video advertisement requires boost and debits only once', () {
    publishing.dispose();
    publishing = PublishingController(
      wallet: wallet,
      clock: () => DateTime(2026, 1, 1),
      seedPublications: true,
    );
    final draft = publishing.createDraft(PublicationType.advertisement)
      ..paidCategory = true
      ..media = PublicationMedia.video;
    final review = publishing.review(draft);
    expect(
      (review.category, review.boost, review.advertisement, review.total),
      (5, 50, 100, 155),
    );
    expect(publishing.publish(draft, review), PublishResult.success);
    expect(publishing.publish(draft, review), PublishResult.success);
    expect(wallet.credits, 2845);
    expect(publishing.publications, hasLength(3));
    expect(wallet.activity, hasLength(1));
    expect(publishing.usedPhotoSlots, 2);
    expect(
      publishing.publications
          .firstWhere((item) => item.id == draft.id)
          .expiresAt
          .difference(
            publishing.publications
                .firstWhere((item) => item.id == draft.id)
                .createdAt,
          )
          .inHours,
      48,
    );
  });

  test('paid photo status consumes a slot and prevents another photo', () {
    publishing.dispose();
    publishing = PublishingController(
      wallet: wallet,
      clock: () => DateTime(2026, 1, 1),
      seedPublications: true,
    );
    final first = publishing.createDraft(PublicationType.status)
      ..paidCategory = true;
    expect(
      publishing.publish(first, publishing.review(first)),
      PublishResult.success,
    );
    expect(publishing.usedPhotoSlots, 3);
    final second = publishing.createDraft(PublicationType.status);
    expect(
      publishing.publish(second, publishing.review(second)),
      PublishResult.noSlots,
    );
    publishing.remove(
      publishing.publications.firstWhere((item) => item.id == first.id),
    );
    expect(
      publishing.publish(second, publishing.review(second)),
      PublishResult.success,
    );
    expect(publishing.usedPhotoSlots, 3);
  });

  test('changed price and failed submit preserve draft for retry', () {
    final draft = publishing.createDraft(PublicationType.advertisement)
      ..paidCategory = true
      ..caption = 'Keep this'
      ..location = 'Douala';
    final original = publishing.review(draft);
    publishing.updateConfig(const PublishingConfig(advertisementFee: 120));
    expect(publishing.publish(draft, original), PublishResult.changedPrice);
    final updated = publishing.review(draft);
    expect(updated.total, 125);
    publishing.failNextPublish = true;
    expect(publishing.publish(draft, updated), PublishResult.failed);
    expect(wallet.credits, 3000);
    expect(publishing.publish(draft, updated), PublishResult.success);
    expect(publishing.publications.single.caption, 'Keep this');
    expect(draft.location, 'Douala');
    expect(wallet.credits, 2875);
  });

  test('insufficient balance does not create publication or spend', () {
    wallet.credits = 2;
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.insufficientCredits,
    );
    expect(publishing.publications, isEmpty);
    expect(wallet.credits, 2);
  });

  test('one extension adds 24 hours and cannot repeat', () {
    final draft = publishing.createDraft(PublicationType.status);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final item = publishing.publications.single;
    expect(publishing.extend(item), isTrue);
    expect(publishing.extend(item), isFalse);
    expect(item.expiresAt.difference(item.createdAt).inHours, 48);
  });
  test(
    'publishing stores the reviewed audience and media editing metadata',
    () {
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..media = PublicationMedia.video
        ..location = 'Bonapriso, Douala, Cameroon'
        ..country = 'Cameroon'
        ..city = 'Douala'
        ..neighbourhood = 'Bonapriso'
        ..radiusKm = 17
        ..gender = 'Women'
        ..interest = 'Design'
        ..rotation = 1
        ..cropScale = 1.5
        ..trimStart = .2
        ..trimEnd = .8
        ..cover = 'Artwork';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      expect(
        (
          publication.location,
          publication.radiusKm,
          publication.gender,
          publication.interest,
        ),
        ('Bonapriso, Douala, Cameroon', 17, 'Women', 'Design'),
      );
      expect(
        (
          publication.rotation,
          publication.cropScale,
          publication.trimStart,
          publication.trimEnd,
          publication.cover,
        ),
        (1, 1.5, .2, .8, 'Artwork'),
      );
      draft.location = 'Changed afterwards';
      expect(publication.location, 'Bonapriso, Douala, Cameroon');
    },
  );

  test('views exclude owner and duplicates, hold suspicious views, and protect promoted identities', () {
    final draft = publishing.createDraft(PublicationType.status);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.single;
    publishing.recordView(
      publication,
      viewerId: 'alex',
      viewerName: 'Alex',
      isOwner: true,
    );
    publishing.recordView(publication, viewerId: 'sarah', viewerName: 'Sarah');
    publishing.recordView(publication, viewerId: 'sarah', viewerName: 'Sarah');
    publishing.recordView(
      publication,
      viewerId: 'held',
      viewerName: 'Held',
      suspicious: true,
    );
    expect(
      (
        publication.totalViews,
        publication.qualifiedViews,
        publication.heldViews,
      ),
      (2, 1, 1),
    );
    expect(publication.contactViewers.keys, ['sarah']);
    final ad = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(ad, publishing.review(ad)),
      PublishResult.success,
    );
    final promoted = publishing.publications.first;
    publishing.recordView(promoted, viewerId: 'sarah', viewerName: 'Sarah');
    expect(promoted.qualifiedViews, 1);
    expect(promoted.contactViewers, isEmpty);
    publishing.remove(publication);
    publishing.recordView(publication, viewerId: 'new', viewerName: 'New');
    expect(publication.totalViews, 2);
  });
}
