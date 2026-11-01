import 'package:flutter/material.dart';

import '../../publishing/controllers/publishing_controller.dart';
import '../../publishing/models/publication.dart';
import '../models/story.dart';
import '../models/publication_story.dart';

class StoriesController extends ChangeNotifier {
  StoriesController({this.publishing, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    publishing?.addListener(_publicationChanged);
  }
  final PublishingController? publishing;
  final DateTime Function() _clock;
  void _publicationChanged() => notifyListeners();
  static const stories = <Story>[
    Story(
      id: 'maison',
      author: 'Maison Studio',
      title: 'Spaces that feel like home',
      category: 'Design',
      kind: StoryKind.business,
      media: StoryMedia.photo,
      colors: [Color(0xFFBCA18A), Color(0xFF6C584C)],
      boosted: true,
      assetPath: 'assets/story/maison_studio.png',
    ),
    Story(
      id: 'brew',
      author: 'Daily Brew',
      title: 'A little moment for you',
      category: 'Food & drink',
      kind: StoryKind.business,
      media: StoryMedia.video,
      colors: [Color(0xFFB7835E), Color(0xFF54372B)],
      sponsored: true,
      assetPath: 'assets/story/daily_brew.png',
    ),
    Story(
      id: 'local',
      author: 'Made Local',
      title: 'Made with care, close to home',
      category: 'Shopping',
      kind: StoryKind.business,
      media: StoryMedia.photo,
      colors: [Color(0xFFD4A775), Color(0xFF765543)],
      popular: true,
    ),
    Story(
      id: 'green',
      author: 'Green Corner',
      title: 'Bring a little green inside',
      category: 'Lifestyle',
      kind: StoryKind.business,
      media: StoryMedia.photo,
      colors: [Color(0xFF7A9C70), Color(0xFF365B45)],
      boosted: true,
      assetPath: 'assets/story/green_corner.png',
    ),
    Story(
      id: 'sarah',
      author: 'Sarah Wilson',
      title: 'A lovely afternoon',
      category: 'Friends',
      kind: StoryKind.contact,
      media: StoryMedia.photo,
      colors: [Color(0xFFCD9F8A), Color(0xFF805762)],
    ),
    Story(
      id: 'amira',
      author: 'Amira Hassan',
      title: 'Weekend notes',
      category: 'Friends',
      kind: StoryKind.contact,
      media: StoryMedia.video,
      colors: [Color(0xFF8EA6A0), Color(0xFF516A66)],
    ),
    Story(
      id: 'alex',
      author: 'Alex Morgan',
      title: 'My Status',
      category: 'Friends',
      kind: StoryKind.own,
      media: StoryMedia.photo,
      colors: [Color(0xFF86B6AA), Color(0xFF416C66)],
    ),
  ];
  final Map<String, StoryAvailability> _availability = {};
  final Set<String> _failedMedia = {};

  List<Story> get allStories => [
    ...stories.where(
      (story) =>
          availability(story.id) == StoryAvailability.active &&
          !(publishing?.seedPublications == true &&
              story.kind == StoryKind.own),
    ),
    ...?publishing?.publications
        .where(
          (publication) =>
              publication.status == PublicationStatus.active &&
              publication.expiresAt.isAfter(_clock()) &&
              availability(publication.id) == StoryAvailability.active,
        )
        .map(
          (publication) => storyForPublication(
            publication,
            author: publishing!.currentAuthorName,
            popular:
                (publication.boosted ||
                    publication.type == PublicationType.advertisement) &&
                publishing!.config.popularThreshold > 0 &&
                publication.qualifiedViews >=
                    publishing!.config.popularThreshold,
          ),
        ),
  ];
  final Set<String> _seen = {};

  StoryAvailability availability(String id) {
    final override = _availability[id];
    if (override != null) return override;
    final matches = publishing?.publications.where((item) => item.id == id);
    if (matches == null || matches.isEmpty) return StoryAvailability.active;
    final publication = matches.first;
    if (publication.status == PublicationStatus.removed) {
      return StoryAvailability.removed;
    }
    if (publication.status == PublicationStatus.expired ||
        !publication.expiresAt.isAfter(_clock())) {
      return StoryAvailability.expired;
    }
    return StoryAvailability.active;
  }

  bool mediaFailed(String id) => _failedMedia.contains(id);

  void setAvailability(String id, StoryAvailability value) {
    if (value == StoryAvailability.active) {
      _availability.remove(id);
    } else {
      _availability[id] = value;
    }
    notifyListeners();
  }

  void setMediaFailed(String id, bool failed) {
    if (failed) {
      _failedMedia.add(id);
    } else {
      _failedMedia.remove(id);
    }
    notifyListeners();
  }

  bool isSeen(String id) => _seen.contains(id);
  void markSeen(String id) {
    if (_seen.add(id)) notifyListeners();
  }

  void reset() {
    _seen.clear();
    _availability.clear();
    _failedMedia.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    publishing?.removeListener(_publicationChanged);
    super.dispose();
  }
}
