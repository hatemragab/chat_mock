/// English copy for the safety feature.
abstract final class SafetyCopy {
  static const youCanContactThisBusinessAgain =
      'You can contact this Business again.';
  static const theyCanContactYouAgain = 'They can contact you again.';
  static const blockBusinessDescription =
      'This Business will be blocked across its Story conversations. Existing history remains available.';
  static const blockPersonalDescription =
      'This account will be blocked. Existing history remains available.';
  static const unblock = 'Unblock';
  static const block = 'Block';
  static const accountNotice = 'Account notice';
  static const accountWarning = 'Account warning';
  static const accountSuspended = 'Account suspended';
  static const accountPermanentlyRestricted = 'Account permanently restricted';
  static const warningDescription =
      'You can continue to use Whizpee while reviewing our community guidelines.';
  static const restrictionDescription =
      'Messaging and publishing are unavailable. You can review support information.';
  static const helpSupport = 'Help & support';
  static const spam = 'Spam';
  static const harassment = 'Harassment';
  static const inappropriateContent = 'Inappropriate content';
  static const other = 'Other';
  static const report = 'Report';
  static const reportSubmitted = 'Report submitted';
  static const whyAreYouReportingThis = 'Why are you reporting this?';
  static const additionalDetailsOptional = 'Additional details (optional)';
  static const reportFailureDescription =
      'Your report could not be submitted. Please try again.';
  static const submitting = 'Submitting…';
  static const submitReport = 'Submit report';

  static String blockQuestion(String name, {required bool unblock}) =>
      '${unblock ? SafetyCopy.unblock : block} $name?';
  static String reportThanks(String target) =>
      'Thank you for reporting $target.';
  static String reportTarget(String target) => 'Report $target';
}
