import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/safety/models/report_submission.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import 'package:app/features/settings/ui/screens/status_audience_screen/status_audience_screen.dart';
import 'package:app/features/settings/ui/screens/privacy_screen/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'privacy counts Business blocks once across originating Stories',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      settings.setBusinessBlocked('Maison Studio', true);
      chats.toggleBlocked(chats.byId('sarah'));
      final first = chats.ensureBusinessConversation('first', 'Maison Studio');
      final second = chats.ensureBusinessConversation(
        'second',
        'Maison Studio',
      );
      chats.toggleBlocked(first);
      chats.toggleBlocked(second);
      await tester.pumpWidget(
        MaterialApp(home: PrivacyScreen(controller: settings)),
      );
      await tester.scrollUntilVisible(find.text('Blocked accounts'), 150);
      expect(find.text('2 blocked'), findsOneWidget);
      settings.setBusinessBlocked('Maison Studio', false);
      await tester.pump();
      expect(find.text('1 blocked'), findsOneWidget);
      expect(first.blocked, isFalse);
      expect(second.blocked, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      settings.dispose();
      chats.dispose();
    },
  );

  test('audience respects contacts, exclusions and blocks', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    expect(settings.canShareStatusWith('sarah'), isTrue);
    expect(settings.canShareStatusWith('maison'), isFalse);
    expect(settings.canShareStatusWith('unknown'), isFalse);
    final unmatched = chats.addContact('Unmatched', '+237600123456');
    expect(settings.canShareStatusWith(unmatched.id), isFalse);
    settings.setAudience(StatusAudience.except, {'sarah'});
    expect(settings.canShareStatusWith('sarah'), isFalse);
    expect(settings.canShareStatusWith('amira'), isTrue);
    settings.setAudience(StatusAudience.only, {'sarah'});
    expect(settings.canShareStatusWith('sarah'), isTrue);
    expect(settings.canShareStatusWith('amira'), isFalse);
    settings.setAudience(StatusAudience.only, {unmatched.id});
    expect(settings.canShareStatusWith(unmatched.id), isFalse);
    settings.setAudience(StatusAudience.only, {'sarah'});
    chats.toggleBlocked(chats.byId('sarah'));
    expect(settings.canShareStatusWith('sarah'), isFalse);
    settings.dispose();
    chats.dispose();
  });

  test(
    'mock privacy, notification and restriction settings produce policies',
    () {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      expect(settings.canShowPhotoTo(isContact: false), isFalse);
      settings.setPhotoVisibility(PhotoVisibility.everyone);
      expect(settings.canShowPhotoTo(isContact: false), isTrue);
      expect(settings.canShowPhotoTo(isContact: true, blocked: true), isFalse);
      settings.setGroupNotifications(false);
      expect(settings.shouldNotify(NotificationKind.group), isFalse);
      expect(settings.shouldNotify(NotificationKind.message), isTrue);
      settings.setPermission('Notifications', MockPermission.denied);
      expect(settings.shouldNotify(NotificationKind.message), isFalse);
      settings.setRestriction(RestrictionLevel.warning);
      expect(settings.canMessage, isTrue);
      settings.setRestriction(RestrictionLevel.suspension);
      expect(settings.canMessage, isFalse);
      expect(settings.canPublish, isFalse);
      settings.reset();
      expect(settings.canMessage, isTrue);
      expect(settings.shouldNotify(NotificationKind.group), isTrue);
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets('Business profile validates, saves separately, and resets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      EditBusinessProfileScreen(controller: settings),
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
    await tester.scrollUntilVisible(
      find.text('Save'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(settings.businessProfile.isComplete, isFalse);
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Public Business name'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Public Business name'),
      'Maison Demo',
    );
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Description'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Interior design',
    );
    await tester.scrollUntilVisible(
      find.text('Save'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(settings.businessProfile.name, 'Maison Demo');
    expect(settings.businessProfile.isComplete, isTrue);
    settings.reset();
    expect(settings.businessProfile.isComplete, isFalse);
    settings.dispose();
    chats.dispose();
  });

  testWidgets(
    'failed report can retry the same target and draft successfully',
    (tester) async {
      final attempts = <ReportSubmission>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ReportScreen(
            target: 'Maison Studio',
            targetId: 'story-42',
            submit: (submission) async {
              attempts.add(submission);
              return attempts.length == 1
                  ? ReportOutcome.failure
                  : ReportOutcome.success;
            },
          ),
        ),
      );
      await tester.tap(find.text('Spam'));
      await tester.enterText(find.byType(TextField), 'Unwanted content');
      await tester.ensureVisible(find.text('Submit report'));
      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Report submitted'), findsOneWidget);
      expect(attempts.length, 2);
      expect(attempts.last.targetId, 'story-42');
      expect(attempts.last.reason, 'Spam');
      expect(attempts.last.details, 'Unwanted content');
    },
  );
  testWidgets(
    'audience uses the shared contact picker and persists selection on save',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => StatusAudienceScreen(controller: settings),
                  ),
                ),
                child: const Text('Audience'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Audience'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Only share with…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select contacts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sarah Wilson').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue (1)'));
      await tester.pumpAndSettle();
      expect(settings.audience, StatusAudience.contacts);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(settings.audience, StatusAudience.only);
      expect(settings.canShareStatusWith('sarah'), isTrue);
      expect(settings.canShareStatusWith('amira'), isFalse);
      settings.dispose();
      chats.dispose();
    },
  );
}
