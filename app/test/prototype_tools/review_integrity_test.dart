import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/ui/screens/prototype_tools_screen/prototype_tools_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Fixture {
  Fixture({bool seedBusiness = true}) {
    settings = SettingsController(chats: chats);
    chats.canMessage = () => settings.canMessage;
    group = GroupController(chats: chats);
    publishing = PublishingController(
      wallet: wallet,
      canPublish: () => settings.canPublish,
    );
    stories = StoriesController(publishing: publishing);
    business = BusinessController(
      wallet: wallet,
      chats: seedBusiness ? chats : null,
      stories: stories,
      settings: settings,
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
      settings: settings,
      profile: profile,
      onSignOut: () {},
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

Future<void> openReview(WidgetTester tester, Fixture f, String id) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => f.actions.open(context, id),
            child: const Text('Open review'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open review'));
  await tester.pump();
}

void main() {
  testWidgets('editor review uses shared Camera permission on replacement', (
    tester,
  ) async {
    final f = Fixture();
    f.settings.setPermission('Camera', MockPermission.permanentlyDenied);
    await openReview(tester, f, 'P41');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Replace or remove media'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(find.text('Camera access'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(f.settings.permissions['Camera'], MockPermission.allowed);
    expect(find.text('Camera simulation'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets(
    'Status review keeps session permissions through Story creation',
    (tester) async {
      final f = Fixture();
      f.settings.setPermission('Media', MockPermission.permanentlyDenied);
      await openReview(tester, f, 'P03');
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Story options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Publications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everyday'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Import media'));
      await tester.tap(find.text('Import media'));
      await tester.pumpAndSettle();
      expect(find.text('Media access'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(f.settings.permissions['Media'], MockPermission.allowed);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );

  testWidgets('publications review creates with the shared media permission', (
    tester,
  ) async {
    final f = Fixture();
    f.settings.setPermission('Media', MockPermission.permanentlyDenied);
    await openReview(tester, f, 'P49');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create publication'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Everyday'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Import media'));
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    expect(find.text('Media access'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(f.settings.permissions['Media'], MockPermission.allowed);
    expect(find.text('Simulated import'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('media review uses the session permission and recovery', (
    tester,
  ) async {
    final f = Fixture();
    f.settings.setPermission('Media', MockPermission.permanentlyDenied);
    await openReview(tester, f, 'P39');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Import media'));
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    expect(find.text('Media access'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(f.settings.permissions['Media'], MockPermission.allowed);
    expect(find.text('Simulated import'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('reconnecting calls can be advanced using the review control', (
    tester,
  ) async {
    final f = Fixture();
    final call = f.calls.start(name: 'Sarah Wilson', kind: CallKind.audio);
    expect(f.calls.answer(), isTrue);
    f.calls.setReconnecting(true);
    await tester.pumpWidget(
      MaterialApp(
        home: PrototypeToolsScreen(
          chats: f.chats,
          calls: f.calls,
          group: f.group,
          business: f.business,
          publishing: f.publishing,
          stories: f.stories,
          wallet: f.wallet,
          onReset: () {},
          onOnboarding: () {},
          themeMode: ThemeMode.system,
          onThemeChanged: (_) {},
          onAdvanceClock: (_) {},
        ),
      ),
    );
    final item = find.widgetWithText(ListTile, 'Advance call by one minute');
    await tester.scrollUntilVisible(item, 200);
    await tester.ensureVisible(item);
    await tester.pump();
    expect(tester.widget<ListTile>(item).enabled, isTrue);
    await tester.tap(item);
    await tester.pump();
    expect(call.phase, CallPhase.reconnecting);
    expect(call.seconds, 60);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets(
    'personal call review uses the current eligible contact identity',
    (tester) async {
      final f = Fixture();
      final sarah = f.chats.byId('sarah');
      expect(
        f.chats.updateContact(sarah, 'Sarah Renamed', sarah.phone!),
        isTrue,
      );
      f.chats.toggleBlocked(sarah);
      expect(f.actions.canOpen('V045'), isFalse);
      expect(f.actions.canOpen('V050'), isFalse);
      f.chats.toggleBlocked(sarah);
      await openReview(tester, f, 'V050');
      await tester.pumpAndSettle();
      expect(find.text('Sarah Renamed'), findsOneWidget);
      expect(f.calls.active?.contactId, sarah.id);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );

  testWidgets('incoming-call control tracks blocked and reset contacts', (
    tester,
  ) async {
    final f = Fixture();
    await tester.pumpWidget(
      MaterialApp(
        home: PrototypeToolsScreen(
          chats: f.chats,
          calls: f.calls,
          group: f.group,
          business: f.business,
          publishing: f.publishing,
          stories: f.stories,
          wallet: f.wallet,
          onReset: () {},
          onOnboarding: () {},
          themeMode: ThemeMode.system,
          onThemeChanged: (_) {},
          onAdvanceClock: (_) {},
        ),
      ),
    );
    final item = find.widgetWithText(ListTile, 'Simulate an incoming call');
    await tester.scrollUntilVisible(item, 200);
    expect(tester.widget<ListTile>(item).enabled, isTrue);
    f.chats.toggleBlocked(f.chats.byId('sarah'));
    await tester.pump();
    expect(tester.widget<ListTile>(item).enabled, isFalse);
    f.chats.reset();
    await tester.pump();
    expect(tester.widget<ListTile>(item).enabled, isTrue);
    final sarah = f.chats.byId('sarah');
    f.chats.updateContact(sarah, 'Sarah Renamed', sarah.phone!);
    await tester.pump();
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(f.calls.active?.name, 'Sarah Renamed');
    expect(f.calls.active?.contactId, sarah.id);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  test(
    'scenario availability respects restrictions, blocks, and playable Stories',
    () {
      final f = Fixture();
      final source = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      expect(f.actions.canOpen('V046'), isTrue);
      expect(f.actions.canOpen('S11'), isTrue);
      f.business.setBlocked(source, true);
      expect(f.actions.canOpen('V046'), isFalse);
      expect(f.actions.canOpen('S11'), isFalse);
      f.business.setBlocked(source, false);
      f.stories.setAvailability(source.id, StoryAvailability.expired);
      expect(f.actions.canOpen('V046'), isFalse);
      f.settings.setRestriction(RestrictionLevel.suspension);
      expect(f.actions.canOpen('V018'), isFalse);
      expect(f.actions.canOpen('S04'), isFalse);
      for (final story in f.stories.allStories.where(
        (item) => item.media == StoryMedia.video,
      )) {
        f.stories.setMediaFailed(story.id, true);
      }
      expect(f.actions.canOpen('V060'), isFalse);
      expect(f.actions.canOpen('V067'), isTrue);
      f.dispose();
    },
  );

  testWidgets('restriction review changes actual session permissions', (
    tester,
  ) async {
    final f = Fixture();
    await openReview(tester, f, 'V129');
    await tester.pumpAndSettle();
    expect(f.settings.restriction, RestrictionLevel.suspension);
    expect(f.chats.canSendTo(f.chats.byId('sarah')), isFalse);
    expect(f.publishing.canPublish!(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('price review fixture leaves other drafts current', (
    tester,
  ) async {
    final f = Fixture();
    final other = f.publishing.createDraft(PublicationType.status);
    final terms = f.publishing.review(other);
    await openReview(tester, f, 'D14');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Price changed'), findsOneWidget);
    expect(f.publishing.review(other).revision, terms.revision);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('failed report retries with the same target and can succeed', (
    tester,
  ) async {
    final f = Fixture();
    await openReview(tester, f, 'V127');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('Maison Studio'), findsWidgets);
    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Report submitted'), findsOneWidget);
    expect(find.textContaining('Maison Studio'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });
  testWidgets('reviewed Chats preserves the Business room destination', (
    tester,
  ) async {
    final f = Fixture();
    await openReview(tester, f, 'P01');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maison Studio'));
    await tester.pumpAndSettle();
    expect(find.byType(BusinessConversationScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets(
    'recipient review keeps an active room after its source expires',
    (tester) async {
      final f = Fixture();
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      expect(
        f.business.openRoom(story, confirmed: true),
        OpenRoomResult.opened,
      );
      final balance = f.wallet.credits;
      f.business.setSourceEligible(story.id, false);
      expect(f.actions.canOpen('V085'), isTrue);
      await openReview(tester, f, 'V085');
      await tester.pumpAndSettle();
      expect(find.byType(BusinessConversationScreen), findsOneWidget);
      expect(f.wallet.credits, balance);
      expect(f.business.isActive(f.business.roomFor(story.id)!), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      f.dispose();
    },
  );

  test('recipient review is unavailable for blocked or missing sources', () {
    final f = Fixture(seedBusiness: false);
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'maison',
    );
    expect(f.business.roomFor(story.id), isNull);
    expect(f.actions.canOpen('V085'), isTrue);
    f.business.setBlocked(story, true);
    expect(f.actions.canOpen('V085'), isFalse);
    f.business.setBlocked(story, false);
    f.business.setSourceEligible(story.id, false);
    expect(f.actions.canOpen('V085'), isFalse);
    f.dispose();
  });

  testWidgets('shared media review returns to the original message', (
    tester,
  ) async {
    final f = Fixture();
    final chat = f.chats.conversations.firstWhere((item) => item.id == 'sarah');
    chat.messages.add(
      ChatMessage(
        id: 'review-photo',
        author: 'Sarah',
        text: 'Holiday photo',
        time: DateTime(2026),
        isMine: false,
        kind: MessageKind.photo,
      ),
    );
    await openReview(tester, f, 'P16');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Holiday photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show in chat'));
    await tester.pumpAndSettle();
    final screen = tester.widget<ConversationScreen>(
      find.byType(ConversationScreen),
    );
    expect(screen.chat, same(chat));
    expect(screen.initialMessageId, 'review-photo');
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });
  testWidgets('sign-in review runs the actual completion timer', (
    tester,
  ) async {
    final f = Fixture();
    await openReview(tester, f, 'V004');
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Complete profile'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });

  testWidgets('sign-in review cancellation stops its completion timer', (
    tester,
  ) async {
    final f = Fixture();
    await openReview(tester, f, 'V004');
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in cancelled. You can try again.'), findsOneWidget);
    expect(find.text('Complete profile'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    f.dispose();
  });
}
