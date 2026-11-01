import 'package:flutter/material.dart';

import '../../../../stories/models/story.dart';
import '../../../copy/business_copy.dart';
import '../../../models/business_room.dart';

class BusinessRoomUnavailableDialog extends StatelessWidget {
  const BusinessRoomUnavailableDialog({
    super.key,
    required this.story,
    required this.reason,
  });
  final Story story;
  final OpenRoomResult reason;

  @override
  Widget build(BuildContext context) {
    final explanation = switch (reason) {
      OpenRoomResult.sourceUnavailable => BusinessCopy.unavailableStory(
        story.title,
      ),
      OpenRoomResult.limitReached => BusinessCopy.interactionLimit(story.title),
      OpenRoomResult.recipientCannotOpen => BusinessCopy.customerMustOpenRoom,
      OpenRoomResult.inProgress => BusinessCopy.roomOpeningInProgress,
      OpenRoomResult.blocked => BusinessCopy.blockedExplanation(story.author),
      _ => BusinessCopy.cannotOpenRoomNow,
    };
    return AlertDialog(
      title: Text(
        reason == OpenRoomResult.limitReached
            ? BusinessCopy.interactionLimitReached
            : BusinessCopy.roomUnavailable,
      ),
      content: Text(explanation),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(BusinessCopy.ok),
        ),
      ],
    );
  }
}
