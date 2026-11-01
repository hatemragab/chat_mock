import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/controllers/review_commerce_missing.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Fixture {
  Fixture({bool seedPublications = false}) {
    settings = SettingsController(chats: chats);
    group = GroupController(chats: chats);
    publishing = PublishingController(
      wallet: wallet,
      seedPublications: seedPublications,
    );
    stories = StoriesController(publishing: publishing);
    business = BusinessController(
      wallet: wallet,
      stories: stories,
      chats: chats,
      settings: settings,
    );
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
      settings: settings,
      profile: profile,
      onSignOut: () => signedOut = true,
    );
  }
  final wallet = WalletController();
  final chats = ChatsController();
  final profile = OnboardingController();
  late final SettingsController settings;
  late final GroupController group;
  late final PublishingController publishing;
  late final StoriesController stories;
  late final BusinessController business;
  late final CallsController calls;
  late final ReviewActions actions;
  bool signedOut = false;
  void dispose() {
    calls.dispose();
    business.dispose();
    stories.dispose();
    publishing.dispose();
    group.dispose();
    settings.dispose();
    profile.dispose();
    chats.dispose();
    wallet.dispose();
  }
}

Future<void> openScenario(WidgetTester tester, Fixture f, String id) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => f.actions.open(context, id),
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open review'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'changed terms are real, cancellable and require another confirmation',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await openScenario(tester, f, 'D14');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Price changed'), findsOneWidget);
      final before = f.wallet.credits;
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(f.wallet.credits, before);
      await tester.ensureVisible(find.text('Publish'));
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Price changed'), findsOneWidget);
    },
  );

  testWidgets(
    'paid photo review uses a slot only after confirmed publication',
    (tester) async {
      final f = Fixture(seedPublications: true);
      addTearDown(f.dispose);
      await openScenario(tester, f, 'V075');
      expect(f.publishing.usedPhotoSlots, 2);
      await tester.ensureVisible(find.text('Publish'));
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(f.publishing.usedPhotoSlots, 3);
      expect(f.wallet.credits, 2995);
    },
  );

  testWidgets('publication failure preserves the draft and allows retry', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await openScenario(tester, f, 'V081');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('Publishing failed.'), findsOneWidget);
    expect(f.publishing.publications, isEmpty);
    await tester.ensureVisible(find.text('Publish'));
    await tester.tap(find.text('Publish'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(f.publishing.publications, hasLength(1));
  });

  testWidgets(
    'publishing review shows real submission progress before completion',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => f.actions.open(context, 'V080'),
                child: const Text('Open review'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open review'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(f.publishing.publications, isEmpty);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(f.publishing.publications, hasLength(1));
    },
  );

  testWidgets(
    'location-denied review uses the real manual form and restores permission',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      f.settings.setPermission('Location', MockPermission.allowed);
      await openScenario(tester, f, 'V083');
      expect(f.settings.permissions['Location'], MockPermission.denied);
      expect(
        find.textContaining('Location permission is denied.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Save area'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Save area'));
      await tester.pumpAndSettle();
      expect(find.text('Choose your audience'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(f.settings.permissions['Location'], MockPermission.allowed);
    },
  );

  testWidgets(
    'failed conversion requires review, preserves balances and permits retry',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await openScenario(tester, f, 'V108');
      expect(find.text('Confirm conversion'), findsOneWidget);
      await tester.tap(find.text('Confirm conversion'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.textContaining('Conversion failed'), findsOneWidget);
      expect(f.wallet.diamonds, 350);
      expect(f.wallet.cash, 1000);
      await tester.tap(find.text('Review conversion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm conversion'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(f.wallet.diamonds, 349);
      expect(f.wallet.cash, 1005);
    },
  );

  for (final scenario in ['V110', 'V112']) {
    testWidgets('$scenario uses actual withdrawal validation', (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await openScenario(tester, f, scenario);
      expect(
        find.textContaining(
          scenario == 'V110'
              ? 'Minimum withdrawal is'
              : 'Enter a valid Mobile Money number.',
        ),
        findsOneWidget,
      );
      expect(f.wallet.cash, 1000);
    });
  }

  testWidgets('frequency review requires the real session limit', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    expect(canOpenCommerceMissing(f.actions, 'V113'), isFalse);
    f.wallet.cash = 5000;
    for (var i = 0; i < 2; i++) {
      f.wallet.requestWithdrawal(
        id: 'seed-$i',
        amount: 1000,
        method: PaymentMethod.mtn,
        destination: '670000000',
      );
    }
    expect(canOpenCommerceMissing(f.actions, 'V113'), isTrue);
    await openScenario(tester, f, 'V113');
    expect(find.text('Daily withdrawal limit reached.'), findsOneWidget);
    expect(f.wallet.withdrawals, hasLength(2));
  });

  testWidgets(
    'account deletion review still requires acknowledgement and confirmation',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await openScenario(tester, f, 'D20');
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Delete account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(f.signedOut, isFalse);
    },
  );

  for (final scenario in ['V126', 'V127']) {
    testWidgets('$scenario runs a real simulated report', (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await openScenario(tester, f, scenario);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          scenario == 'V126'
              ? 'Report submitted'
              : 'Your report could not be submitted.',
        ),
        findsOneWidget,
      );
    });
  }
}
