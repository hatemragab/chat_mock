import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/controllers/review_chat_missing.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ReviewFixture {
  ReviewFixture() {
    group = GroupController(chats: chats);
    publishing = PublishingController(wallet: wallet);
    stories = StoriesController(publishing: publishing);
    business = BusinessController(
      wallet: wallet,
      chats: chats,
      stories: stories,
    );
    calls = CallsController(spendCredits: (_, _, _) => true);
    actions = ReviewActions(
      chats: chats,
      calls: calls,
      group: group,
      business: business,
      publishing: publishing,
      stories: stories,
      wallet: wallet,
    );
  }
  final chats = ChatsController();
  final wallet = WalletController();
  late final GroupController group;
  late final PublishingController publishing;
  late final StoriesController stories;
  late final BusinessController business;
  late final CallsController calls;
  late final ReviewActions actions;
  void dispose() {
    calls.dispose();
    business.dispose();
    stories.dispose();
    publishing.dispose();
    group.dispose();
    chats.dispose();
    wallet.dispose();
  }
}

Widget reviewLauncher(ReviewFixture fixture, String id) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => fixture.actions.open(context, id),
        child: const Text('Open scenario'),
      ),
    ),
  ),
);

void main() {
  for (final id in ['V022', 'V023']) {
    testWidgets('$id opens the real voice recorder and can send a typed note', (
      tester,
    ) async {
      final f = ReviewFixture();
      await tester.pumpWidget(reviewLauncher(f, id));
      await tester.tap(find.text('Open scenario'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(id == 'V023' ? 'Recording locked' : 'Recording ·'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byTooltip('Stop recording'));
      await tester.pump();
      await tester.tap(find.byTooltip('Send voice note'));
      await tester.pump();
      expect(f.chats.byId('sarah').messages.last.kind, MessageKind.audio);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    });
  }
  testWidgets(
    'empty searches can be edited to find real messages and members',
    (tester) async {
      final f = ReviewFixture();
      await tester.pumpWidget(reviewLauncher(f, 'V026'));
      await tester.tap(find.text('Open scenario'));
      await tester.pumpAndSettle();
      expect(
        find.text('No matching conversations or messages'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'meeting');
      await tester.pump();
      expect(find.textContaining('meeting'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pumpWidget(reviewLauncher(f, 'V036'));
      await tester.tap(find.text('Open scenario'));
      await tester.pumpAndSettle();
      expect(find.text('No members match your search.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Sarah');
      await tester.pump();
      expect(find.text('Sarah Wilson'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );
  testWidgets(
    'group update can be cancelled during submission without mutation',
    (tester) async {
      final f = ReviewFixture();
      await tester.pumpWidget(reviewLauncher(f, 'V039'));
      await tester.tap(find.text('Open scenario'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(f.group.updateStatus, GroupUpdateStatus.submitting);
      expect(find.text('Updating group…'), findsOneWidget);
      await tester.tap(find.text('Cancel update'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(f.group.name, 'Design Team');
      expect(f.group.updateStatus, GroupUpdateStatus.idle);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );
  testWidgets('failed group update retains the draft and retry saves it', (
    tester,
  ) async {
    final f = ReviewFixture();
    await tester.pumpWidget(reviewLauncher(f, 'V040'));
    await tester.tap(find.text('Open scenario'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(f.group.updateStatus, GroupUpdateStatus.failed);
    expect(find.textContaining('Your changes are still here'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Group name'),
      'Updated team',
    );
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(f.group.name, 'Updated team');
    expect(f.chats.byId('design').name, 'Updated team');
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });
  test('review respects current chat and group permissions', () {
    final f = ReviewFixture();
    expect(canOpenChatMissing(f.actions, 'V022'), isTrue);
    f.chats.toggleBlocked(f.chats.byId('sarah'));
    expect(canOpenChatMissing(f.actions, 'V022'), isFalse);
    f.group.setPerspective('amira');
    expect(canOpenChatMissing(f.actions, 'V039'), isFalse);
    f.dispose();
  });
}
