/// English presentation copy for the session-only prototype.
abstract final class DiscoverCopy {
  static const searchDiscover = 'Search Discover';
  static const searchStoriesAndBusinesses = 'Search stories and businesses';
  static const noSearchResults =
      'No stories match your search. Try another category.';
  static const discover = 'Discover';
  static const aLittleInspirationEveryDay = 'A little inspiration, every day';
  static const exploreStories = 'Explore stories';
  static const forYou = 'FOR YOU';
  static const noPromotedStories =
      'No promoted Stories are available right now.';
  static const browseByCategory = 'Browse by category';
  static const popularNearYou = 'Popular near you';
  static const offlineShowingAvailableStories =
      'Offline · Showing available Stories';
  static const reconnecting = 'Reconnecting…';
  static const couldNotLoadStories = 'Could not load Stories';
  static const retryDescription =
      'Please try again. Your search and filters are saved.';
  static const loadingStories = 'Loading stories';
  static const loadingStoriesStatus = 'Loading stories…';
  static String categoryLabel(String category) => switch (category) {
    'Design' => 'Design',
    'Food & drink' => 'Food & drink',
    'Shopping' => 'Shopping',
    'Lifestyle' => 'Lifestyle',
    _ => category,
  };
}
