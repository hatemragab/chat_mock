import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_person_row.dart';
import '../../copy/groups_copy.dart';
import '../../models/group_member.dart';

class GroupMemberRow extends StatelessWidget {
  const GroupMemberRow({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.onTap,
    this.contentPadding,
  });

  final GroupMember member;
  final bool isCurrentUser;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => AppPersonRow(
    name: member.name,
    subtitle: GroupCopy.roleLabel(member.role).toUpperCase(),
    contentPadding: contentPadding,
    trailing: isCurrentUser
        ? const Text(GroupCopy.you)
        : onTap == null
        ? null
        : const Icon(Icons.more_vert),
    onTap: isCurrentUser ? null : onTap,
  );
}
