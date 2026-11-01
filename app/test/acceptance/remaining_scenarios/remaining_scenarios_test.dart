import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/ui/screens/interests_screen/interests_screen.dart';
import 'package:app/features/onboarding/ui/screens/welcome_screen/welcome_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/price_review_screen/price_review_screen.dart';
import 'package:app/features/publishing/ui/screens/publications_screen/publications_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/ui/screens/settings_screen/settings_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('failed sign-in can retry and reach profile', (tester) async {
    final profile = OnboardingController()..setSignInState(SignInState.failed);
    addTearDown(profile.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(controller: profile, onComplete: () {}),
      ),
    );
    expect(find.text('Sign-in failed. Please try again.'), findsOneWidget);
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Complete profile'), findsOneWidget);
  });

  testWidgets('advertisement interest requires exactly one selection', (
    tester,
  ) async {
    final profile = OnboardingController();
    addTearDown(profile.dispose);
    Set<String>? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => InterestsScreen(
                    controller: profile,
                    mode: InterestSelectionMode.advertisement,
                    onComplete: () {},
                    onSelected: (value) => selected = value,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Select one interest.'), findsOneWidget);
    await tester.tap(find.text('Art'));
    await tester.pump();
    await tester.tap(find.text('Music'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(selected, {'Music'});
    expect(profile.interests, isEmpty);
  });

  testWidgets('Business profile hides contact action for unavailable Story', (
    tester,
  ) async {
    final wallet = WalletController();
    final business = BusinessController(wallet: wallet);
    addTearDown(() {
      business.dispose();
      wallet.dispose();
    });
    final story = StoriesController.stories.firstWhere((s) => s.id == 'maison');
    business.setSourceEligible(story.id, false);
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessProfileScreen(controller: business, story: story),
      ),
    );
    expect(
      find.text('There are no active Stories available for this Business.'),
      findsOneWidget,
    );
    expect(find.text('Contact about this Story'), findsNothing);
    business.setSourceEligible(story.id, true);
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Contact about this Story'), 150);
    expect(find.text('Contact about this Story'), findsOneWidget);
  });

  for (final paid in [false, true]) {
    testWidgets(
      '${paid ? 'paid' : 'free'} category displays its mock cost and publishes a photo into an available slot',
      (tester) async {
        final wallet = WalletController();
        final publishing = PublishingController(wallet: wallet);
        addTearDown(() {
          publishing.dispose();
          wallet.dispose();
        });
        final draft = publishing.createDraft(PublicationType.status)
          ..paidCategory = paid
          ..category = paid ? 'Design' : 'Everyday';
        final before = wallet.credits;
        await tester.pumpWidget(
          MaterialApp(
            home: PriceReviewScreen(controller: publishing, draft: draft),
          ),
        );
        expect(find.text('Photo Status slots: 0/3 used'), findsOneWidget);
        expect(
          publishing.review(draft).category,
          paid ? publishing.config.categoryFee : 0,
        );
        await tester.ensureVisible(find.text('Publish'));
        await tester.tap(find.text('Publish'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(publishing.publications, hasLength(1));
        expect(publishing.availablePhotoSlots, 2);
        expect(
          wallet.credits,
          before - (paid ? publishing.config.categoryFee : 0),
        );
      },
    );
  }

  testWidgets('active customer room permits mock messages', (tester) async {
    final wallet = WalletController();
    final chats = ChatsController();
    final business = BusinessController(wallet: wallet, chats: chats);
    addTearDown(() {
      business.dispose();
      chats.dispose();
      wallet.dispose();
    });
    final story = StoriesController.stories.firstWhere((s) => s.id == 'maison');
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    final creditsAfterOpening = wallet.credits;
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessConversationScreen(controller: business, story: story),
      ),
    );
    expect(find.text('Business room · active'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Message'),
      'Hello there',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    expect(find.text('Hello there'), findsOneWidget);
    expect(wallet.credits, creditsAfterOpening);
  });

  testWidgets('empty publications remains empty when filters change', (
    tester,
  ) async {
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    addTearDown(() {
      publishing.dispose();
      wallet.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(home: PublicationsScreen(controller: publishing)),
    );
    expect(find.text('No publications in this view yet.'), findsOneWidget);
    await tester.tap(find.text('Advertisements'));
    await tester.pump();
    expect(find.text('No publications in this view yet.'), findsOneWidget);
  });

  testWidgets('incomplete Business profile directs user to validation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final profile = OnboardingController();
    addTearDown(() {
      settings.dispose();
      chats.dispose();
      profile.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          controller: settings,
          profile: profile,
          onSignOut: () {},
          onAppearance: () {},
          onProfileUpdated: () {},
        ),
      ),
    );
    expect(find.text('Complete your public Business profile'), findsOneWidget);
    await tester.tap(find.text('Edit Business profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.ensureVisible(find.text('Enter a Business name.'));
    expect(find.text('Enter a Business name.'), findsOneWidget);
    expect(settings.businessProfile.isComplete, isFalse);
  });
}
