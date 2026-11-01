/// English UI copy for the chats feature.
abstract final class ChatCopy {
  static String clearConversationTitle(String name) =>
      'Clear conversation with $name?';
  static String deleteConversationTitle(String name) =>
      'Delete conversation with $name?';
  static String deleteDeviceContactTitle(String name) =>
      'Delete $name from device contacts?';
  static String muteTitle(String name) => 'Mute $name';
  static String reactWith(String reaction) => 'React with $reaction';
  static String quote(String author, String text) => '$author: $text';
  static String continueWithCount(int count) => 'Continue ($count)';
  static String memberCount(int count) =>
      '$count ${count == 1 ? 'member' : 'members'}';
  static String readAt(String time) => 'Read at $time';
  static String deliveredAt(String time) => 'Delivered at $time';
  static String createdAt(String time) => 'Created at $time';
  static String reportContact(String name) => 'Report $name';
  static String fileType(String mimeType) => 'File type: $mimeType';
  static String fileSize(int bytes) {
    final String size;
    if (bytes >= 1024 * 1024) {
      size = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      size = '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      size = '$bytes bytes';
    }
    return 'File size: $size';
  }

  static String uploadProgress(int percent) => 'Uploading $percent%';
  static String recordingStatus({
    required bool stopped,
    required bool locked,
    required int seconds,
  }) =>
      '${stopped
          ? 'Voice note ready'
          : locked
          ? 'Recording locked'
          : 'Recording'} · ${duration(seconds)}';
  static String voiceNote(int seconds) =>
      'Voice note · ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String duration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String clockTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  static String calendarDate(DateTime date) =>
      '${date.day} ${abbreviatedMonths[date.month - 1]} ${date.year}';
  static String documentSamplePreview(String extension) =>
      '$extension document · Local sample preview';
  static String playbackPosition(String elapsed, String total) =>
      '$elapsed of $total';
  static String playbackProgress(String elapsed, String total) =>
      '$elapsed / $total';
  static const addContact = 'Add contact';
  static const alreadyAdded = 'Already added';
  static const always = 'Always';
  static const archive = 'Archive';
  static const archivedChats = 'Archived chats';
  static const attach = 'Attach';
  static const audio = 'Audio';
  static const audioCall = 'Audio call';
  static const block = 'Block';
  static const blocked = 'Blocked';
  static const business = 'Business';
  static const businessStoryConversation = 'Business · Story conversation';
  static const camera = 'Camera';
  static const cancelReplyOrEdit = 'Cancel reply or edit';
  static const cannotSendToThisConversation =
      'Cannot send to this conversation';
  static const chatOptions = 'Chat options';
  static const chats = 'Chats';
  static const chooseAReaction = 'Choose a reaction';
  static const chooseHowToRemoveThisMessage =
      'Choose how to remove this message.';
  static const clear = 'Clear';
  static const clearConversation = 'Clear conversation';
  static const clearConversationDescription =
      'Messages will be removed from this demo conversation.';
  static const contact = 'Contact';
  static const contactEditorDescription =
      'Changes are simulated in this session. Your device contacts will not be changed.';
  static const contactInfo = 'Contact info';
  static const contactSavedWaitingForMatch =
      'Contact saved. Waiting for a mutual match.';
  static const contactUpdated =
      'Contact updated for this demo. Device contacts were not changed.';
  static const contacts = 'Contacts';
  static const conversationInfo = 'Conversation info';
  static const copied = 'Copied';
  static const copy = 'Copy';
  static const copyLink = 'Copy link';
  static const deleteConversation = 'Delete conversation';
  static const deleteConversationDescription =
      'This removes the local chat history from this demo.';
  static const deleteDeviceContact = 'Delete device contact';
  static const deleteDeviceContactDescription =
      'This demo simulates opening device contacts. No contact is changed or deleted.';
  static const deleteForEveryone = 'Delete for everyone';
  static const deleteForMe = 'Delete for me';
  static const deleteGroupConversationDescription =
      'This removes the local chat history. You remain a group member.';
  static const deleteMessage = 'Delete message?';
  static const delivered = 'Delivered';
  static const deliveredTo = 'Delivered to';
  static const demoPhone = 'Demo phone';
  static const deviceContactsOpened =
      'Device contacts opened in simulation. No contact was changed.';
  static const document = 'Document';
  static const downloadSample = 'Download sample';
  static const duplicatePhone = 'This phone number is already in your contacts';
  static const editContact = 'Edit contact';
  static const editingMessage = 'Editing message';
  static const eightHours = '8 hours';
  static const emoji = 'Emoji';
  static const enterAName = 'Enter a name';
  static const enterAValidPhoneNumber = 'Enter a valid phone number';
  static const filePreview = 'File preview';
  static const failedToSend = 'Failed to send';
  static const files = 'Files';
  static const forward = 'Forward';
  static const groupInfo = 'Group info';
  static const groupNameRequired = 'A group name is required';
  static const groupReceiptsSenderOnly =
      'Only the sender can view group receipts.';
  static const groups = 'Groups';
  static const linkPreviewIsUnavailableOffline =
      'Link preview is unavailable offline.';
  static const links = 'Links';
  static const localSampleMedia = 'Local sample media';
  static const lockRecording = 'Lock recording';
  static const markRead = 'Mark read';
  static const markUnread = 'Mark unread';
  static const media = 'Media';
  static const mediaFilesAndLinks = 'Media, files and links';
  static const message = 'Message';
  static const messageDeleted = 'This message was deleted';
  static const messageInfo = 'Message info';
  static const messagingUnavailable =
      'Messaging is unavailable in this conversation.';
  static const moreOptions = 'More options';
  static const moreReactions = 'More reactions';
  static const mute = 'Mute';
  static const muteNotifications = 'Mute notifications';
  static const muteOptions = 'Mute options';
  static const name = 'Name';
  static const newChat = 'New chat';
  static const newGroup = 'New group';
  static const noArchivedChats = 'No archived chats';
  static const noChatsToShow = 'No chats to show';
  static const noContactsFound = 'No contacts found';
  static const noMatchingMessages = 'No matching messages';
  static const noMessagesYet = 'No messages yet';
  static const noOneAwaitingARead = 'No one awaiting a read';
  static const noOneYet = 'No one yet';
  static const noStarredMessages = 'No starred messages';
  static const notYetRead = 'Not yet read';
  static const nothingSharedHereYet = 'Nothing shared here yet';
  static const offlineQueueDescription = 'Offline — messages will be queued';
  static const oneWeek = '1 week';
  static const openContacts = 'Open contacts';
  static const openSample = 'Open sample';
  static const openedInSimulation = 'Opened in simulation';
  static const pause = 'Pause';
  static const paused = 'Paused';
  static const pending = 'Pending';
  static const pendingDelivery = 'Pending delivery';
  static const phoneHint = '+237 6XX XXX XXX';
  static const phoneNumber = 'Phone number';
  static const photoLibrary = 'Photo library';
  static const pin = 'Pin';
  static const play = 'Play';
  static const playingSample = 'Playing sample';
  static const previewAttachment = 'Preview attachment';
  static const read = 'Read';
  static const readBy = 'Read by';
  static const queued = 'Queued';
  static const recordVoiceNote = 'Record voice note';
  static const removeReaction = 'Remove reaction';
  static const reply = 'Reply';
  static const replyingTo = 'Replying to';
  static const sampleContactCard = 'Sample contact card';
  static const sampleContentForThisDemonstration =
      'Sample content for this demonstration';
  static const saveContact = 'Save contact';
  static const savedInDemo = 'Saved in demo';
  static const searchChats = 'Search chats';
  static const searchContacts = 'Search contacts';
  static const searchConversation = 'Search conversation';
  static const searchMessages = 'Search messages';
  static const searchYourConversations = 'Search your conversations';
  static const conversationResults = 'Conversations';
  static const messageResults = 'Messages';
  static const noMatchingConversationsOrMessages =
      'No matching conversations or messages';
  static const selectContact = 'Select contact';
  static const selectRecipients = 'Select recipients';
  static const sendAttachment = 'Send attachment';
  static const sendVoiceNote = 'Send voice note';
  static const sending = 'Sending';
  static const sent = 'Sent';
  static const shareASample = 'Share a sample';
  static const sharedLink = 'Shared link';
  static const showInChat = 'Show in chat';
  static const simulatedSelection = 'Simulated selection';
  static const star = 'Star';
  static const starredMessages = 'Starred messages';
  static const stopRecording = 'Stop recording';
  static const thisSampleCanBeOpenedInSimulation =
      'This sample can be opened in simulation.';
  static const today = 'Today';
  static const unarchive = 'Unarchive';
  static const unblock = 'Unblock';
  static const unmute = 'Unmute';
  static const unpin = 'Unpin';
  static const unread = 'Unread';
  static const unstar = 'Unstar';
  static const unsupportedFilePreview = 'Unsupported file preview';
  static const uploadFailedRetry = 'Upload failed · Retry';
  static const videoCall = 'Video call';
  static const videoLibrary = 'Video library';
  static const waitingForConnection = 'Waiting for connection';
  static const waitingForMutualContact = 'Waiting for a mutual contact match.';
  static const waitingForMutualMatch = 'Waiting for a mutual match';
  static const yesterday = 'Yesterday';
  static const abbreviatedMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
