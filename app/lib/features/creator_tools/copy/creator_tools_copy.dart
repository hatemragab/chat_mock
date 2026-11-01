/// English presentation copy for the session-only prototype.
abstract final class CreatorToolsCopy {
  static const contactActivity = 'Contact activity';
  static const contactActivityDescription =
      'Conversations and calls started from this Story appear here. Viewing statistics remain anonymous.';
  static const noContactActivityForThisStoryYet =
      'No contact activity for this Story yet.';
  static const businessMessageRoom = 'Business message room';

  static String publicationState(String category, String status) =>
      '$category · $status';
  static String roomActivity(bool active, int messages) =>
      '${active ? 'Active' : 'Expired'} · $messages messages';
  static String businessCall(String kind) => 'Business $kind call';
  static String callActivity(bool incoming, String phase) =>
      '${incoming ? 'Incoming' : 'Outgoing'} · $phase';
}
