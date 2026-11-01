import 'package:flutter/material.dart';

import '../copy/prototype_tools_copy.dart';

import '../../onboarding/controllers/onboarding_controller.dart';
import '../../onboarding/models/phone_number.dart';
import '../../onboarding/ui/screens/complete_profile_screen/complete_profile_screen.dart';
import '../../onboarding/ui/screens/contacts_access_screen/contacts_access_screen.dart';
import '../../onboarding/ui/screens/interests_screen/interests_screen.dart';
import 'review_actions.dart';

const _onboardingReviewIds = {
  'S01',
  'D01',
  'V007',
  'V008',
  'V009',
  'V011',
  'V012',
};

/// Whether the required session context is available for these real screens.
bool canOpenOnboardingMissing(ReviewActions actions, String id) =>
    _onboardingReviewIds.contains(id) &&
    (id != 'S01' || actions.profile != null);

/// Opens the actual onboarding form/sheet with an isolated review draft where
/// validation or discard is being demonstrated. S01 uses the retained profile.
Future<void> openOnboardingMissing(
  ReviewActions actions,
  BuildContext context,
  String id,
) async {
  if (!canOpenOnboardingMissing(actions, id)) return;
  final navigator = Navigator.of(context);
  final anchor = ModalRoute.of(context);
  if (anchor == null) return;
  final retainedProfile = id == 'S01';
  final controller = retainedProfile
      ? actions.profile!
      : OnboardingController();
  if (id == 'V007') controller.termsAccepted = true;
  if (id == 'V008' || id == 'D01') {
    controller.name = 'Alex Morgan';
    controller.phone = const PhoneNumber(
      country: PhoneCountry('Cameroon', '+237'),
      local: '670000000',
    );
  }
  if (id == 'V011') controller.contactsState = ContactsState.denied;
  void finish() => navigator.popUntil((route) => identical(route, anchor));
  final Widget screen = switch (id) {
    'S01' => CompleteProfileScreen(
      controller: controller,
      onComplete: finish,
      initiallyShowCountryPicker: true,
    ),
    'V007' || 'V008' => CompleteProfileScreen(
      controller: controller,
      onComplete: finish,
      initiallyShowValidation: true,
    ),
    'D01' => CompleteProfileScreen(
      controller: controller,
      onComplete: finish,
      initialDraftName: 'Alex Morgan (edited)',
      initiallyPromptDiscard: true,
    ),
    'V009' => InterestsScreen(
      controller: controller,
      onComplete: finish,
      initiallyShowValidation: true,
    ),
    'V011' => ContactsAccessScreen(controller: controller, onComplete: finish),
    'V012' => ContactsAccessScreen(
      controller: controller,
      onComplete: finish,
      initiallyStartMatching: true,
      matchingDelay: const Duration(seconds: 4),
    ),
    _ => throw StateError(PrototypeToolsCopy.unsupportedOnboardingCase),
  };
  final route = MaterialPageRoute<void>(builder: (_) => screen);
  try {
    await navigator.push<void>(route);
    await route.completed;
  } finally {
    if (!retainedProfile) controller.dispose();
  }
}
