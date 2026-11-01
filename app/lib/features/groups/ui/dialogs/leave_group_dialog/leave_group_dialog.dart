import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/groups_copy.dart';

enum LeaveGroupChoice { leave, chooseOwner }

class LeaveGroupDialog extends StatelessWidget {
  const LeaveGroupDialog({
    super.key,
    required this.groupName,
    required this.isOwner,
  });
  final String groupName;
  final bool isOwner;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      isOwner
          ? GroupCopy.transferOwnershipFirst
          : GroupCopy.leaveGroupTitle(groupName),
    ),
    content: Text(
      isOwner
          ? GroupCopy.ownerMustTransferDescription
          : GroupCopy.leaveGroupDescription,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(CommonCopy.cancel),
      ),
      TextButton(
        onPressed: () => Navigator.pop(
          context,
          isOwner ? LeaveGroupChoice.chooseOwner : LeaveGroupChoice.leave,
        ),
        child: Text(isOwner ? GroupCopy.chooseOwner : GroupCopy.leave),
      ),
    ],
  );
}
