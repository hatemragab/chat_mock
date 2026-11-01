/// English copy for the isolated prototype review tools.
abstract final class PrototypeToolsCopy {
  static const reviewInventory = 'Review inventory';
  static const searchIdOrName = 'Search ID or name';
  static const pages = 'Pages';
  static const sheets = 'Sheets';
  static const dialogs = 'Dialogs';
  static const scenarios = 'Scenarios';
  static const noMatchingReviewItems = 'No matching review items.';
  static const openCurrentImplementation = 'Open current implementation';
  static const notAvailableInTheCurrentSession =
      'Not available in the current session';
  static const prototypeTools = 'Prototype tools';
  static const reviewControls = 'Review controls';
  static const sessionControlsDescription =
      'These controls change the in-memory demonstration session.';
  static const searchReviewInventory = 'Search review inventory';
  static const inventoryDescription = 'Pages, sheets, dialogs and scenarios';
  static const appearance = 'Appearance';
  static const light = 'Light';
  static const dark = 'Dark';
  static const system = 'System';
  static const online = 'Online';
  static const offlineMessagesDescription =
      'Offline messages queue until reconnected.';
  static const simulateAnIncomingMessage = 'Simulate an incoming message';
  static const callPermissionsAvailable = 'Call permissions available';
  static const simulateMicrophoneAndCameraPermission =
      'Simulate microphone and camera permission.';
  static const advanceCallByOneMinute = 'Advance call by one minute';
  static const returnToActiveCall = 'Return to active call';
  static const callReconnecting = 'Call reconnecting';
  static const simulateAnIncomingCall = 'Simulate an incoming call';
  static const startOnboarding = 'Start onboarding';
  static const resetDemo = 'Reset demo';
  static const resetDescription = 'Restore the initial in-memory fixtures.';
  static const resetDemoTitle = 'Reset demo?';
  static const sessionChangesWillBeLost = 'Session changes will be lost.';
  static const reset = 'Reset';
  static const publicationViews = 'Publication views';
  static const noPublicationDescription =
      'Publish a Status or advertisement to review view counts.';
  static const publication = 'Publication';
  static const addContactView = 'Add contact view';
  static const addHeldView = 'Add held view';
  static const reachPopularThreshold = 'Reach Popular threshold';
  static const openAggregateAnalytics = 'Open aggregate analytics';
  static const openContactViewers = 'Open contact viewers';
  static const groupPerspective = 'Group perspective';
  static const reviewAsMember = 'Review as member';
  static const openGroup = 'Open group';
  static const businessRoom = 'Business room';
  static const reviewAs = 'Review as';
  static const customerPayer = 'Customer / payer';
  static const businessRecipient = 'Business recipient';
  static const roomExpiryDescription =
      'An existing paid room remains active when its Story expires.';
  static const advanceBusinessRoomClockBy24Hours =
      'Advance Business room clock by 24 hours';
  static const reviewRoomExpiryWithoutWaiting =
      'Review room expiry without waiting.';
  static const addAnIncomingRoomFixture = 'Add an incoming room fixture';
  static const openBusinessProfile = 'Open Business profile';
  static const advanceDirectMessageReceipt = 'Advance direct-message receipt';
  static const readReceiptsAreDisabled = 'Read receipts are disabled.';
  static const sendADirectMessageToReviewDelivery =
      'Send a direct message to review delivery.';
  static const diamondConversion = 'Diamond conversion';
  static const increaseRateByOneXaf = 'Increase rate by 1 XAF';
  static const restoreDefaultRate = 'Restore default rate';
  static const failNextConversion = 'Fail next conversion';
  static const conversionFailureDescription =
      'A failed attempt preserves balances and can be retried.';
  static const paymentAndPayout = 'Payment and payout';
  static const noPaymentDescription =
      'Start a simulated purchase in Wallet to control its outcome.';
  static const latestPayment = 'Latest payment';
  static const noWithdrawalDescription =
      'Create a withdrawal request to control its outcome.';
  static const latestWithdrawal = 'Latest withdrawal';
  static const reject = 'Reject';
  static const fail = 'Fail';
  static const unsupportedOnboardingCase = 'Unsupported onboarding review case';
  static const signOutTitle = 'Sign out?';
  static const youCanSignInAgainToContinue =
      'You can sign in again to continue the demo.';
  static const signOutAction = 'Sign out';
  static const profilePhotoLabel = 'profile photo';
  static const deviceContactsSimulation =
      'Device contacts opened in simulation. No contact was changed.';
  static const conversionSuccess = 'Diamonds converted to Cash.';
  static const conversionFailure =
      'Conversion failed or the rate changed. Review and retry.';
  static const profilePhoto = 'Profile photo';
  static const gettingStarted = 'Getting started';
  static const gettingStartedDescription =
      'Choose your interests and complete your profile to make Whizpee your own. You can change these details later.';
  static const warningReason = 'Please review our community guidelines.';
  static const suspensionReason = 'Your account is temporarily suspended.';
  static const permanentRestrictionReason =
      'Your account is permanently restricted.';

  static String incomingMessage(String? contact) =>
      '${contact ?? 'The sample contact'} sends a local demo message.';
  static String currentCall(String name) => 'Current call: $name';
  static String publicationSummary(
    String category,
    String sample,
    String status,
  ) => '$category · $sample · $status';
  static String viewCounts(int qualified, int held) =>
      '$qualified qualified · $held held for review';
  static String demoViewer(String number) => 'Demo viewer $number';
  static String memberSummary(String name, String role, bool active) =>
      '$name · $role${active ? '' : ' (departed)'}';
  static String storyAvailable(String author) => '$author Story is available';
  static String receiptProgress(String name, String current, String next) =>
      '$name · $current → $next';
  static String conversionRate(int rate) =>
      'Current rate: 1 Diamond = $rate XAF';
  static String paymentSummary(int credits, String status) =>
      '$credits Credits · $status';
  static String withdrawalSummary(int amount, String status) =>
      '$amount XAF · $status';
  static String advanceWithdrawal(String status) => 'Advance to $status';
  static String unsupportedSheet(String id) => 'Unsupported review sheet $id';
  static String unsupportedPage(String id) => 'Unsupported review page $id';
  static String storyTarget(String author, String title) => '$author · $title';
}
