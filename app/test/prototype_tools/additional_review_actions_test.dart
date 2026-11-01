import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/ui/screens/review_catalog_screen/review_catalog_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Fixture {
  Fixture() {
    settings = SettingsController(chats: chats);
    group = GroupController(chats: chats);
    publishing = PublishingController(wallet: wallet);
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
      onThemeChanged: (value) => theme = value,
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
  ThemeMode theme = ThemeMode.system;
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

Future<void> select(WidgetTester tester, String id) async {
  await tester.enterText(find.byType(TextField).first, id);
  await tester.pumpAndSettle();
  await tester.tap(find.text(id).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('P76 opens the real readable help article', (tester) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'P76');
    expect(find.text('Getting started'), findsWidgets);
    expect(
      find.textContaining('Choose your interests and complete your profile'),
      findsOneWidget,
    );
  });

  testWidgets(
    'payment cancellation requires confirmation and never credits funds',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      final payment = f.wallet.startPayment(
        id: 'pending',
        credits: 10,
        method: PaymentMethod.mtn,
        phone: '+237670000000',
      );
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'D18');
      await tester.tap(find.text('Keep payment'));
      await tester.pumpAndSettle();
      expect(payment.status, PaymentStatus.processing);
      await tester.tap(find.text('D18').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel payment'));
      await tester.pumpAndSettle();
      expect(payment.status, PaymentStatus.cancelled);
      expect(f.wallet.credits, 3000);
    },
  );

  testWidgets('block and unblock confirmation controls the same contact', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    final sarah = f.chats.byId('sarah');
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'D21');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(sarah.blocked, isFalse);
    await tester.tap(find.text('D21').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    expect(sarah.blocked, isTrue);
    await select(tester, 'D22');
    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();
    expect(sarah.blocked, isFalse);
  });

  testWidgets('Story scenarios track real availability and show real states', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    final story = StoriesController.stories.first;
    expect(f.actions.canOpen('V065'), isFalse);
    f.stories.setAvailability(story.id, StoryAvailability.expired);
    expect(f.actions.canOpen('V065'), isTrue);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'V065');
    expect(find.text('This Story has expired.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    f.stories.setAvailability(story.id, StoryAvailability.active);
    f.stories.setMediaFailed(story.id, true);
    await select(tester, 'V067');
    expect(find.text('Story media could not be loaded.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(f.stories.mediaFailed(story.id), isFalse);
  });

  testWidgets(
    'room confirmation preserves balance on cancel and charges once on confirm',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'D16');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(f.wallet.credits, 3000);
      await tester.tap(find.text('D16').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reopen room'));
      await tester.pumpAndSettle();
      expect(f.wallet.credits, 2990);
      expect(f.business.isActive(f.business.roomFor('maison')!), isTrue);
    },
  );

  testWidgets('message action Reply opens the actual reply composer', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'S03');
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Replying to'), findsWidgets);
  });

  testWidgets('appearance scenario applies the requested real theme', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'V121');
    expect(f.theme, ThemeMode.dark);
    expect(find.text('Dark'), findsOneWidget);
  });
  testWidgets(
    'publication deletion only removes the selected item after confirmation',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      final draft = f.publishing.createDraft(PublicationType.status)
        ..caption = 'My update';
      expect(
        f.publishing.publish(draft, f.publishing.review(draft)),
        PublishResult.success,
      );
      final publication = f.publishing.publications.single;
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'D13');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.active);
      await tester.tap(find.text('D13').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.removed);
    },
  );

  testWidgets(
    'chat actions and mute selection change only the targeted conversation',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      final chat = f.chats.byId('sarah');
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'S02');
      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();
      expect(chat.pinned, isTrue);
      await select(tester, 'S06');
      await tester.tap(find.text('8 hours'));
      await tester.pumpAndSettle();
      expect(chat.muted, isTrue);
      expect(chat.mutedUntil, isNotNull);
      expect(f.chats.byId('amira').muted, isFalse);
      f.chats.unmute(chat);
    },
  );

  testWidgets('photo visibility selection is applied only after Save', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'S21');
    await tester.tap(find.text('Nobody'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(f.settings.photoVisibility, PhotoVisibility.contacts);
    await tester.tap(find.text('S21').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nobody'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(f.settings.photoVisibility, PhotoVisibility.nobody);
  });

  testWidgets(
    'paid video advertisement scenario shows the additive review total',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'V077');
      expect(find.text('155 Credits'), findsOneWidget);
      expect(find.text('50 Credits'), findsOneWidget);
      expect(find.text('100 Credits'), findsOneWidget);
    },
  );

  testWidgets('paused and muted Story scenarios open real viewer controls', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'V063');
    expect(find.text('Paused'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await select(tester, 'V064');
    expect(find.byTooltip('Unmute'), findsOneWidget);
  });
  testWidgets('clear and delete dialogs preserve the chat on cancel', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    final chat = f.chats.byId('sarah');
    final originalCount = chat.messages.length;
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'D04');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(chat.messages.length, originalCount);
    await tester.tap(find.text('D04').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(chat.messages, isEmpty);
    await select(tester, 'D03');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(chat.hidden, isFalse);
  });

  testWidgets(
    'target area selection opens the real editable location context',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'S15');
      await tester.tap(find.text('Akwa'));
      await tester.pumpAndSettle();
      expect(find.text('Target area'), findsOneWidget);
      expect(find.text('Akwa'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
    },
  );

  testWidgets('Story options use the real report and block sheet', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await select(tester, 'S12');
    expect(find.text('Report Story'), findsOneWidget);
    expect(find.text('Block Maison Studio'), findsOneWidget);
    await tester.tap(find.text('Block Maison Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(f.business.isBlocked(StoriesController.stories.first), isFalse);
  });

  testWidgets(
    'photo source library selection updates the actual profile draft',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'S05');
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a photo'), findsOneWidget);
      await tester.tap(find.text('Studio portrait'));
      await tester.pumpAndSettle();
      expect(f.profile.photoSelected, isTrue);
    },
  );
  testWidgets(
    'minimized call review retains the actual session and can return',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      f.calls.start(name: 'Sarah Wilson', kind: CallKind.audio);
      f.calls.answer();
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'S10');
      expect(f.calls.active!.minimized, isTrue);
      expect(find.textContaining('Tap to return'), findsWidgets);
      await tester.tap(find.textContaining('Tap to return').first);
      await tester.pumpAndSettle();
      expect(f.calls.active!.minimized, isFalse);
      expect(find.text('End call'), findsOneWidget);
      f.calls.end();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'interaction limit dialog is only available when actual limit is reached',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      final story = StoriesController.stories.first;
      expect(f.actions.canOpen('D17'), isFalse);
      f.business.openRoom(story, confirmed: true);
      f.business.advance(const Duration(hours: 25));
      f.business.openRoom(story, confirmed: true);
      f.business.advance(const Duration(hours: 25));
      expect(f.actions.canOpen('D17'), isTrue);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'D17');
      expect(find.text('Interaction limit reached'), findsWidgets);
      final balance = f.wallet.credits;
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(f.wallet.credits, balance);
    },
  );

  testWidgets(
    'photo-slot limit uses actual slot usage and preserves publications',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      for (var i = 0; i < f.publishing.config.photoSlots; i++) {
        final draft = f.publishing.createDraft(PublicationType.status);
        expect(
          f.publishing.publish(draft, f.publishing.review(draft)),
          PublishResult.success,
        );
      }
      expect(f.actions.canOpen('D15'), isTrue);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'D15');
      expect(find.text('Photo Status limit reached'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        f.publishing.publications,
        hasLength(f.publishing.config.photoSlots),
      );
      expect(
        f.publishing.publications.every(
          (item) => item.status == PublicationStatus.active,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'publication action sheet opens the selected publication details',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      final draft = f.publishing.createDraft(PublicationType.status)
        ..caption = 'Selected update';
      expect(
        f.publishing.publish(draft, f.publishing.review(draft)),
        PublishResult.success,
      );
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await select(tester, 'S14');
      expect(find.text('Selected update'), findsOneWidget);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Publication details'), findsOneWidget);
    },
  );
}
