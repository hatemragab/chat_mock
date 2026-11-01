import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'published stories are added once and disappear on removal or expiry',
    () {
      var now = DateTime(2026, 1, 1);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet, clock: () => now);
      final stories = StoriesController(
        publishing: publishing,
        clock: () => now,
      );
      var updates = 0;
      stories.addListener(() => updates++);
      final draft = publishing.createDraft(PublicationType.status)
        ..caption = 'Our latest work';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      expect(
        stories.allStories.where((story) => story.id == draft.id).single.title,
        'Our latest work',
      );
      expect(updates, greaterThan(0));
      final publication = publishing.publications.single;
      now = now.add(const Duration(hours: 25));
      expect(stories.availability(draft.id), StoryAvailability.expired);
      expect(
        stories.allStories.where((story) => story.id == draft.id),
        isEmpty,
      );
      publishing.remove(publication);
      expect(stories.availability(draft.id), StoryAvailability.removed);
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    },
  );

  test('review availability, media failure and seen state reset together', () {
    final stories = StoriesController();
    final story = StoriesController.stories.first;
    stories.markSeen(story.id);
    stories.setAvailability(story.id, StoryAvailability.expired);
    stories.setMediaFailed(story.id, true);
    expect(stories.isSeen(story.id), isTrue);
    expect(stories.mediaFailed(story.id), isTrue);
    expect(stories.allStories.where((item) => item.id == story.id), isEmpty);
    stories.reset();
    expect(stories.isSeen(story.id), isFalse);
    expect(stories.mediaFailed(story.id), isFalse);
    expect(stories.availability(story.id), StoryAvailability.active);
    stories.dispose();
  });
}
