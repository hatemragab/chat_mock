import 'package:flutter/material.dart';

import '../../../../stories/models/story.dart';
import '../../../../wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';
import '../../../models/business_room.dart';
import '../../dialogs/business_room_unavailable_dialog/business_room_unavailable_dialog.dart';
import '../../dialogs/open_business_room_dialog/open_business_room_dialog.dart';
import '../../screens/business_conversation_screen/business_conversation_screen.dart';
import '../../widgets/business_safety_actions.dart';
import '../business_call_preflight_sheet/business_call_preflight_sheet.dart';

class BusinessContactSheet extends StatelessWidget {
  const BusinessContactSheet({
    super.key,
    required this.controller,
    required this.story,
    this.onCall,
  });
  final BusinessController controller;
  final Story story;
  final BusinessCallCallback? onCall;

  Future<void> _openRoom(BuildContext context) async {
    var outcome = controller.openRoom(story);
    if (outcome == OpenRoomResult.confirmationRequired) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) =>
            OpenBusinessRoomDialog(controller: controller, story: story),
      );
      if (!context.mounted || confirm != true) return;
      outcome = controller.openRoom(story, confirmed: true);
    }
    if (!context.mounted) return;
    if (outcome == OpenRoomResult.insufficientCredits) {
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => InsufficientCreditsSheet(
          controller: controller.wallet,
          requiredCredits: controller.config.roomCredits,
        ),
      );
      return;
    }
    if (outcome == OpenRoomResult.opened ||
        outcome == OpenRoomResult.alreadyActive) {
      final navigator = Navigator.of(context);
      navigator.pop();
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BusinessConversationScreen(controller: controller, story: story),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) =>
          BusinessRoomUnavailableDialog(story: story, reason: outcome),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isBlocked(story)) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BusinessSafetyActions(controller: controller, story: story),
        ),
      );
    }
    final room = controller.roomFor(story.id);
    final active = room != null && controller.isActive(room);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BusinessCopy.contactBusiness(story.author),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(BusinessCopy.fromStory(story.title)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(
                active
                    ? BusinessCopy.continueMessageRoom
                    : BusinessCopy.messageRoom,
              ),
              subtitle: Text(
                active
                    ? BusinessCopy.activeRoomNoAdditionalCharge
                    : BusinessCopy.roomOpeningPrice(
                        controller.config.roomCredits,
                      ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openRoom(context),
            ),
            if (onCall != null) ...[
              for (final video in [false, true])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    video ? Icons.videocam_outlined : Icons.call_outlined,
                  ),
                  title: Text(
                    video ? BusinessCopy.videoCall : BusinessCopy.audioCall,
                  ),
                  subtitle: Text(
                    BusinessCopy.startedMinutePrice(
                      video
                          ? controller.config.videoBlockCredits
                          : controller.config.audioBlockCredits,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    showModalBottomSheet<void>(
                      context: navigator.context,
                      builder: (_) => BusinessCallPreflightSheet(
                        controller: controller,
                        story: story,
                        video: video,
                        onCall: onCall!,
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
