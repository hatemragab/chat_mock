import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeded photo slots belong to removable and expiring publications', () {
    var now = DateTime(2026, 1, 1);
    final wallet = WalletController(clock: () => now);
    final publishing = PublishingController(
      wallet: wallet,
      clock: () => now,
      seedPublications: true,
    );
    final stories = StoriesController(publishing: publishing, clock: () => now);
    final initialIds = publishing.publications.map((p) => p.id).toSet();
    expect(initialIds, {'seed-status-1', 'seed-status-2'});
    expect(publishing.usedPhotoSlots, 2);
    expect(
      stories.allStories
          .where((story) => story.kind == StoryKind.own)
          .map((story) => story.id)
          .toSet(),
      initialIds,
    );
    now = now.add(const Duration(hours: 19));
    publishing.refreshExpiry();
    expect(publishing.usedPhotoSlots, 1);
    expect(
      stories.allStories.any((story) => story.id == 'seed-status-1'),
      isFalse,
    );
    final remaining = publishing.publications.firstWhere(
      (p) => p.id == 'seed-status-2',
    );
    publishing.remove(remaining);
    publishing.remove(remaining);
    expect(publishing.usedPhotoSlots, 0);
    expect(
      stories.allStories.where((story) => story.kind == StoryKind.own),
      isEmpty,
    );
    publishing.reset();
    expect(publishing.usedPhotoSlots, 2);
    expect(publishing.publications.map((p) => p.id).toSet(), initialIds);
    stories.dispose();
    publishing.dispose();
    wallet.dispose();
  });

  test('qualified promoted views earn pending Diamonds once per mock tier', () {
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.single;
    void view(String id, {bool suspicious = false, bool owner = false}) =>
        publishing.recordView(
          publication,
          viewerId: id,
          viewerName: id,
          suspicious: suspicious,
          isOwner: owner,
        );
    view('self', owner: true);
    view('held', suspicious: true);
    for (var i = 0; i < 49; i++) {
      view('viewer-$i');
    }
    view('viewer-1');
    expect(publication.qualifiedViews, 49);
    expect(wallet.pendingDiamonds, 40);
    view('viewer-49');
    expect(publication.pendingDiamondRewards, 1);
    expect(wallet.pendingDiamonds, 41);
    expect(wallet.diamonds, 350);
    final reward = wallet.activity.singleWhere(
      (item) =>
          item.kind == BalanceKind.diamonds && item.title == 'Promotion reward',
    );
    expect((reward.amount, reward.status), (1, 'Pending'));
    for (var i = 50; i < 100; i++) {
      view('viewer-$i');
    }
    expect(publication.pendingDiamondRewards, 2);
    expect(wallet.pendingDiamonds, 42);
    expect(
      wallet.activity.where((item) => item.title == 'Promotion reward'),
      hasLength(2),
    );
    publishing.dispose();
    wallet.dispose();
  });

  test(
    'resetting only publishing cannot reuse an old debit or reward reference',
    () {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final first = publishing.createDraft(PublicationType.advertisement);
      expect(
        publishing.publish(first, publishing.review(first)),
        PublishResult.success,
      );
      final firstItem = publishing.publications.single;
      for (var i = 0; i < 50; i++) {
        publishing.recordView(firstItem, viewerId: '$i', viewerName: '$i');
      }
      publishing.reset();
      final second = publishing.createDraft(PublicationType.advertisement);
      expect(second.id, isNot(first.id));
      expect(
        publishing.publish(second, publishing.review(second)),
        PublishResult.success,
      );
      final secondItem = publishing.publications.single;
      for (var i = 0; i < 50; i++) {
        publishing.recordView(secondItem, viewerId: '$i', viewerName: '$i');
      }
      expect(wallet.credits, 2800);
      expect(wallet.pendingDiamonds, 42);
      expect(
        wallet.activity.where((item) => item.title == 'Promotion reward'),
        hasLength(2),
      );
      publishing.dispose();
      wallet.dispose();
    },
  );
  test(
    'reward terms stay attached to the publication when configuration changes',
    () {
      final wallet = WalletController();
      final publishing = PublishingController(
        wallet: wallet,
        config: const PublishingConfig(
          qualifiedViewsPerDiamond: 3,
          diamondsPerReward: 2,
        ),
      );
      final draft = publishing.createDraft(PublicationType.advertisement);
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      publishing.updateConfig(
        const PublishingConfig(
          qualifiedViewsPerDiamond: 1,
          diamondsPerReward: 10,
        ),
      );
      for (var i = 0; i < 3; i++) {
        publishing.recordView(publication, viewerId: '$i', viewerName: '$i');
      }
      expect(publication.pendingDiamondRewards, 2);
      expect(wallet.pendingDiamonds, 42);
      publishing.dispose();
      wallet.dispose();
    },
  );
}
