import 'dart:async';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/stories_copy.dart';

import 'package:flutter/material.dart';

import '../../../../business/controllers/business_controller.dart';
import '../../../../chats/controllers/chats_controller.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../publishing/models/publication.dart';
import '../../../../publishing/ui/dialogs/delete_publication_dialog/delete_publication_dialog.dart';
import '../../../../publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import '../../../../publishing/ui/screens/publications_screen/publications_screen.dart';
import '../../../../publishing/ui/screens/story_viewers_screen/story_viewers_screen.dart';
import '../../../../safety/ui/dialogs/account_block_dialog/account_block_dialog.dart';
import '../../../../safety/ui/screens/report_screen/report_screen.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../controllers/stories_controller.dart';
import '../../../models/story.dart';
import '../../sheets/story_options_sheet/story_options_sheet.dart';
import '../../widgets/story_media_background.dart';
import '../../widgets/story_progress_segments.dart';
import '../../widgets/story_viewer_header.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.controller,
    required this.story,
    this.storyQueue,
    this.onBusinessProfile,
    this.initiallyPaused = false,
    this.initiallyMuted = false,
    this.initiallyShowOptions = false,
    this.businessController,
    this.chatsController,
    this.settings,
  });
  final StoriesController controller;
  final Story story;

  /// The ordered stories from the surface that opened this viewer.
  final List<Story>? storyQueue;
  final ValueChanged<Story>? onBusinessProfile;
  final bool initiallyPaused;
  final bool initiallyMuted;
  final bool initiallyShowOptions;
  final BusinessController? businessController;
  final ChatsController? chatsController;
  final SettingsController? settings;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final List<Story> stories;
  late int index;
  double progress = 0;
  bool paused = false;
  bool pausedBeforeLongPress = false;
  bool muted = false;
  Timer? timer;
  Story get story {
    final current = stories[index];
    final contact = _contactFor(current);
    return contact == null ? current : current.withAuthor(contact.name);
  }

  bool _isBlocked(Story item) {
    if (item.kind == StoryKind.business) {
      return widget.businessController?.isBlocked(item) ?? false;
    }
    if (item.kind == StoryKind.contact && widget.chatsController != null) {
      final contact = _contactFor(item);
      return contact == null ||
          !widget.chatsController!.canCommunicateWithContact(contact);
    }
    return false;
  }

  void _markCurrentSeenAfterFrame() {
    final id = story.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || story.id != id || _isBlocked(story)) return;
      if (widget.controller.availability(id) == StoryAvailability.active) {
        widget.controller.markSeen(id);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    paused = widget.initiallyPaused;
    muted = widget.initiallyMuted;
    stories =
        (widget.storyQueue ??
                widget.controller.allStories.where(
                  (item) => item.kind == widget.story.kind,
                ))
            .where((item) => !_isBlocked(item))
            .toList();
    index = stories.indexWhere((item) => item.id == widget.story.id);
    if (index < 0) {
      stories.add(widget.story);
      index = stories.length - 1;
    }
    widget.controller.addListener(_storyChanged);
    widget.chatsController?.addListener(_storyChanged);
    widget.businessController?.addListener(_storyChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_isBlocked(story) &&
          widget.controller.availability(story.id) ==
              StoryAvailability.active) {
        widget.controller.markSeen(story.id);
      }
      if (widget.initiallyShowOptions) unawaited(_openOptions());
    });
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted ||
          paused ||
          _isBlocked(story) ||
          widget.controller.mediaFailed(story.id) ||
          widget.controller.availability(story.id) !=
              StoryAvailability.active) {
        return;
      }
      if (progress >= 1) {
        _next();
      } else {
        final fraction = story.media == StoryMedia.photo
            ? 1.0
            : (story.trimEnd - story.trimStart).clamp(.05, 1.0);
        setState(() => progress = (progress + .0125 / fraction).clamp(0, 1));
      }
    });
  }

  void _storyChanged() {
    if (!mounted) return;
    setState(() {});
    if (!widget.controller.isSeen(story.id) && !_isBlocked(story)) {
      _markCurrentSeenAfterFrame();
    }
  }

  @override
  void didUpdateWidget(covariant StoryViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatsController != widget.chatsController) {
      oldWidget.chatsController?.removeListener(_storyChanged);
      widget.chatsController?.addListener(_storyChanged);
    }
    if (oldWidget.businessController != widget.businessController) {
      oldWidget.businessController?.removeListener(_storyChanged);
      widget.businessController?.addListener(_storyChanged);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_storyChanged);
      widget.controller.addListener(_storyChanged);
    }
  }

  void _next() {
    var next = index + 1;
    while (next < stories.length &&
        (_isBlocked(stories[next]) ||
            widget.controller.availability(stories[next].id) !=
                StoryAvailability.active)) {
      next++;
    }
    if (next >= stories.length) {
      Navigator.maybePop(context);
      return;
    }
    setState(() {
      index = next;
      progress = 0;
    });
    if (!_isBlocked(story) &&
        widget.controller.availability(story.id) == StoryAvailability.active) {
      widget.controller.markSeen(story.id);
    }
  }

  void _previous() {
    var previous = index - 1;
    while (previous >= 0 &&
        (_isBlocked(stories[previous]) ||
            widget.controller.availability(stories[previous].id) !=
                StoryAvailability.active)) {
      previous--;
    }
    setState(() {
      if (previous >= 0) index = previous;
      progress = 0;
    });
    if (!_isBlocked(story) &&
        widget.controller.availability(story.id) == StoryAvailability.active) {
      widget.controller.markSeen(story.id);
    }
  }

  ChatConversation? _contactFor(Story current) {
    if (current.kind != StoryKind.contact) return null;
    return widget.chatsController?.conversations
        .where((chat) => chat.id == current.id && chat.kind == ChatKind.contact)
        .firstOrNull;
  }

  Publication? _publicationFor(Story current) => widget
      .controller
      .publishing
      ?.publications
      .where((publication) => publication.id == current.id)
      .firstOrNull;

  Future<void> _openOptions() async {
    final current = story;
    final previousPaused = paused;
    final business = widget.businessController;
    final contact = _contactFor(current);
    final publisher = widget.controller.publishing;
    final publication = _publicationFor(current);
    final blocked = current.kind == StoryKind.business
        ? business?.isBlocked(current) ?? false
        : contact?.blocked ?? false;
    setState(() => paused = true);
    final action = await showModalBottomSheet<StoryOption>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => StoryOptionsSheet(
        story: current,
        canOpenProfile: widget.onBusinessProfile != null && !blocked,
        canBlock: current.kind == StoryKind.business
            ? business != null
            : contact != null,
        blocked: blocked,
        hasPublication: publication != null,
        hasPublishing: publisher != null,
        canDeletePublication: publication?.status == PublicationStatus.active,
      ),
    );
    if (!mounted) return;
    switch (action) {
      case StoryOption.publicProfile:
        widget.onBusinessProfile?.call(current);
        // The callback owns the route. Keep playback paused until the user resumes it.
        return;
      case StoryOption.report:
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ReportScreen(
              target: StoriesCopy.identityTitle(current.author, current.title),
              targetId: current.id,
            ),
          ),
        );
      case StoryOption.block:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AccountBlockDialog(
            name: current.author,
            unblock: blocked,
            business: current.kind == StoryKind.business,
          ),
        );
        if (!mounted) return;
        if (confirmed == true) {
          if (current.kind == StoryKind.business) {
            if (business?.isBlocked(current) == blocked) {
              business?.setBlocked(current, !blocked);
            }
          } else if (contact != null && contact.blocked == blocked) {
            widget.chatsController?.toggleBlocked(contact);
          }
        }
      case StoryOption.publicationDetails:
        if (publisher != null && publication != null) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PublicationDetailsScreen(
                controller: publisher,
                publication: publication,
              ),
            ),
          );
        }
      case StoryOption.viewers:
        if (publisher != null && publication != null) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => StoryViewersScreen(
                controller: publisher,
                publication: publication,
              ),
            ),
          );
        }
      case StoryOption.deletePublication:
        if (publisher != null &&
            publication != null &&
            publication.status == PublicationStatus.active) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => DeletePublicationDialog(publication: publication),
          );
          if (!mounted) return;
          if (confirmed == true) publisher.remove(publication);
        }
      case StoryOption.myPublications:
        if (publisher != null) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PublicationsScreen(
                controller: publisher,
                settings: widget.settings,
              ),
            ),
          );
        }
      case null:
        break;
    }
    if (mounted) setState(() => paused = previousPaused);
  }

  @override
  void dispose() {
    timer?.cancel();
    widget.controller.removeListener(_storyChanged);
    widget.chatsController?.removeListener(_storyChanged);
    widget.businessController?.removeListener(_storyChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = story;
    final availability = widget.controller.availability(current.id);
    final blocked = _isBlocked(current);
    final failed = widget.controller.mediaFailed(current.id);
    return AppScaffold(
      safeArea: false,
      backgroundColor: current.colors.last,
      body: SafeArea(
        child: GestureDetector(
          onLongPressStart: (_) => setState(() {
            pausedBeforeLongPress = paused;
            paused = true;
          }),
          onLongPressEnd: (_) => setState(() => paused = pausedBeforeLongPress),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: current.colors,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (current.assetPath != null &&
                    !blocked &&
                    !failed &&
                    availability == StoryAvailability.active)
                  StoryMediaBackground(story: current, dim: .45),
                Column(
                  children: [
                    StoryProgressSegments(
                      count: stories.length,
                      index: index,
                      progress: progress,
                    ),
                    StoryViewerHeader(
                      author: current.author,
                      media: current.media,
                      blocked: blocked,
                      paused: paused,
                      muted: muted,
                      onBack: () => Navigator.pop(context),
                      onToggleMuted: () => setState(() => muted = !muted),
                      onTogglePaused: () => setState(() => paused = !paused),
                      onOptions:
                          current.kind != StoryKind.own ||
                              widget.controller.publishing != null
                          ? _openOptions
                          : null,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _previous,
                            tooltip: StoriesCopy.previousStory,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white70,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (blocked) ...[
                                      const Icon(
                                        Icons.block,
                                        color: Colors.white70,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        StoriesCopy.thisStoryIsUnavailable,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ] else if (availability !=
                                        StoryAvailability.active) ...[
                                      const Icon(
                                        Icons.history_toggle_off,
                                        color: Colors.white70,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        availability ==
                                                StoryAvailability.expired
                                            ? StoriesCopy.thisStoryHasExpired
                                            : StoriesCopy
                                                  .thisStoryHasBeenRemoved,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ] else if (failed) ...[
                                      const Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white70,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        StoriesCopy.storyMediaCouldNotBeLoaded,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => widget.controller
                                            .setMediaFailed(current.id, false),
                                        child: const Text(CommonCopy.retry),
                                      ),
                                    ] else ...[
                                      Icon(
                                        current.media == StoryMedia.audio
                                            ? Icons.graphic_eq_rounded
                                            : current.media == StoryMedia.video
                                            ? Icons.play_circle_outline_rounded
                                            : Icons.auto_awesome_rounded,
                                        color: Colors.white70,
                                        size: 72,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        current.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (current.media != StoryMedia.photo)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            current.media == StoryMedia.audio
                                                ? StoriesCopy.audioPreview
                                                : StoriesCopy.videoPreview,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      if (current.media != StoryMedia.photo &&
                                          current.coverLabel != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            StoriesCopy.mediaEdits(
                                              current.coverLabel,
                                              (current.trimStart * 100).round(),
                                              (current.trimEnd * 100).round(),
                                            ),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                    if (paused && !blocked)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Text(
                                          StoriesCopy.paused,
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _next,
                            tooltip: StoriesCopy.nextStory,
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!blocked &&
                        availability == StoryAvailability.active &&
                        current.kind == StoryKind.business &&
                        widget.onBusinessProfile != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() => paused = true);
                            widget.onBusinessProfile!(current);
                          },
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text(StoriesCopy.viewBusiness),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
