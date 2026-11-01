import '../copy/onboarding_copy.dart';

import 'package:flutter/foundation.dart';

import '../models/onboarding_contacts_session.dart';
import '../models/phone_number.dart';

export '../models/onboarding_contacts_session.dart' show ContactsState;

enum SignInState { idle, loading, failed, cancelled }

/// Session-only onboarding draft. The caller may retain it after completion.
class OnboardingController extends ChangeNotifier {
  String name = '';
  String gender = OnboardingCopy.preferNotToSay;
  PhoneNumber phone = const PhoneNumber(
    country: PhoneCountry(OnboardingCopy.cameroon, '+237'),
    local: '',
  );
  bool termsAccepted = false;
  bool photoSelected = false;
  String? photoLabel;
  final Set<String> interests = <String>{};
  SignInState signInState = SignInState.idle;
  ContactsState contactsState = ContactsState.idle;
  OnboardingContactsSession? _contactsSession;
  List<String> _matchedContactNames = const [];

  bool get hasContactsSession => _contactsSession != null;
  List<String> get matchedContactNames =>
      List.unmodifiable(_matchedContactNames);

  /// Binds the retained session owner without taking ownership of it.
  void bindContactsSession(OnboardingContactsSession? session) {
    if (identical(_contactsSession, session)) return;
    _contactsSession?.removeListener(_onContactsSessionChanged);
    _contactsSession = session;
    _contactsSession?.addListener(_onContactsSessionChanged);
    _onContactsSessionChanged();
  }

  void _onContactsSessionChanged() {
    final session = _contactsSession;
    if (session == null) return;
    final names = session.matchedNames;
    if (contactsState == session.contactsState &&
        listEquals(_matchedContactNames, names)) {
      return;
    }
    contactsState = session.contactsState;
    _matchedContactNames = List.of(names);
    notifyListeners();
  }

  void startSessionContactMatching(Duration delay) =>
      _contactsSession?.allowAndMatch(delay: delay);

  void declineContacts() {
    final session = _contactsSession;
    if (session == null) {
      setContactsState(ContactsState.denied);
    } else {
      session.decline();
      _onContactsSessionChanged();
    }
  }

  void cancelSessionContactMatching() => _contactsSession?.cancelMatching();

  void reset() {
    name = '';
    gender = OnboardingCopy.preferNotToSay;
    phone = const PhoneNumber(
      country: PhoneCountry(OnboardingCopy.cameroon, '+237'),
      local: '',
    );
    termsAccepted = false;
    photoSelected = false;
    photoLabel = null;
    interests.clear();
    signInState = SignInState.idle;
    contactsState = ContactsState.idle;
    _matchedContactNames = const [];
    if (_contactsSession != null) {
      contactsState = _contactsSession!.contactsState;
      _matchedContactNames = List.of(_contactsSession!.matchedNames);
    }
    notifyListeners();
  }

  void setPhone(String input) {
    phone = phone.withInput(input);
    notifyListeners();
  }

  /// Restores a profile draft without normalizing or dropping validation state.
  void restoreProfile({
    required String name,
    required PhoneNumber phone,
    required String gender,
    required bool termsAccepted,
    required bool photoSelected,
    required String? photoLabel,
  }) {
    this.name = name;
    this.phone = phone;
    this.gender = gender;
    this.termsAccepted = termsAccepted;
    this.photoSelected = photoSelected;
    this.photoLabel = photoLabel;
    notifyListeners();
  }

  void setPhoto(String? label) {
    photoLabel = label;
    photoSelected = label != null;
    notifyListeners();
  }

  void setCountry(PhoneCountry country) {
    phone = phone.withCountry(country);
    notifyListeners();
  }

  void toggleInterest(String interest, {bool single = false}) {
    if (single) {
      interests
        ..clear()
        ..add(interest);
    } else if (!interests.remove(interest)) {
      interests.add(interest);
    }
    notifyListeners();
  }

  void setSignInState(SignInState value) {
    signInState = value;
    notifyListeners();
  }

  void setContactsState(ContactsState value) {
    contactsState = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _contactsSession?.removeListener(_onContactsSessionChanged);
    _contactsSession = null;
    super.dispose();
  }
}
