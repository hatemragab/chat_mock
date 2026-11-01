import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/privacy_screen/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'unblocking updates the shared conversation and reset restores settings',
    () {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final sarah = chats.byId('sarah');
      chats.toggleBlocked(sarah);
      expect(settings.blockedAccounts, contains(sarah));
      settings.unblock(sarah);
      expect(sarah.blocked, isFalse);
      expect(settings.blockedAccounts, isEmpty);
      settings.setAudience(StatusAudience.only, {'sarah'});
      settings.setReadReceipts(false);
      settings.setPermission('Camera', MockPermission.permanentlyDenied);
      settings.reset();
      expect(settings.audience, StatusAudience.contacts);
      expect(settings.audienceContactIds, isEmpty);
      expect(settings.readReceipts, isTrue);
      expect(settings.permissions['Camera'], MockPermission.denied);
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets('profile edits stay in a draft until valid save', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final profile = OnboardingController()..name = 'Alex Morgan';
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => EditProfileScreen(
                    profile: profile,
                    settings: settings,
                    onSaved: () => saved = true,
                  ),
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), '');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter your name.'), findsOneWidget);
    expect(profile.name, 'Alex Morgan');
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'New Name');
    await tester.enterText(
      find.byKey(const ValueKey('phone_local')),
      '+201234567890',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(profile.name, 'New Name');
    expect(profile.phone.international, '+201234567890');
    expect(find.text('Edit'), findsOneWidget);
    profile.dispose();
    settings.dispose();
    chats.dispose();
  });

  testWidgets('privacy photo selection requires save', (tester) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    await tester.pumpWidget(
      MaterialApp(home: PrivacyScreen(controller: settings)),
    );
    await tester.tap(find.text('Profile photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nobody'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.photoVisibility, PhotoVisibility.contacts);
    await tester.tap(find.text('Profile photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nobody'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(settings.photoVisibility, PhotoVisibility.nobody);
    settings.dispose();
    chats.dispose();
  });

  testWidgets('failed report keeps its target, reason, and explanation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(
          target: 'Maison Studio',
          outcome: ReportOutcome.failure,
        ),
      ),
    );
    await tester.tap(find.text('Spam'));
    await tester.enterText(find.byType(TextField), 'Unwanted messages');
    await tester.ensureVisible(find.text('Submit report'));
    await tester.tap(find.text('Submit report'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Report Maison Studio'), findsOneWidget);
    expect(find.text('Unwanted messages'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
