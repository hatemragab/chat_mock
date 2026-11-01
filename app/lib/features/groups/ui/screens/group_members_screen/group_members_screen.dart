import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../../sheets/group_member_actions_sheet/group_member_actions_sheet.dart';
import '../../widgets/group_member_row.dart';
import '../add_group_members_screen/add_group_members_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  const GroupMembersScreen({
    super.key,
    required this.controller,
    this.transferMode = false,
    this.initialQuery = '',
  });
  final GroupController controller;
  final bool transferMode;
  final String initialQuery;
  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  late String query = widget.initialQuery;
  late final TextEditingController queryController = TextEditingController(
    text: query,
  );

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final members = widget.controller.activeMembers
          .where(
            (member) =>
                member.name.toLowerCase().contains(query.toLowerCase()) &&
                (!widget.transferMode ||
                    member.id != widget.controller.perspectiveId),
          )
          .toList();
      return AppScaffold(
        appBar: AppHeader(
          title: Text(
            widget.transferMode
                ? GroupCopy.chooseNewOwner
                : GroupCopy.groupMembers,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppSearchField(
              controller: queryController,
              hintText: GroupCopy.searchMembers,
              onChanged: (value) => setState(() => query = value),
            ),
            if (widget.controller.canManage && !widget.transferMode)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_add_alt)),
                title: const Text(GroupCopy.addMembers),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AddGroupMembersScreen(controller: widget.controller),
                  ),
                ),
              ),
            if (members.isEmpty)
              const AppStateView(title: GroupCopy.noMembersMatchYourSearch),
            ...members.map(
              (member) => GroupMemberRow(
                member: member,
                isCurrentUser: member.id == widget.controller.perspectiveId,
                onTap: member.id == widget.controller.perspectiveId
                    ? null
                    : () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => GroupMemberActionsSheet(
                          controller: widget.controller,
                          member: member,
                          transferMode: widget.transferMode,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
