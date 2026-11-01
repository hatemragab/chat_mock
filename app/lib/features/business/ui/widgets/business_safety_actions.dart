import 'package:flutter/material.dart';

import '../../../safety/ui/dialogs/account_block_dialog/account_block_dialog.dart';
import '../../../safety/ui/screens/report_screen/report_screen.dart';
import '../../../stories/models/story.dart';
import '../../controllers/business_controller.dart';
import '../../copy/business_copy.dart';

/// Safety actions always keep the originating public Story identity.
class BusinessSafetyActions extends StatelessWidget {
  const BusinessSafetyActions({
    super.key,
    required this.controller,
    required this.story,
  });
  final BusinessController controller;
  final Story story;

  @override
  Widget build(BuildContext context) {
    final blocked = controller.isBlocked(story);
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.flag_outlined),
          title: Text(BusinessCopy.reportAction(story.author)),
          subtitle: const Text(BusinessCopy.reportBusinessAndStory),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ReportScreen(
                target: BusinessCopy.reportTarget(story.author, story.title),
                targetId: story.id,
              ),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(blocked ? Icons.person_add_alt : Icons.block),
          title: Text(BusinessCopy.blockAction(blocked, story.author)),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AccountBlockDialog(
                name: story.author,
                unblock: blocked,
                business: true,
              ),
            );
            if (confirmed == true) controller.setBlocked(story, !blocked);
          },
        ),
      ],
    );
  }
}
