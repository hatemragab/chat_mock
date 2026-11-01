import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_member.dart';

enum GroupMemberAction { remove, promote, demote, transfer }

class GroupMemberActionDialog extends StatelessWidget {
  const GroupMemberActionDialog({
    super.key,
    required this.member,
    required this.action,
  });
  final GroupMember member;
  final GroupMemberAction action;

  @override
  Widget build(BuildContext context) {
    final (title, description, button) = switch (action) {
      GroupMemberAction.remove => (
        GroupCopy.removeMemberTitle(member.name),
        GroupCopy.removeMemberDescription,
        CommonCopy.remove,
      ),
      GroupMemberAction.promote => (
        GroupCopy.promoteMemberTitle(member.name),
        GroupCopy.promoteMemberDescription,
        GroupCopy.promote,
      ),
      GroupMemberAction.demote => (
        GroupCopy.demoteMemberTitle(member.name),
        GroupCopy.demoteMemberDescription,
        GroupCopy.demote,
      ),
      GroupMemberAction.transfer => (
        GroupCopy.transferOwnershipTitle(member.name),
        GroupCopy.transferOwnershipDescription,
        GroupCopy.transfer,
      ),
    };
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(CommonCopy.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(button),
        ),
      ],
    );
  }
}
