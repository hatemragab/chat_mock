import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_selectable_person_row.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_member.dart';

class AddGroupMembersScreen extends StatefulWidget {
  const AddGroupMembersScreen({super.key, required this.controller});
  final GroupController controller;
  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final selected = <String>{};
  String query = '';
  @override
  Widget build(BuildContext context) {
    final candidates = widget.controller.chats.conversations
        .where(widget.controller.chats.canCommunicateWithContact)
        .map((chat) => GroupMember(id: chat.id, name: chat.name))
        .toList();
    final visible = candidates
        .where(
          (member) => member.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(GroupCopy.addMembers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hintText: GroupCopy.searchContacts,
              query: query,
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          if (selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  children: candidates
                      .where((candidate) => selected.contains(candidate.id))
                      .map(
                        (candidate) => InputChip(
                          label: Text(candidate.name),
                          onDeleted: () =>
                              setState(() => selected.remove(candidate.id)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Expanded(
            child: visible.isEmpty
                ? const AppStateView(title: GroupCopy.noMatchingContacts)
                : ListView(
                    children: visible.map((candidate) {
                      final existing = widget.controller.activeMembers.any(
                        (member) => member.id == candidate.id,
                      );
                      return AppSelectablePersonRow(
                        name: candidate.name,
                        selected: existing || selected.contains(candidate.id),
                        onChanged: existing
                            ? null
                            : (value) => setState(() {
                                if (value == true) {
                                  selected.add(candidate.id);
                                } else {
                                  selected.remove(candidate.id);
                                }
                              }),
                        subtitle: existing ? GroupCopy.alreadyAMember : null,
                      );
                    }).toList(),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          widget.controller.addMembers(
                            candidates.where(
                              (member) => selected.contains(member.id),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  child: Text(GroupCopy.addMemberCount(selected.length)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
