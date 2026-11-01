import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/appearance_screen/appearance_screen.dart';
import 'package:app/features/settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import 'package:app/features/settings/ui/screens/settings_screen/settings_screen.dart';
import 'package:app/features/safety/models/report_submission.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:app/features/safety/ui/screens/restriction_screen/restriction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session {
  _Session() {
    settings = SettingsController(chats: chats);
    profile.name = 'Alex Morgan';
    profile.setPhone('+237670000000');
  }
  final chats = ChatsController();
  final profile = OnboardingController();
  late final SettingsController settings;
  var signsOut = 0;
  var themeMode = ThemeMode.system;
  void dispose() {
    profile.dispose();
    settings.dispose();
    chats.dispose();
  }
}

Future<void> _reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 160,
}) async {
  await tester.pumpAndSettle();
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await Scrollable.ensureVisible(tester.element(finder.last), alignment: .5);
  await tester.pumpAndSettle();
  expect(finder.last.hitTestable(), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _tap(
  WidgetTester tester,
  String label, {
  double delta = 160,
}) async {
  final finder = find.text(label);
  await _reveal(tester, finder, delta: delta);
  await tester.tap(finder.last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _back(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _mount(
  WidgetTester tester,
  _Session session,
  Brightness brightness, {
  bool keyboard = false,
  Widget? home,
}) async {
  session.themeMode = brightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;
  final appKey = UniqueKey();
  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, update) => MaterialApp(
        key: appKey,
        theme: AppTheme.create(Brightness.light),
        darkTheme: AppTheme.create(Brightness.dark),
        themeMode: session.themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
            viewInsets: EdgeInsets.only(bottom: keyboard ? 200 : 0),
          ),
          child: child!,
        ),
        home:
            home ??
            Builder(
              builder: (context) => SettingsScreen(
                controller: session.settings,
                profile: session.profile,
                onProfileUpdated: () {},
                onSignOut: () => session.signsOut++,
                onAppearance: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AppearanceScreen(
                      mode: session.themeMode,
                      onChanged: (mode) =>
                          update(() => session.themeMode = mode),
                      textScaleFactor: session.settings.textScaleFactor,
                      onTextScaleChanged: session.settings.setTextScaleFactor,
                    ),
                  ),
                ),
              ),
            ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      for (final scenario in [
        'profile editing',
        'privacy and preferences',
        'support and account',
        'report and restrictions',
      ]) {
        testWidgets('$scenario at $size, ${brightness.name}, 1.3 text', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final session = _Session();
          final keyboard =
              scenario == 'profile editing' ||
              scenario == 'report and restrictions';
          await _mount(tester, session, brightness, keyboard: keyboard);
          switch (scenario) {
            case 'profile editing':
              await _tap(tester, 'Edit profile');
              await tester.tap(find.byTooltip('Change profile photo'));
              await tester.pumpAndSettle();
              await _tap(tester, 'Library');
              await _tap(tester, 'Outdoor portrait');
              await _reveal(tester, find.widgetWithText(TextField, 'Name'));
              await tester.enterText(
                find.widgetWithText(TextField, 'Name'),
                'Alex Updated',
              );
              await _reveal(tester, find.widgetWithText(TextField, 'About'));
              await tester.enterText(
                find.widgetWithText(TextField, 'About'),
                'Prototype profile',
              );
              await _reveal(tester, find.byKey(const ValueKey('phone_local')));
              await tester.enterText(
                find.byKey(const ValueKey('phone_local')),
                '+20 1234567890',
              );
              await _reveal(
                tester,
                find.byType(DropdownButtonFormField<String>),
              );
              await tester.tap(find.byType(DropdownButtonFormField<String>));
              await tester.pumpAndSettle();
              await tester.tap(find.text('Woman').last);
              await tester.pumpAndSettle();
              await _tap(tester, 'Design');
              await _tap(tester, 'Save');
              expect(session.profile.name, 'Alex Updated');
              expect(session.profile.phone.international, '+201234567890');
              expect(session.settings.about, 'Prototype profile');
              expect(session.profile.photoLabel, 'Outdoor portrait');
              expect(session.profile.gender, 'Woman');
              expect(session.profile.interests, contains('Design'));
              expect(find.byType(EditProfileScreen), findsNothing);
              await _tap(tester, 'Edit Business profile');
              await _tap(tester, 'Save');
              await _tap(tester, 'Add a cover image', delta: -160);
              await _tap(tester, 'Choose demo image');
              await _tap(tester, 'Add a logo');
              await _tap(tester, 'Choose demo image');
              final coverPreview = tester.widget<Container>(
                find.byKey(const ValueKey('business-cover-preview')),
              );
              expect(
                (coverPreview.decoration! as BoxDecoration).image!.image,
                const AssetImage(BusinessProfile.demoCoverAssetPath),
              );
              expect(
                tester
                    .widget<CircleAvatar>(
                      find.byKey(const ValueKey('business-logo-preview')),
                    )
                    .backgroundImage,
                const AssetImage(BusinessProfile.demoLogoAssetPath),
              );
              await _reveal(
                tester,
                find.widgetWithText(TextField, 'Public Business name'),
                delta: -160,
              );
              await tester.enterText(
                find.widgetWithText(TextField, 'Public Business name'),
                'Demo Design',
              );
              await _reveal(
                tester,
                find.byType(DropdownButtonFormField<String>),
              );
              await tester.tap(find.byType(DropdownButtonFormField<String>));
              await tester.pumpAndSettle();
              await tester.tap(find.text('Design').last);
              await tester.pumpAndSettle();
              await _reveal(
                tester,
                find.widgetWithText(TextField, 'Description'),
              );
              await tester.enterText(
                find.widgetWithText(TextField, 'Description'),
                'Design work and inspiration.',
              );
              await _reveal(
                tester,
                find.widgetWithText(TextField, 'Public location (optional)'),
              );
              await tester.enterText(
                find.widgetWithText(TextField, 'Public location (optional)'),
                'Demo city',
              );
              await _tap(tester, 'Save');
              expect(session.settings.businessProfile.isComplete, isTrue);
              expect(session.settings.businessProfile.name, 'Demo Design');
              expect(session.settings.businessProfile.logoSelected, isTrue);
              expect(session.settings.businessProfile.coverSelected, isTrue);
              expect(session.settings.businessProfile.location, 'Demo city');
              expect(
                session.settings.businessProfile.coverAssetPath,
                BusinessProfile.demoCoverAssetPath,
              );
              expect(
                session.settings.businessProfile.logoAssetPath,
                BusinessProfile.demoLogoAssetPath,
              );
              await _tap(tester, 'Edit Business profile');
              await _tap(tester, 'Demo cover selected · Change');
              await _tap(tester, 'Remove image');
              await _tap(tester, 'Demo logo selected · Change');
              await _tap(tester, 'Remove image');
              expect(
                find.byKey(const ValueKey('business-logo-preview')),
                findsNothing,
              );
              await _reveal(
                tester,
                find.widgetWithText(TextField, 'Public Business name'),
              );
              await tester.enterText(
                find.widgetWithText(TextField, 'Public Business name'),
                'Unsaved name',
              );
              await _back(tester);
              expect(find.text('Discard changes?'), findsOneWidget);
              await _tap(tester, 'Keep editing');
              expect(find.text('Unsaved name'), findsOneWidget);
              await _back(tester);
              await _tap(tester, 'Discard');
              expect(find.byType(EditBusinessProfileScreen), findsNothing);
              expect(session.settings.businessProfile.name, 'Demo Design');
              expect(session.settings.businessProfile.logoSelected, isTrue);
              expect(session.settings.businessProfile.coverSelected, isTrue);
            case 'privacy and preferences':
              await _tap(tester, 'Privacy');
              await _tap(tester, 'Profile photo');
              await _tap(tester, 'Nobody');
              await _tap(tester, 'Save');
              expect(session.settings.photoVisibility, PhotoVisibility.nobody);
              await _tap(tester, 'Status audience');
              await _tap(tester, 'Only share with…');
              await _tap(tester, 'Select contacts');
              await _tap(tester, 'Sarah Wilson');
              await _tap(tester, 'Continue (1)');
              await _tap(tester, 'Save');
              expect(session.settings.audience, StatusAudience.only);
              expect(session.settings.audienceContactIds, {'sarah'});
              await _tap(tester, 'Read receipts');
              expect(session.settings.readReceipts, isFalse);
              session.chats.toggleBlocked(session.chats.byId('sarah'));
              session.settings.setBusinessBlocked('Maison Studio', true);
              await _tap(tester, 'Blocked accounts');
              await tester.enterText(find.byType(TextField), 'Maison');
              await tester.pumpAndSettle();
              await _tap(tester, 'Unblock');
              await _tap(tester, 'Unblock');
              expect(
                session.settings.isBusinessBlocked('Maison Studio'),
                isFalse,
              );
              expect(
                find.text('No blocked accounts match your search.'),
                findsOneWidget,
              );
              await _back(tester);
              await _back(tester);
              await _tap(tester, 'Notifications');
              await _tap(tester, 'Messages');
              expect(session.settings.messageNotifications, isFalse);
              await _tap(tester, 'Message');
              expect(
                find.text('This notification type is turned off.'),
                findsOneWidget,
              );
              await _tap(tester, 'Messages', delta: -160);
              await _tap(tester, 'Groups');
              await _tap(tester, 'Calls');
              await _tap(tester, 'Show previews');
              await _tap(tester, 'Vibration');
              expect(session.settings.groupNotifications, isFalse);
              expect(session.settings.callNotifications, isFalse);
              expect(session.settings.previews, isFalse);
              expect(session.settings.vibration, isFalse);
              await _tap(tester, 'Message');
              expect(session.settings.notifications.items, hasLength(1));
              expect(
                session.settings.notifications.items.single.body(
                  showPreview: false,
                ),
                isNot(contains('Are we')),
              );
              await _back(tester);
              session.settings.setPermission(
                'Camera',
                MockPermission.permanentlyDenied,
              );
              await _tap(tester, 'Permissions and contact sync');
              await _tap(tester, 'Camera');
              await _tap(tester, 'Open settings');
              expect(
                session.settings.permissions['Camera'],
                MockPermission.allowed,
              );
              await _tap(tester, 'Find contacts', delta: -160);
              await tester.pump(const Duration(milliseconds: 800));
              await tester.pump();
              expect(
                session.settings.contactMatchingState,
                ContactMatchingState.matched,
              );
              await _back(tester);
              await _tap(tester, 'Appearance');
              await _tap(tester, 'System');
              expect(session.themeMode, ThemeMode.system);
              await _reveal(tester, find.byType(Slider));
              await tester.tapAt(
                tester.getCenter(find.byType(Slider)) + const Offset(50, 0),
              );
              await tester.pump();
              expect(session.settings.textScaleFactor, greaterThan(1));
            case 'support and account':
              await _tap(tester, 'Help & support');
              await tester.enterText(find.byType(TextField), 'wallet');
              await tester.pumpAndSettle();
              await _tap(tester, 'Wallet and Credits');
              expect(
                find.textContaining('Diamonds are rewards'),
                findsOneWidget,
              );
              await _back(tester);
              expect(
                tester
                    .widget<EditableText>(find.byType(EditableText))
                    .controller
                    .text,
                'wallet',
              );
              await _back(tester);
              await _tap(tester, 'About Whizpee');
              await _tap(tester, 'Terms of Service');
              expect(find.text('Using Whizpee'), findsOneWidget);
              await _back(tester);
              await _tap(tester, 'Privacy Policy');
              expect(find.text('Your privacy'), findsOneWidget);
              await _back(tester);
              await _back(tester);
              await _tap(tester, 'Account');
              expect(find.text('+237670000000'), findsOneWidget);
              await _tap(tester, 'Sign out');
              await _tap(tester, 'Cancel');
              expect(session.signsOut, 0);
              await _tap(tester, 'Delete account');
              final continueButton = find.widgetWithText(
                FilledButton,
                'Continue',
              );
              await _reveal(tester, continueButton);
              expect(
                tester.widget<FilledButton>(continueButton).onPressed,
                isNull,
              );
              await _tap(tester, 'I understand the consequences.');
              await _tap(tester, 'Continue');
              await _tap(tester, 'Cancel');
              expect(session.signsOut, 0);
              await _tap(tester, 'Continue');
              await _tap(tester, 'Delete account');
              expect(session.signsOut, 1);
            case 'report and restrictions':
              final submissions = <ReportSubmission>[];
              await _mount(
                tester,
                session,
                brightness,
                keyboard: true,
                home: ReportScreen(
                  target: 'Maison Studio Story',
                  targetId: 'story-maison',
                  submit: (submission) async {
                    submissions.add(submission);
                    return submissions.length == 1
                        ? ReportOutcome.failure
                        : ReportOutcome.success;
                  },
                ),
              );
              await _tap(tester, 'Spam');
              await _reveal(
                tester,
                find.widgetWithText(TextField, 'Additional details (optional)'),
              );
              await tester.enterText(
                find.widgetWithText(TextField, 'Additional details (optional)'),
                'Keep the Story context',
              );
              await _tap(tester, 'Submit report');
              expect(
                find.text(
                  'Your report could not be submitted. Please try again.',
                ),
                findsOneWidget,
              );
              await _tap(tester, 'Retry');
              expect(find.text('Report submitted'), findsOneWidget);
              expect(submissions, hasLength(2));
              expect(submissions.last.targetId, 'story-maison');
              expect(submissions.last.details, 'Keep the Story context');
              for (final level in RestrictionLevel.values) {
                await _mount(
                  tester,
                  session,
                  brightness,
                  home: RestrictionScreen(
                    level: level,
                    reason: 'Review the demo community rules.',
                  ),
                );
                await _tap(tester, 'Help & support');
                await tester.enterText(find.byType(TextField), 'Privacy');
                await tester.pumpAndSettle();
                await _tap(tester, 'Privacy and blocking');
                expect(
                  find.textContaining('Blocked accounts are listed'),
                  findsOneWidget,
                );
              }
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          session.dispose();
        });
      }
    }
  }
}
