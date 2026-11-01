import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final story = StoriesController.stories.first;
  final other = StoriesController.stories[1];
  late WalletController wallet;
  late BusinessController business;

  setUp(() {
    wallet = WalletController();
    business = BusinessController(
      wallet: wallet,
      clock: () => DateTime.utc(2026, 1, 1),
    );
  });
  tearDown(() {
    business.dispose();
    wallet.dispose();
  });

  test(
    'confirmation is required and an active room is never charged again',
    () {
      expect(business.openRoom(story), OpenRoomResult.confirmationRequired);
      expect(wallet.credits, 3000);
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      expect(wallet.credits, 2990);
      expect(
        business.openRoom(story, confirmed: true),
        OpenRoomResult.alreadyActive,
      );
      expect(wallet.credits, 2990);
      expect(wallet.activity.length, 1);
    },
  );

  test('reentrant room opening never charges twice', () {
    OpenRoomResult? nested;
    void retry() {
      nested ??= business.openRoom(story, confirmed: true);
    }

    wallet.addListener(retry);
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    wallet.removeListener(retry);
    expect(nested, OpenRoomResult.inProgress);
    expect(wallet.credits, 2990);
    expect(wallet.activity, hasLength(1));
    expect(business.roomFor(story.id)!.openingCount, 1);
    expect(
      business.openRoom(story, confirmed: true),
      OpenRoomResult.alreadyActive,
    );
  });

  test('originating Story unavailability does not end an active room but prevents reopening', () {
    business.openRoom(story, confirmed: true);
    business.setSourceEligible(story.id, false);
    expect(business.openRoom(story), OpenRoomResult.alreadyActive);
    expect(business.send(story.id, 'Still active'), isTrue);
    business.advance(const Duration(hours: 24));
    expect(business.send(story.id, 'Too late'), isFalse);
    expect(
      business.openRoom(story, confirmed: true),
      OpenRoomResult.sourceUnavailable,
    );
    expect(wallet.credits, 2990);
  });

  test('expired rooms reopen with confirmation and respect their interaction limit', () {
    for (var opening = 1; opening <= 3; opening++) {
      expect(business.openRoom(story), OpenRoomResult.confirmationRequired);
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      business.advance(const Duration(hours: 24));
    }
    expect(
      business.openRoom(story, confirmed: true),
      OpenRoomResult.limitReached,
    );
    expect(wallet.credits, 2970);
    expect(business.roomFor(story.id)!.openingCount, 3);
  });

  test('rooms and messages remain isolated by originating Story', () {
    business.openRoom(story, confirmed: true);
    business.openRoom(other, confirmed: true);
    business.send(story.id, 'First');
    business.send(other.id, 'Second');
    expect(business.roomFor(story.id)!.messages.single.text, 'First');
    expect(business.roomFor(other.id)!.messages.single.text, 'Second');
    expect(business.roomFor(story.id)!.story.author, story.author);
  });

  test('message ownership follows stable participant identity', () {
    business.openRoom(story, confirmed: true);
    final room = business.roomFor(story.id)!;
    final otherParticipant = ChatMessage(
      id: 'recipient',
      author: 'Alex Morgan',
      authorId: 'business-recipient',
      text: 'A recipient message',
      time: DateTime(2026),
      isMine: false,
    );
    room.messages.add(otherParticipant);
    expect(business.isOwnMessage(room, otherParticipant), isFalse);
    expect(business.editMessage(story.id, otherParticipant, 'Forged'), isFalse);
    business.setPerspective(BusinessPerspective.recipient);
    expect(business.isOwnMessage(room, otherParticipant), isTrue);
    expect(business.editMessage(story.id, otherParticipant, 'Edited'), isTrue);
  });

  test('standalone Business replies include the source author and message', () {
    business.openRoom(story, confirmed: true);
    final room = business.roomFor(story.id)!;
    final source = ChatMessage(
      id: 'source',
      author: 'Maison Studio',
      authorId: 'business-recipient',
      text: 'How can we help?',
      time: DateTime(2026),
      isMine: false,
    );
    room.messages.add(source);
    expect(business.send(story.id, 'A question', reply: source), isTrue);
    expect(room.messages.last.quote, 'Maison Studio: How can we help?');
  });

  test('recipient can reply to a seeded incoming room without buying', () {
    business.setPerspective(BusinessPerspective.recipient);
    expect(
      business.openRoom(story, confirmed: true),
      OpenRoomResult.recipientCannotOpen,
    );
    business.seedRecipientRoom(story);
    expect(business.send(story.id, 'Welcome!'), isTrue);
    expect(business.roomFor(story.id)!.messages.single.author, story.author);
    expect(wallet.credits, 3000);
  });

  test('insufficient balance does not open a room or add a ledger entry', () {
    wallet.credits = 9;
    expect(
      business.openRoom(story, confirmed: true),
      OpenRoomResult.insufficientCredits,
    );
    expect(business.roomFor(story.id), isNull);
    expect(wallet.activity, isEmpty);
  });

  test('resetting rooms alone cannot reuse a previous wallet debit', () {
    business.openRoom(story, confirmed: true);
    business.reset();
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    expect(wallet.credits, 2980);
    expect(wallet.activity.length, 2);
  });
}
