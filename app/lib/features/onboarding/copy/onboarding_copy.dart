/// English copy for the onboarding feature.
abstract final class OnboardingCopy {
  static const cameroon = 'Cameroon';
  static const egypt = 'Egypt';
  static const unitedStates = 'United States';
  static const unitedKingdom = 'United Kingdom';
  static const france = 'France';
  static const nigeria = 'Nigeria';
  static const kenya = 'Kenya';
  static const india = 'India';
  static const unitedArabEmirates = 'United Arab Emirates';
  static const chooseASupportedCountryCode = 'Choose a supported country code.';
  static const enterYourPhoneNumber = 'Enter your phone number.';
  static const enterAValidPhoneNumber = 'Enter a valid phone number.';
  static const preferNotToSay = 'Prefer not to say';
  static const phoneNumber = 'Phone number';
  static const termsOfService = 'Terms of Service';
  static const privacyPolicy = 'Privacy Policy';
  static const usingWhizpee = 'Using Whizpee';
  static const yourPrivacy = 'Your privacy';
  static const termsIntroduction =
      'Whizpee helps people connect, share stories and discover businesses. Treat others with respect and share only content you have the right to use. Paid features show their terms before confirmation.';
  static const privacyIntroduction =
      'You control the information you share and your audience settings. Contact matching requires permission and is intended to help you find mutual contacts. You may change your choices in settings.';
  static const aSafeCommunity = 'A safe community';
  static const yourChoices = 'Your choices';
  static const communityGuidelines =
      'Do not use the service to harass, impersonate, mislead or harm others. You can block or report an account and manage your profile and content.';
  static const privacyChoices =
      'You can review your profile, manage privacy preferences, block accounts, or request account deletion. This demonstration uses simulated data and does not access your contacts.';
  static const legalPrototypeNotice =
      'This text is provided for the prototype and is not a final legal document.';
  static const whizpee = 'Whizpee';
  static const welcomeTagline = 'Your people. Your stories.\nAll in one place.';
  static const signingIn = 'Signing in…';
  static const signInCancelledYouCanTryAgain =
      'Sign-in cancelled. You can try again.';
  static const signInFailedPleaseTryAgain = 'Sign-in failed. Please try again.';
  static const continueWithGoogle = 'Continue with Google';
  static const continueWithApple = 'Continue with Apple';
  static const byContinuingYouAgreeToOur = 'By continuing, you agree to our';
  static const art = 'Art';
  static const beauty = 'Beauty';
  static const business = 'Business';
  static const design = 'Design';
  static const fashion = 'Fashion';
  static const food = 'Food';
  static const gaming = 'Gaming';
  static const health = 'Health';
  static const music = 'Music';
  static const photography = 'Photography';
  static const sports = 'Sports';
  static const technology = 'Technology';
  static const travel = 'Travel';
  static const chooseAnInterest = 'Choose an interest';
  static const yourInterests = 'Your interests';
  static const chooseOneInterestForYourAudience =
      'Choose one interest for your audience.';
  static const onboardingInterestsDescription =
      'Choose at least three interests to personalize your experience.';
  static const selectOneInterest = 'Select one interest.';
  static const selectAtLeastThreeInterests = 'Select at least three interests.';
  static const capturePhoto = 'Capture photo';
  static const sampleCaptured = 'Sample captured';
  static const cameraSimulation = 'Camera simulation';
  static const switchCamera = 'Switch camera';
  static const retake = 'Retake';
  static const capture = 'Capture';
  static const frontCameraPhoto = 'Front camera photo';
  static const cameraPhoto = 'Camera photo';
  static const usePhoto = 'Use photo';
  static const yourProfileChangesHaveNotBeenSaved =
      'Your profile changes have not been saved.';
  static const profilePhoto = 'profile photo';
  static const completeProfile = 'Complete profile';
  static const chooseProfilePhoto = 'Choose profile photo';
  static const profilePhotoAdded = 'Profile photo added';
  static const yourName = 'Your name';
  static const enterYourName = 'Enter your name';
  static const requiredNameError = 'Enter your name.';
  static const gender = 'Gender';
  static const woman = 'Woman';
  static const man = 'Man';
  static const anotherIdentity = 'Another identity';
  static const termsConsent =
      'I agree to the Terms of Service and Privacy Policy';
  static const pleaseAcceptTheTermsToContinue =
      'Please accept the terms to continue.';
  static const findYourContacts = 'Find your contacts';
  static const noMatchingContactsYet = 'No matching contacts yet';
  static const mutualContactsFound = 'Mutual contacts found';
  static const contactsAccessDeclined = 'Contacts access declined';
  static const contactMatchingFailed = 'Contact matching failed';
  static const connectWithPeopleYouKnow = 'Connect with people you know';
  static const noMatchesDescription =
      'Your contacts will appear here when mutual matches are available.';
  static const declinedContactsDescription =
      'You can continue without contacts and change this choice later in settings.';
  static const failedMatchingDescription =
      'Your choice is saved. Retry matching or continue without contacts.';
  static const contactsExplanation =
      'With your permission, Whizpee can find people who have also saved your number. You can decide later.';
  static const findingMutualContacts = 'Finding mutual contacts…';
  static const cancelMatching = 'Cancel matching';
  static const continueToDiscover = 'Continue to Discover';
  static const retryMatching = 'Retry matching';
  static const allowContacts = 'Allow contacts';
  static const continueWithoutContacts = 'Continue without contacts';
  static const countryCode = 'Country code';
  static const searchCountryOrCode = 'Search country or code';
  static const noCountriesMatchYourSearch = 'No countries match your search.';
  static const photo = 'photo';
  static const camera = 'Camera';
  static const useASimulatedCapture = 'Use a simulated capture';
  static const libraryLabel = 'Library';
  static const chooseABundledSample = 'Choose a bundled sample';
  static const chooseAPhoto = 'Choose a photo';
  static const studioPortrait = 'Studio portrait';
  static const outdoorPortrait = 'Outdoor portrait';

  static String cameraPreview(bool front) =>
      '${front ? 'Front' : 'Back'} camera preview';
  static String matchedContactsDescription(Iterable<String> names) =>
      'You can connect with ${names.join(', ')}.';
  static String replaceMedia(String label) => 'Replace $label';
  static String addMedia(String label) => 'Add $label';
  static String removeMedia(String label) => 'Remove $label';
}
