import 'package:flutter/foundation.dart';

import '../../onboarding/models/onboarding_contacts_session.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_models.dart';

/// Adapts the retained, in-memory Settings state for the onboarding flow.
class SettingsContactsSession implements OnboardingContactsSession {
  const SettingsContactsSession(this.settings);

  final SettingsController settings;

  @override
  ContactsState get contactsState => switch (settings.contactMatchingState) {
    ContactMatchingState.idle => ContactsState.idle,
    ContactMatchingState.matching => ContactsState.matching,
    ContactMatchingState.matched => ContactsState.matched,
    ContactMatchingState.empty => ContactsState.empty,
    ContactMatchingState.denied => ContactsState.denied,
    ContactMatchingState.failed => ContactsState.failed,
  };

  @override
  List<String> get matchedNames => [
    for (final contact in settings.matchedContacts) contact.name,
  ];

  @override
  void allowAndMatch({required Duration delay}) {
    if (settings.permissions['Contacts'] != MockPermission.permanentlyDenied) {
      settings.setPermission('Contacts', MockPermission.allowed);
    }
    settings.startContactMatching(delay: delay);
  }

  @override
  void decline() {
    if (settings.permissions['Contacts'] != MockPermission.permanentlyDenied) {
      settings.setPermission('Contacts', MockPermission.denied);
    }
  }

  @override
  void cancelMatching() => settings.cancelContactMatching();

  @override
  void addListener(VoidCallback listener) {
    settings.addListener(listener);
    settings.chats.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    settings.removeListener(listener);
    settings.chats.removeListener(listener);
  }
}
