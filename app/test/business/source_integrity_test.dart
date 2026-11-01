import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Story copyStory(
  Story source, {
  String? id,
  String? author,
  String? assetPath,
  StoryKind? kind,
}) => Story(
  id: id ?? source.id,
  author: author ?? source.author,
  title: source.title,
  category: source.category,
  kind: kind ?? source.kind,
  media: source.media,
  colors: source.colors,
  boosted: source.boosted,
  sponsored: source.sponsored,
  popular: source.popular,
  assetPath: assetPath ?? source.assetPath,
  sampleLabel: source.sampleLabel,
  rotation: source.rotation,
  cropScale: source.cropScale,
  trimStart: source.trimStart,
  trimEnd: source.trimEnd,
  coverLabel: source.coverLabel,
);

void main() {
  test('Popular changes do not invalidate an existing Business Story room', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final wallet = WalletController();
    final publishing = PublishingController(
      wallet: wallet,
      config: const PublishingConfig(popularThreshold: 2),
    );
    final stories = StoriesController(publishing: publishing);
    final business = BusinessController(
      wallet: wallet,
      stories: stories,
      settings: settings,
    );
    addTearDown(() {
      business.dispose();
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
      settings.dispose();
      chats.dispose();
    });
    settings.saveBusinessProfile(
      const BusinessProfile(
        name: 'Public Studio',
        category: 'Design',
        description: 'Independent studio',
      ),
    );
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.firstWhere(
      (item) => item.id == draft.id,
    );
    final initial = stories.allStories.firstWhere(
      (item) => item.id == draft.id,
    );
    expect(settings.linkBusinessStory(initial), isTrue);
    final initialPublic = copyStory(initial, author: 'Public Studio');
    expect(
      business.openRoom(initialPublic, confirmed: true),
      OpenRoomResult.opened,
    );
    publishing.recordView(publication, viewerId: 'one', viewerName: 'One');
    publishing.recordView(publication, viewerId: 'two', viewerName: 'Two');
    final current = stories.allStories.firstWhere(
      (item) => item.id == draft.id,
    );
    expect(current.popular, isTrue);
    final currentPublic = copyStory(current, author: 'Public Studio');
    expect(business.sourceEligible(initialPublic), isTrue);
    expect(business.openRoom(currentPublic), OpenRoomResult.alreadyActive);
    expect(wallet.credits, 2890);
    business.advance(const Duration(hours: 24));
    expect(
      business.openRoom(initialPublic, confirmed: true),
      OpenRoomResult.opened,
    );
    expect(wallet.credits, 2880);
  });

  test(
    'unknown and forged Story identity cannot create or reuse a paid room',
    () {
      final wallet = WalletController();
      final stories = StoriesController();
      final business = BusinessController(wallet: wallet, stories: stories);
      final source = StoriesController.stories.first;
      final unknown = copyStory(source, id: 'unknown');
      final impersonator = copyStory(source, author: 'Impersonator');
      final forgedCover = copyStory(
        source,
        assetPath: 'assets/story/unrelated.png',
      );
      for (final fake in [unknown, impersonator, forgedCover]) {
        expect(
          business.openRoom(fake, confirmed: true),
          OpenRoomResult.sourceUnavailable,
        );
      }
      expect(wallet.credits, 3000);
      expect(wallet.activity, isEmpty);
      expect(business.openRoom(source, confirmed: true), OpenRoomResult.opened);
      expect(
        business.openRoom(impersonator, confirmed: true),
        OpenRoomResult.sourceUnavailable,
      );
      stories.setAvailability(source.id, StoryAvailability.expired);
      expect(business.openRoom(source), OpenRoomResult.alreadyActive);
      expect(wallet.credits, 2990);
      business.advance(const Duration(hours: 24));
      expect(
        business.openRoom(source, confirmed: true),
        OpenRoomResult.sourceUnavailable,
      );
      expect(wallet.credits, 2990);
      business.dispose();
      stories.dispose();
      wallet.dispose();
    },
  );

  test('linked own promoted Story accepts only the verified public Business identity', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final stories = StoriesController(publishing: publishing);
    final business = BusinessController(
      wallet: wallet,
      stories: stories,
      settings: settings,
    );
    settings.saveBusinessProfile(
      const BusinessProfile(
        name: 'Public Studio',
        category: 'Design',
        description: 'Independent studio',
      ),
    );
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final source = stories.allStories.firstWhere(
      (story) => story.id == draft.id,
    );
    expect(settings.linkBusinessStory(source), isTrue);
    final publicStory = copyStory(source, author: 'Public Studio');
    expect(business.sourceEligible(publicStory), isTrue);
    expect(
      business.sourceEligible(copyStory(source, author: 'Alex Morgan')),
      isFalse,
    );
    business.setPerspective(BusinessPerspective.recipient);
    final room = business.seedRecipientRoom(publicStory);
    expect(room.story.author, 'Public Studio');
    expect(business.send(room.story.id, 'Public reply'), isTrue);
    settings.unlinkBusinessStory(source.id);
    expect(business.sourceEligible(publicStory), isFalse);
    expect(business.isActive(room), isTrue);
    business.dispose();
    stories.dispose();
    publishing.dispose();
    wallet.dispose();
    settings.dispose();
    chats.dispose();
  });
}
