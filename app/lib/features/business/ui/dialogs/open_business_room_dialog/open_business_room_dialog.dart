import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../stories/models/story.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';

class OpenBusinessRoomDialog extends StatelessWidget {
  const OpenBusinessRoomDialog({
    super.key,
    required this.controller,
    required this.story,
  });
  final BusinessController controller;
  final Story story;

  @override
  Widget build(BuildContext context) {
    final reopening = controller.roomFor(story.id) != null;
    final hours = controller.config.roomDuration.inHours;
    return AlertDialog(
      title: Text(BusinessCopy.openRoomQuestion(reopening, story.author)),
      content: Text(
        BusinessCopy.roomTerms(
          controller.config.roomCredits,
          hours,
          story.title,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(CommonCopy.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            reopening ? BusinessCopy.reopenRoom : BusinessCopy.openRoom,
          ),
        ),
      ],
    );
  }
}
