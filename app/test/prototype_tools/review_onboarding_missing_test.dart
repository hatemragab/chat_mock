import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixture {
  _Fixture() {
    group = GroupController(chats: chats);
    publishing = PublishingController(wallet: wallet);
    stories = StoriesController(publishing: publishing);
    business = BusinessController(wallet: wallet);
    calls = CallsController(
      spendCredits: (id, amount, description) =>
          wallet.spendCredits(id: id, amount: amount, description: description),
    );
    actions = ReviewActions(
      chats: chats,
      calls: calls,
      group: group,
      business: business,
      publishing: publishing,
      stories: stories,
      wallet: wallet,
      profile: profile,
    );
  }
  final chats = ChatsController();
  final wallet = WalletController();
  final profile = OnboardingController();
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
    profile.dispose();
    chats.dispose();
    wallet.dispose();
  }
}

Future<void> _launch(
  WidgetTester tester,
  _Fixture fixture,
  String id, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => fixture.actions.open(context, id),
            child: const Text('Review'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Review'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  testWidgets(
    'S01 searches country codes and composes the selected prefix once',
    (tester) async {
      final f = _Fixture();
      f.profile.setPhone('670000000');
      await _launch(tester, f, 'S01');
      expect(find.text('Country code'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('country_code_search')),
        'Egypt',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Egypt').last);
      await tester.pumpAndSettle();
      expect(f.profile.phone.international, '+20670000000');
      expect(find.text('+20'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(f.profile.phone.international, '+237670000000');
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );

  testWidgets(
    'V007 and V008 show their actual validation while retaining review context',
    (tester) async {
      final f = _Fixture();
      await _launch(tester, f, 'V007');
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter your phone number.'), findsOneWidget);
      expect(find.text('Please accept the terms to continue.'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _launch(tester, f, 'V008');
      expect(find.text('Please accept the terms to continue.'), findsOneWidget);
      expect(find.text('Enter your name.'), findsNothing);
      expect(find.text('Enter your phone number.'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(f.profile.name, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );

  testWidgets('V009 permits progression after choosing three interests', (
    tester,
  ) async {
    final f = _Fixture();
    await _launch(tester, f, 'V009');
    expect(find.text('Select at least three interests.'), findsOneWidget);
    for (final item in ['Art', 'Music', 'Travel']) {
      await tester.tap(find.text(item));
      await tester.pump();
    }
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Find your contacts'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Review'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('declined and matching contacts remain actionable', (
    tester,
  ) async {
    final f = _Fixture();
    await _launch(tester, f, 'V011');
    expect(find.text('Contacts access declined'), findsOneWidget);
    await tester.tap(find.text('Continue to Discover'));
    await tester.pumpAndSettle();
    await _launch(tester, f, 'V012', settle: false);
    await tester.pump();
    expect(find.text('Finding mutual contacts…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('No matching contacts yet'), findsOneWidget);
    await tester.tap(find.text('Continue to Discover'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('D01 uses a real dirty profile draft and cancel preserves it', (
    tester,
  ) async {
    final f = _Fixture();
    await _launch(tester, f, 'D01');
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Alex Morgan (edited)'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Review'), findsOneWidget);
    expect(f.profile.name, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });
  testWidgets(
    'dismissing the country picker leaves the retained number unchanged',
    (tester) async {
      final fixture = _Fixture();
      fixture.profile.setPhone('670000000');
      await _launch(tester, fixture, 'S01');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(fixture.profile.phone.international, '+237670000000');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Review'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.dispose();
    },
  );
}
