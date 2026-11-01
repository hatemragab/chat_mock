/// English UI copy for the session-only business experience.
abstract final class BusinessCopy {
  static const storyRequired = 'A Business Story is required';
  static const messageDeleted = 'This message was deleted';
  static const businessStory = 'Business Story';
  static const publicIdentityExplanation =
      'Your public Business identity appears with this Story.';
  static const publicBusinessProfile = 'Public Business profile';
  static const editBusinessProfile = 'Edit Business profile';
  static const completePublicProfile = 'Complete your public Business profile';
  static const completePublicProfileExplanation =
      'Add a public name, category and description before linking a Story.';
  static const publicCoverSemantics = 'Public Business cover';
  static const publicLogoSemantics = 'Public Business logo';
  static const activeStories = 'Active Stories';
  static const noLinkedActiveStories =
      'There are no linked active Stories on this Business profile.';
  static const unlinkStory = 'Unlink Story';
  static const choosePromotedStory = 'Choose a promoted Story';
  static const linkStory = 'Link a Story';
  static const businessProfile = 'Business profile';
  static const noActiveStories =
      'There are no active Stories available for this Business.';
  static const contactAboutStory = 'Contact about this Story';
  static const deleteForEveryoneExplanation =
      'A deletion marker will remain in this conversation.';
  static const deleteForMeExplanation =
      'This removes the message from your local conversation.';
  static const deleteForEveryoneQuestion = 'Delete for everyone?';
  static const deleteForMeQuestion = 'Delete for me?';
  static const reply = 'Reply';
  static const copy = 'Copy';
  static const star = 'Star';
  static const unstar = 'Unstar';
  static const reactThumbsUp = 'React 👍';
  static const deleteForMe = 'Delete for me';
  static const deleteForEveryone = 'Delete for everyone';
  static const blockedRoomStatus = 'Business room · blocked';
  static const activeRoomStatus = 'Business room · active';
  static const unavailableRoomStatus = 'Business room · unavailable';
  static const expiredRoomStatus = 'Business room · expired';
  static const conversationInfo = 'Business conversation info';
  static const startConversation = 'Start the conversation about this Story.';
  static const unblockToContinue =
      'This Business is blocked. Unblock it in Privacy settings to continue.';
  static const messagingUnavailable =
      'Messaging is unavailable in this conversation.';
  static const expiredReadOnly = 'This room has expired. History is read-only.';
  static const unavailableCannotReopen =
      'The originating Story is unavailable, so this room cannot be reopened.';
  static const reopenRoom = 'Reopen room';
  static const blockedBusiness = 'This Business is blocked.';
  static const reportBusinessAndStory =
      'Report this Business and its originating Story';
  static const interactionLimitReached = 'Interaction limit reached';
  static const roomUnavailable = 'Room unavailable';
  static const cannotOpenRoomNow = 'This room cannot be opened right now.';
  static const originatingStoryUnavailable =
      'The originating Story is no longer available.';
  static const customerMustOpenRoom = 'The customer must open this room first.';
  static const roomOpeningInProgress =
      'This room is already being opened. Please try again shortly.';
  static const openRoom = 'Open room';
  static const continueMessageRoom = 'Continue message room';
  static const messageRoom = 'Message room';
  static const activeRoomNoAdditionalCharge =
      'Your room is active · no additional charge';
  static const audioCall = 'Audio call';
  static const videoCall = 'Video call';
  static const unblockBeforeCalling =
      'This Business is blocked. Unblock it before calling.';
  static const startCall = 'Start call';
  static const buyCredits = 'Buy Credits';
  static const roomActive = 'Room active';
  static const roomExpired = 'Room expired';
  static const noRoomOpened = 'No room has been opened';
  static const mediaFilesLinks = 'Media, files and links';
  static const starredMessages = 'Starred messages';
  static const searchMessages = 'Search messages';
  static const noPerMessageFee = 'Messages have no additional per-message fee.';
  static const expiredSourceCannotReopen =
      'The originating Story is unavailable. An expired room cannot be reopened.';
  static const ok = 'OK';
  static String roomCharge(String author) => 'Business room · $author';
  static String replyQuote(String author, String text) => '$author: $text';
  static String reportAction(String author) => 'Report $author';
  static String reportTarget(String author, String title) => '$author · $title';
  static String blockAction(bool blocked, String author) =>
      '${blocked ? 'Unblock' : 'Block'} $author';
  static String unavailableStory(String title) =>
      'The originating Story “$title” is unavailable, so this room cannot be reopened.';
  static String interactionLimit(String title) =>
      'The interaction limit for “$title” has been reached. This room cannot be reopened.';
  static String blockedExplanation(String author) =>
      '$author is blocked. Unblock this Business to contact them.';
  static String openRoomQuestion(bool reopening, String author) =>
      '${reopening ? 'Reopen' : 'Open'} $author message room?';
  static String roomTerms(int credits, int hours, String title) =>
      '$credits Credits opens a room for $hours hours, from “$title”. Messages during this time have no additional fee.';
  static String storyCategoryTitle(String category, String title) =>
      '$category · $title';
  static String expiresAt(DateTime time) =>
      'Expires ${time.toLocal().toString().substring(0, 16)}';
  static String roomPrice24Hours(int credits) =>
      '$credits Credits for 24 hours';
  static String callWith(bool video, String author) =>
      '${video ? 'Video' : 'Audio'} call with $author';
  static String callRate(int credits) =>
      '$credits Credits per started minute after answer. Ringing is free.';
  static String callBalance(int credits, int blocks) =>
      'Balance: $credits Credits · up to $blocks minutes';
  static String voiceNote(int seconds) =>
      'Voice note · ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String storyContext(String title, String author) =>
      'From “$title” · $author';
  static String viewExpiry(bool customer, bool active, DateTime expiry) =>
      '${customer ? 'Customer' : 'Recipient'} view · ${active ? 'Expires' : 'Expired'} ${expiry.toLocal().toString().substring(0, 16)}';
  static String contactBusiness(String author) => 'Contact $author';
  static String fromStory(String title) => 'From “$title”';
  static String roomOpeningPrice(int credits) => '$credits Credits · 24 hours';
  static String startedMinutePrice(int credits) =>
      '$credits Credits per started minute';
  static String profileCover(String name) => '$name public cover';
  static String profileLogo(String name) => '$name public logo';
}
