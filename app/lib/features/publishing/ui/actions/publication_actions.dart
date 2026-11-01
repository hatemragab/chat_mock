import 'package:flutter/material.dart';

import '../../../creator_tools/ui/screens/promotion_contact_activity_screen/promotion_contact_activity_screen.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../controllers/publishing_controller.dart';
import '../../models/publication.dart';
import '../dialogs/delete_publication_dialog/delete_publication_dialog.dart';
import '../screens/analytics_screen/analytics_screen.dart';
import '../screens/publication_details_screen/publication_details_screen.dart';
import '../screens/publication_viewer_screen/publication_viewer_screen.dart';
import '../screens/story_viewers_screen/story_viewers_screen.dart';
import '../sheets/publication_actions_sheet/publication_actions_sheet.dart';

/// Runs the same contextual action from the list or a prototype review entry.
Future<void> showPublicationActions(
  BuildContext context, {
  required PublishingController controller,
  required Publication publication,
  SettingsController? settings,
}) async {
  final action = await showModalBottomSheet<PublicationAction>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PublicationActionsSheet(
      publication: publication,
      hasContactActivity: controller.contactActivity != null,
    ),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case PublicationAction.open:
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => PublicationViewerScreen(
            controller: controller,
            publication: publication,
            settings: settings,
          ),
        ),
      );
    case PublicationAction.details:
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => PublicationDetailsScreen(
            controller: controller,
            publication: publication,
          ),
        ),
      );
    case PublicationAction.viewers:
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => StoryViewersScreen(
            controller: controller,
            publication: publication,
          ),
        ),
      );
    case PublicationAction.analytics:
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AnalyticsScreen(controller: controller, publication: publication),
        ),
      );
    case PublicationAction.contactActivity:
      final activity = controller.contactActivity;
      if (activity != null) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => PromotionContactActivityScreen(
              controller: activity,
              publication: publication,
            ),
          ),
        );
      }
    case PublicationAction.delete:
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => DeletePublicationDialog(publication: publication),
      );
      if (confirmed == true && context.mounted) controller.remove(publication);
  }
}
