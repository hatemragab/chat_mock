import 'package:flutter/foundation.dart';

/// Contact matching state shown during onboarding.
enum ContactsState { idle, matching, matched, empty, denied, failed }

/// A session-only bridge to a retained contact-matching state owner.
/// Implementations must use mock data and must not request device contacts.
abstract interface class OnboardingContactsSession implements Listenable {
  ContactsState get contactsState;
  List<String> get matchedNames;
  void allowAndMatch({required Duration delay});
  void decline();
  void cancelMatching();
}
