import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/discover/controllers/discover_controller.dart';
import 'package:app/features/discover/ui/screens/discover_screen/discover_screen.dart';
import 'package:app/features/discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/ui/screens/onboarding_screen/onboarding_screen.dart';
import 'package:app/features/settings/adapters/settings_contacts_session.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/stories/ui/widgets/story_cover.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void configure(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 16);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 16);
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewInsets);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> reach(
  WidgetTester tester,
  Finder target, {
  double delta = 180,
}) async {
  await tester.pumpAndSettle();
  final list = find.byType(ListView).first;
  await tester.scrollUntilVisible(
    target,
    delta,
    scrollable: find
        .descendant(of: list, matching: find.byType(Scrollable))
        .first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      for (final allowContacts in [false, true]) {
        testWidgets(
          'onboarding ${allowContacts ? 'allow' : 'decline'} at $size, ${brightness.name}',
          (tester) async {
            configure(tester, size);
            final chats = ChatsController();
            final settings = SettingsController(chats: chats);
            final profile = OnboardingController()
              ..bindContactsSession(SettingsContactsSession(settings));
            var complete = false;
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.create(brightness),
                home: OnboardingScreen(
                  controller: profile,
                  onComplete: () => complete = true,
                ),
              ),
            );
            for (final document in ['Terms of Service', 'Privacy Policy']) {
              await tester.ensureVisible(find.text(document));
              await tester.tap(find.text(document));
              await tester.pumpAndSettle();
              await reach(
                tester,
                find.text(
                  'This text is provided for the prototype and is not a final legal document.',
                ),
              );
              await tester.pageBack();
              await tester.pumpAndSettle();
            }
            final provider = allowContacts
                ? 'Continue with Google'
                : 'Continue with Apple';
            await tester.ensureVisible(find.text(provider));
            await tester.tap(find.text(provider));
            await tester.pump();
            expect(find.text('Signing in…'), findsOneWidget);
            await tester.tap(find.text('Cancel'));
            await tester.pump(const Duration(milliseconds: 700));
            expect(find.text('Complete profile'), findsNothing);
            await tester.tap(find.text(provider));
            await tester.pump(const Duration(milliseconds: 700));
            await tester.pumpAndSettle();
            final avatar = tester.getRect(find.byType(CircleAvatar));
            expect(avatar.center.dx, closeTo(size.width / 2, 1));
            expect(
              avatar.top,
              greaterThanOrEqualTo(
                tester.getBottomRight(find.byType(AppBar)).dy,
              ),
            );
            await reach(tester, find.text('Continue'));
            await tester.tap(find.text('Continue'));
            await tester.pump();
            await reach(
              tester,
              find.byKey(const ValueKey('profile_name')),
              delta: -180,
            );
            expect(find.text('Enter your name.'), findsOneWidget);
            await tester.enterText(
              find.byKey(const ValueKey('profile_name')),
              'Alex Morgan',
            );
            await reach(tester, find.byKey(const ValueKey('phone_local')));
            await tester.enterText(
              find.byKey(const ValueKey('phone_local')),
              '+20 1234567890',
            );
            await tester.pump();
            expect(profile.phone.international, '+201234567890');
            tester.view.viewInsets = const FakeViewPadding(bottom: 220);
            tester.view.padding = const FakeViewPadding(top: 24);
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text('+20'));
            await tester.tap(find.text('+20'));
            await tester.pumpAndSettle();
            await tester.enterText(
              find.byKey(const ValueKey('country_code_search')),
              'France',
            );
            await tester.pumpAndSettle();
            await tester.tap(find.widgetWithText(ListTile, 'France'));
            await tester.pumpAndSettle();
            expect(profile.phone.international, '+331234567890');
            await tester.enterText(
              find.byKey(const ValueKey('phone_local')),
              '0033670000000',
            );
            await tester.pumpAndSettle();
            expect(profile.phone.international, '+33670000000');
            await reach(tester, find.byType(CheckboxListTile));
            await tester.tap(find.byType(CheckboxListTile));
            await reach(tester, find.text('Continue'));
            expect(
              tester.getBottomRight(find.text('Continue')).dy,
              lessThanOrEqualTo(size.height - 220),
            );
            await tester.tap(find.text('Continue'));
            tester.view.resetViewInsets();
            tester.view.padding = const FakeViewPadding(top: 24, bottom: 16);
            await tester.pumpAndSettle();
            await tester.tap(find.text('Continue'));
            await tester.pump();
            await reach(tester, find.text('Select at least three interests.'));
            for (final interest in ['Art', 'Music', 'Travel']) {
              await reach(
                tester,
                find.text(interest),
                delta: interest == 'Art' ? -180 : 180,
              );
              await tester.tap(find.text(interest));
              await tester.pump();
            }
            await tester.tap(find.text('Continue'));
            await tester.pumpAndSettle();
            if (allowContacts) {
              await tester.ensureVisible(find.text('Allow contacts'));
              await tester.tap(find.text('Allow contacts'));
              await tester.pump();
              expect(find.text('Finding mutual contacts…'), findsOneWidget);
              await tester.pump(const Duration(milliseconds: 800));
              await tester.pump();
              expect(profile.matchedContactNames, contains('Sarah Wilson'));
              await tester.ensureVisible(find.text('Continue to Discover'));
              await tester.tap(find.text('Continue to Discover'));
            } else {
              await tester.ensureVisible(find.text('Not now'));
              await tester.tap(find.text('Not now'));
            }
            expect(complete, isTrue);
            expect(
              settings.permissions['Contacts'],
              allowContacts ? MockPermission.allowed : MockPermission.denied,
            );
            expect(profile.interests, containsAll(['Art', 'Music', 'Travel']));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            profile.dispose();
            settings.dispose();
            chats.dispose();
          },
        );
      }

      testWidgets(
        'Discover refinement and Story recovery at $size, ${brightness.name}',
        (tester) async {
          configure(tester, size);
          final stories = StoriesController();
          final discover = DiscoverController();
          final wallet = WalletController();
          final business = BusinessController(wallet: wallet, stories: stories);
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.create(brightness),
              home: DiscoverScreen(
                controller: stories,
                discover: discover,
                businessController: business,
                onBusinessProfile: (_) {},
              ),
            ),
          );
          discover.setOnline(false);
          await tester.pump();
          expect(
            find.text('Offline · Showing available Stories'),
            findsOneWidget,
          );
          await reach(tester, find.widgetWithText(ActionChip, 'Food & drink'));
          await tester.tap(find.widgetWithText(ActionChip, 'Food & drink'));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilterChip>(
                  find.widgetWithText(FilterChip, 'Food & drink'),
                )
                .selected,
            isTrue,
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 200);
          tester.view.padding = const FakeViewPadding(top: 24);
          await tester.enterText(find.byType(TextField), 'missing');
          await tester.pump();
          await reach(
            tester,
            find.text('No stories match your search. Try another category.'),
          );
          await reach(tester, find.byType(TextField), delta: -180);
          await tester.enterText(find.byType(TextField), 'Brew');
          await tester.pumpAndSettle();
          discover.showError();
          await tester.pump();
          await reach(tester, find.text('Retry'));
          await tester.tap(find.text('Retry'));
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump();
          await reach(tester, find.text('Daily Brew'));
          tester.view.resetViewInsets();
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 16);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Daily Brew'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Pause'));
          await tester.pump();
          await tester.tap(find.byTooltip('Mute'));
          await tester.pump();
          expect(find.byTooltip('Unmute'), findsOneWidget);
          stories.setMediaFailed('brew', true);
          await tester.pump();
          await tester.tap(find.text('Retry'));
          await tester.pump();
          expect(stories.mediaFailed('brew'), isFalse);
          await tester.tap(find.byTooltip('Story options'));
          await tester.pumpAndSettle();
          expect(find.text('Block Daily Brew'), findsOneWidget);
          await tester.tapAt(const Offset(10, 100));
          await tester.pumpAndSettle();
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.byType(DiscoverSearchScreen), findsOneWidget);
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .controller
                .text,
            'Brew',
          );
          expect(
            tester
                .widget<FilterChip>(
                  find.widgetWithText(FilterChip, 'Food & drink'),
                )
                .selected,
            isTrue,
          );
          expect(stories.isSeen('brew'), isTrue);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          business.dispose();
          wallet.dispose();
          discover.dispose();
          stories.dispose();
        },
      );

      testWidgets(
        'Status creation and preview context at $size, ${brightness.name}',
        (tester) async {
          configure(tester, size);
          final stories = StoriesController();
          final chats = ChatsController();
          var created = false;
          var explored = false;
          String? profileId;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.create(brightness),
              home: StatusScreen(
                controller: stories,
                chatsController: chats,
                onDiscover: () => explored = true,
                onCreate: () => created = true,
                onBusinessProfile: (story) => profileId = story.id,
              ),
            ),
          );
          await reach(tester, find.text('Create Status'));
          await tester.tap(find.text('Create Status'));
          expect(created, isTrue);
          await reach(tester, find.text('Sarah Wilson'));
          expect(
            tester
                .widget<StoryCover>(
                  find.ancestor(
                    of: find.text('Sarah Wilson'),
                    matching: find.byType(StoryCover),
                  ),
                )
                .seen,
            isFalse,
          );
          await tester.tap(find.text('Sarah Wilson'));
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Pause'));
          await tester.pump();
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(stories.isSeen('sarah'), isTrue);
          await reach(tester, find.text('Sarah Wilson'));
          expect(
            tester
                .widget<StoryCover>(
                  find.ancestor(
                    of: find.text('Sarah Wilson'),
                    matching: find.byType(StoryCover),
                  ),
                )
                .seen,
            isTrue,
          );
          await reach(tester, find.text('Explore Discover'));
          await tester.tap(find.text('Explore Discover'));
          expect(explored, isTrue);
          await reach(tester, find.text('Discover preview'));
          await tester.ensureVisible(find.text('Maison Studio'));
          await tester.tap(find.text('Maison Studio'));
          await tester.pumpAndSettle();
          final viewer = tester.widget<StoryViewerScreen>(
            find.byType(StoryViewerScreen),
          );
          expect(viewer.story.id, 'maison');
          expect(
            viewer.storyQueue!.every(
              (story) => story.boosted || story.sponsored || story.popular,
            ),
            isTrue,
          );
          await tester.tap(find.text('View Business'));
          expect(profileId, 'maison');
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          chats.dispose();
          stories.dispose();
        },
      );
    }
  }
}
