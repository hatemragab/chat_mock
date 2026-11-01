/// English UI copy for the session-only calls experience.
abstract final class CallsCopy {
  static const callAlreadyInProgress = 'A call is already in progress';
  static const callPermissionUnavailable =
      'Microphone or camera access is unavailable. Update permissions to place or answer a call.';
  static const insufficientCreditsToStart =
      'Not enough Credits to start the call';
  static const paidBoundaryEnded =
      'Call ended at the paid-block boundary because the balance is insufficient';
  static const ringing = 'Ringing…';
  static const permissionRequired = 'Permission required';
  static const minimizeCall = 'Minimize call';
  static const businessCallBanner = 'BUSINESS CALL';
  static const creditsRunningLow = 'Your Credits are running low';
  static const lowBalanceExplanation =
      'The call ends at the next paid-block boundary if the balance is insufficient.';
  static const lowBalanceDetails = 'Low balance details';
  static const youFrontCamera = 'You · front';
  static const youBackCamera = 'You · back';
  static const cameraOff = 'Camera off';
  static const cameraPreview = 'Camera preview';
  static const recipientNotCharged = 'No charge to recipient';
  static const unmute = 'Unmute';
  static const mute = 'Mute';
  static const audioOutput = 'Audio output';
  static const turnCameraOff = 'Turn camera off';
  static const turnCameraOn = 'Turn camera on';
  static const switchCamera = 'Switch camera';
  static const answer = 'Answer';
  static const simulateAnswer = 'Simulate answer';
  static const decline = 'Decline';
  static const simulateOutcome = 'Simulate call outcome';
  static const busy = 'Busy';
  static const declined = 'Declined';
  static const unanswered = 'Unanswered';
  static const endCall = 'End call';
  static const permissionNeeded = 'Permission needed';
  static const permissionHelpExplanation =
      'Microphone access is needed for calls. Video calls also need camera access. In this demo, you can simulate restoring access.';
  static const simulateOpeningSettings = 'Simulate opening Settings';
  static const permissionHelp = 'Permission help';
  static const viewSummary = 'View summary';
  static const callSummary = 'Call summary';
  static const result = 'Result';
  static const duration = 'Duration';
  static const charged = 'Charged';
  static const callAgain = 'Call again';
  static const returnToStoryToStart =
      'Return to the originating Story to start another Business call.';
  static const calls = 'Calls';
  static const recent = 'Recent';
  static const missed = 'Missed';
  static const business = 'Business';
  static const mutualContactRequired =
      'A mutual, unblocked contact match is required to place a call.';
  static const personalCallsFree = 'Personal calls are free';
  static const audioCall = 'Audio call';
  static const videoCall = 'Video call';
  static const endCurrentCallFirst =
      'End the current call before starting another.';
  static const tapToReturn = 'Tap to return';
  static const noCalls = 'No calls in this view yet.';
  static const startCall = 'Start a call';
  static const lowCallBalance = 'Low call balance';
  static const ok = 'OK';
  static const deleteCallQuestion = 'Delete call?';
  static const callDetails = 'Call details';
  static const deleteCall = 'Delete call';
  static const cost = 'Cost';
  static const originatingStory = 'Originating Story';
  static const returnToStoryToPlace =
      'Return to the originating Story to place another Business call.';
  static const message = 'Message';
  static const earpiece = 'Earpiece';
  static const speaker = 'Speaker';
  static const bluetoothDevice = 'Bluetooth device';
  static const lowCredits = 'Low Credits';
  static const audioKind = 'audio';
  static const videoKind = 'video';
  static const phaseRinging = 'ringing';
  static const phaseIncoming = 'incoming';
  static const phaseActive = 'active';
  static const phaseReconnecting = 'reconnecting';
  static const phaseBusy = 'busy';
  static const phaseDeclined = 'declined';
  static const phaseMissed = 'missed';
  static const phaseCancelled = 'cancelled';
  static const phaseEnded = 'ended';
  static const phasePermissionBlocked = 'permissionBlocked';
  static String incomingKind(String kind) => 'Incoming $kind call';
  static String reconnecting(String time) => 'Reconnecting… · $time';
  static String elapsed(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String minimizedSubtitle(
    String status, {
    required bool lowBalance,
    String? storyTitle,
  }) => '$status · ${lowBalance ? lowCredits : storyTitle ?? tapToReturn}';
  static String businessCallCharge(String kind) => 'Business $kind call';
  static String storySemantics(String author, String title) =>
      'Business Story: $author, $title';
  static String nextBlock(String kind, String name, int credits) =>
      'The next $kind block with $name costs $credits Credits. The current block will finish before the call ends.';
  static String remotePreview(String name) => '$name · remote preview';
  static String creditsCharged(int credits) => '$credits Credits charged';
  static String deleteHistoryQuestion(String name) =>
      'Remove the call with $name from your history?';
  static String directionKind(bool incoming, String kind) =>
      '${incoming ? 'Incoming' : 'Outgoing'} $kind call';
  static String durationValue(int seconds) =>
      '${seconds ~/ 60}m ${seconds % 60}s';
  static String creditCost(int credits) => '$credits Credits';
  static String callContact(String name) => 'Call $name';
  static String ongoingWith(String name) => 'Ongoing call with $name';
  static String historyStatus(bool incoming, String phase) =>
      '${incoming ? 'Incoming' : 'Outgoing'} · $phase';
}
