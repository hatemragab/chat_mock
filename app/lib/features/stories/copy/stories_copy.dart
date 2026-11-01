/// English presentation copy for the session-only prototype.
abstract final class StoriesCopy {
  static const storyOptions = 'Story options';
  static const viewBusinessProfile = 'View Business profile';
  static const reportStory = 'Report Story';
  static const publicationDetails = 'Publication details';
  static const promotionAnalytics = 'Promotion analytics';
  static const storyViewers = 'Story viewers';
  static const deletePublication = 'Delete publication';
  static const myPublications = 'My Publications';
  static const status = 'Status';
  static const yourStatus = 'Your status';
  static const noOwnStatus =
      'No active Status yet. Share a moment with your contacts.';
  static const createStatus = 'Create Status';
  static const recentUpdates = 'Recent updates';
  static const noContactStories =
      'No updates yet. Your contacts’ stories will appear here.';
  static const seenUpdates = 'Seen updates';
  static const exploreDiscover = 'Explore Discover';
  static const discoverPreview = 'Discover preview';
  static const noPromotedStories =
      'No promoted Stories are available right now.';
  static const today = 'Today';
  static const unmute = 'Unmute';
  static const mute = 'Mute';
  static const play = 'Play';
  static const pause = 'Pause';
  static const previousStory = 'Previous Story';
  static const thisStoryIsUnavailable = 'This Story is unavailable.';
  static const thisStoryHasExpired = 'This Story has expired.';
  static const thisStoryHasBeenRemoved = 'This Story has been removed.';
  static const storyMediaCouldNotBeLoaded = 'Story media could not be loaded.';
  static const audioPreview = 'Audio preview';
  static const videoPreview = 'Video preview';
  static const paused = 'Paused';
  static const nextStory = 'Next Story';
  static const viewBusiness = 'View Business';
  static const sponsored = 'Sponsored';
  static const popular = 'Popular';
  static const boosted = 'Boosted';

  static String identityTitle(String author, String title) =>
      '$author · $title';
  static String blockAction(bool blocked, String author) =>
      '${blocked ? 'Unblock' : 'Block'} $author';
  static String mediaEdits(String? cover, int start, int end) =>
      'Cover: $cover · Trim $start–$end%';
  static String coverSemantics(String author, String title, bool? seen) =>
      '$author, $title${seen == null
          ? ''
          : seen
          ? ', seen update'
          : ', new update'}';
}
