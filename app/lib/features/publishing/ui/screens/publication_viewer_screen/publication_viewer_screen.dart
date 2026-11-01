import 'package:flutter/material.dart';

import '../../../../stories/controllers/stories_controller.dart';
import '../../../../stories/models/publication_story.dart';
import '../../../../stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';

/// Owns a projection of the shared publication while this viewer is open.
class PublicationViewerScreen extends StatefulWidget {
  const PublicationViewerScreen({
    super.key,
    required this.controller,
    required this.publication,
    this.settings,
  });
  final PublishingController controller;
  final Publication publication;
  final SettingsController? settings;

  @override
  State<PublicationViewerScreen> createState() =>
      _PublicationViewerScreenState();
}

class _PublicationViewerScreenState extends State<PublicationViewerScreen> {
  late final StoriesController stories = StoriesController(
    publishing: widget.controller,
    clock: () => widget.controller.now,
  );

  @override
  void dispose() {
    stories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publication = widget.publication;
    final story = storyForPublication(
      publication,
      author: widget.controller.currentAuthorName,
    );
    return StoryViewerScreen(
      controller: stories,
      story: story,
      settings: widget.settings,
    );
  }
}
