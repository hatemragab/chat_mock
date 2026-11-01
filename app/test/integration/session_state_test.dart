import 'package:app/core/demo/demo_clock.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'one mock clock expires publications and business rooms consistently',
    () {
      final clock = DemoClock();
      final wallet = WalletController(clock: clock.now);
      final publishing = PublishingController(wallet: wallet, clock: clock.now);
      final stories = StoriesController(
        publishing: publishing,
        clock: clock.now,
      );
      final business = BusinessController(wallet: wallet, clock: clock.now);
      final draft = publishing.createDraft(PublicationType.status)
        ..caption = 'New update';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      expect(stories.allStories.any((s) => s.id == draft.id), isTrue);
      final source = StoriesController.stories.first;
      expect(business.openRoom(source, confirmed: true), OpenRoomResult.opened);
      expect(business.isActive(business.roomFor(source.id)!), isTrue);
      clock.advance(const Duration(hours: 25));
      publishing.refreshExpiry();
      expect(stories.allStories.any((s) => s.id == draft.id), isFalse);
      expect(business.isActive(business.roomFor(source.id)!), isFalse);
      business.dispose();
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    },
  );
  test('expired source is hidden without ending its existing paid room', () {
    final clock = DemoClock();
    final wallet = WalletController(clock: clock.now);
    final stories = StoriesController(clock: clock.now);
    final business = BusinessController(
      wallet: wallet,
      stories: stories,
      clock: clock.now,
    );
    final source = StoriesController.stories.first;
    expect(business.openRoom(source, confirmed: true), OpenRoomResult.opened);
    final afterCharge = wallet.credits;
    stories.setAvailability(source.id, StoryAvailability.expired);
    expect(stories.allStories.any((story) => story.id == source.id), isFalse);
    expect(business.openRoom(source), OpenRoomResult.alreadyActive);
    expect(wallet.credits, afterCharge);
    clock.advance(const Duration(hours: 25));
    expect(business.openRoom(source), OpenRoomResult.sourceUnavailable);
    expect(wallet.credits, afterCharge);
    business.dispose();
    stories.dispose();
    wallet.dispose();
  });
  test('status audience and restrictions affect publication actions', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final wallet = WalletController();
    final publishing = PublishingController(
      wallet: wallet,
      canPublish: () => settings.canPublish,
      canShareStatusWith: settings.canShareStatusWith,
    );
    settings.setAudience(StatusAudience.only, {'sarah'});
    final draft = publishing.createDraft(PublicationType.status);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.single;
    publishing.recordView(
      publication,
      viewerId: 'amira',
      viewerName: 'Amira Hassan',
    );
    publishing.recordView(
      publication,
      viewerId: 'sarah',
      viewerName: 'Sarah Wilson',
    );
    expect(publication.contactViewers.keys, ['sarah']);
    settings.setRestriction(RestrictionLevel.suspension);
    final next = publishing.createDraft(PublicationType.advertisement);
    final balance = wallet.credits;
    expect(
      publishing.publish(next, publishing.review(next)),
      PublishResult.restricted,
    );
    expect(wallet.credits, balance);
    publishing.dispose();
    wallet.dispose();
    settings.dispose();
    chats.dispose();
  });
  test('incoming call notifications honor the session preference', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final calls = CallsController(
      spendCredits: (_, _, _) => true,
      onIncomingCall: (call) {
        settings.notifications.receive(
          kind: NotificationKind.call,
          sender: call.name,
          message: 'Incoming call',
        );
      },
    );
    settings.setCallNotifications(false);
    calls.start(name: 'Sarah Wilson', kind: CallKind.audio, incoming: true);
    expect(settings.notifications.items, isEmpty);
    calls.finishRinging(CallPhase.declined);
    settings.setCallNotifications(true);
    calls.start(name: 'Amira Hassan', kind: CallKind.audio, incoming: true);
    expect(settings.notifications.items.single.sender, 'Amira Hassan');
    calls.dispose();
    settings.dispose();
    chats.dispose();
  });
  test('incoming messages respect notification preferences without dropping the chat message', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    chats.onIncomingMessage = (chat, message) => settings.notifications.receive(
      kind: NotificationKind.message,
      sender: chat.name,
      message: message.text,
    );
    final chat = chats.byId('sarah');
    final before = chat.messages.length;
    settings.setMessageNotifications(false);
    chats.receiveContactMessage(chat, 'Hello');
    expect(chat.messages.length, before + 1);
    expect(settings.notifications.items, isEmpty);
    settings.setMessageNotifications(true);
    chats.receiveContactMessage(chat, 'See you');
    expect(settings.notifications.items.single.message, 'See you');
    chats.toggleBlocked(chat);
    expect(chats.receiveContactMessage(chat, 'Blocked'), isNull);
    expect(settings.notifications.items, hasLength(1));
    settings.dispose();
    chats.dispose();
  });
}
