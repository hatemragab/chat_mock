import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/ui/screens/contacts_access_screen/contacts_access_screen.dart';
import 'package:app/features/settings/adapters/settings_contacts_session.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('continuing after matching fails preserves permission choice', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)..failNextContactMatch();
    final onboarding = OnboardingController()
      ..bindContactsSession(SettingsContactsSession(settings));
    addTearDown(() {
      onboarding.dispose();
      settings.dispose();
      chats.dispose();
    });
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ContactsAccessScreen(
          controller: onboarding,
          onComplete: () => completed = true,
        ),
      ),
    );
    await tester.tap(find.text('Allow contacts'));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Contact matching failed'), findsOneWidget);
    await tester.tap(find.text('Continue without contacts'));
    expect(completed, isTrue);
    expect(settings.permissions['Contacts'], MockPermission.allowed);
    expect(settings.contactMatchingState, ContactMatchingState.failed);
  });

  testWidgets(
    'allowing onboarding contacts retains real mock matching results in Settings',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final onboarding = OnboardingController()
        ..bindContactsSession(SettingsContactsSession(settings));
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ContactsAccessScreen(
            controller: onboarding,
            onComplete: () => completed = true,
          ),
        ),
      );
      await tester.tap(find.text('Allow contacts'));
      await tester.pump();
      expect(settings.permissions['Contacts'], MockPermission.allowed);
      expect(settings.contactMatchingState, ContactMatchingState.matching);
      expect(onboarding.contactsState, ContactsState.matching);
      expect(find.text('Finding mutual contacts…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(settings.contactMatchingState, ContactMatchingState.matched);
      expect(onboarding.contactsState, ContactsState.matched);
      expect(onboarding.matchedContactNames, contains('Sarah Wilson'));
      expect(find.text('Mutual contacts found'), findsOneWidget);
      expect(find.textContaining('Sarah Wilson'), findsOneWidget);
      await tester.tap(find.text('Continue to Discover'));
      expect(completed, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      onboarding.dispose();
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets(
    'decline does not block onboarding and later permission recovery syncs both views',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final onboarding = OnboardingController()
        ..bindContactsSession(SettingsContactsSession(settings));
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ContactsAccessScreen(
            controller: onboarding,
            onComplete: () => completed = true,
          ),
        ),
      );
      await tester.tap(find.text('Not now'));
      await tester.pump();
      expect(completed, isTrue);
      expect(settings.permissions['Contacts'], MockPermission.denied);
      expect(settings.contactMatchingState, ContactMatchingState.denied);
      expect(onboarding.contactsState, ContactsState.denied);
      settings.setPermission('Contacts', MockPermission.permanentlyDenied);
      await tester.pump();
      expect(onboarding.contactsState, ContactsState.denied);
      onboarding.startSessionContactMatching(Duration.zero);
      onboarding.declineContacts();
      expect(
        settings.permissions['Contacts'],
        MockPermission.permanentlyDenied,
      );
      expect(onboarding.contactsState, ContactsState.denied);
      settings.setPermission('Contacts', MockPermission.allowed);
      await tester.pump();
      expect(onboarding.contactsState, ContactsState.idle);
      settings.startContactMatching();
      await tester.pump(const Duration(milliseconds: 800));
      expect(onboarding.contactsState, ContactsState.matched);
      chats.toggleBlocked(chats.byId('sarah'));
      await tester.pump();
      expect(onboarding.matchedContactNames, isNot(contains('Sarah Wilson')));
      for (final contact in settings.matchedContacts.toList()) {
        chats.toggleBlocked(contact);
      }
      await tester.pump();
      expect(settings.contactMatchingState, ContactMatchingState.empty);
      expect(onboarding.contactsState, ContactsState.empty);
      chats.toggleBlocked(chats.byId('sarah'));
      await tester.pump();
      expect(settings.contactMatchingState, ContactMatchingState.matched);
      expect(onboarding.contactsState, ContactsState.matched);
      await tester.pumpWidget(const SizedBox.shrink());
      onboarding.dispose();
      settings.dispose();
      chats.dispose();
    },
  );

  testWidgets(
    'cancelling or failing matching does not leave a timer or overwrite retry results',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final onboarding = OnboardingController()
        ..bindContactsSession(SettingsContactsSession(settings));
      await tester.pumpWidget(
        MaterialApp(
          home: ContactsAccessScreen(controller: onboarding, onComplete: () {}),
        ),
      );
      await tester.tap(find.text('Allow contacts'));
      await tester.pump();
      await tester.tap(find.text('Cancel matching'));
      await tester.pump(const Duration(seconds: 1));
      expect(onboarding.contactsState, ContactsState.idle);
      expect(settings.contactMatchingState, ContactMatchingState.idle);
      settings.failNextContactMatch();
      await tester.tap(find.text('Allow contacts'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(onboarding.contactsState, ContactsState.failed);
      expect(find.text('Contact matching failed'), findsOneWidget);
      await tester.tap(find.text('Retry matching'));
      await tester.pump(const Duration(milliseconds: 800));
      expect(onboarding.contactsState, ContactsState.matched);
      expect(settings.matchedContacts, isNotEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      onboarding.dispose();
      settings.dispose();
      chats.dispose();
    },
  );
}
