import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import '../../../controllers/group_controller.dart';
import '../../../controllers/group_directory.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_photo.dart';
import '../../dialogs/discard_changes_dialog/discard_changes_dialog.dart';
import '../../widgets/group_photo_picker.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
    required this.directory,
    this.simulateFirstFailure = false,
    this.submissionDelay = const Duration(milliseconds: 400),
  });
  final GroupDirectory directory;
  final bool simulateFirstFailure;
  final Duration submissionDelay;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final name = TextEditingController();
  final description = TextEditingController();
  List<ChatConversation> selected = [];
  GroupPhoto photo = GroupPhoto.none;
  bool _firstSubmission = true;
  bool submitted = false;
  bool allowPop = false;
  bool confirming = false;
  bool get dirty =>
      name.text.isNotEmpty ||
      description.text.isNotEmpty ||
      selected.isNotEmpty ||
      photo != GroupPhoto.none;

  @override
  void initState() {
    super.initState();
    name.addListener(_changed);
    description.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _confirmDiscard() async {
    if (confirming) return;
    confirming = true;
    widget.directory.cancelCreation();
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => const DiscardChangesDialog(
        description: GroupCopy.unsavedNewGroupDescription,
      ),
    );
    confirming = false;
    if (discard == true && mounted) _close();
  }

  void _close([GroupController? result]) {
    setState(() => allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop<GroupController>(context, result);
    });
  }

  @override
  void dispose() {
    widget.directory.cancelCreation();
    name.removeListener(_changed);
    description.removeListener(_changed);
    name.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pickMembers() async {
    final result = await Navigator.push<List<ChatConversation>>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipientPickerScreen(
          controller: widget.directory.chats,
          multiSelect: true,
          initialSelectedIds: selected.map((contact) => contact.id).toSet(),
        ),
      ),
    );
    if (result != null && mounted) setState(() => selected = result);
  }

  Future<void> create() async {
    setState(() => submitted = true);
    if (name.text.trim().isEmpty || selected.isEmpty) return;
    final simulateFailure = _firstSubmission && widget.simulateFirstFailure;
    _firstSubmission = false;
    final group = await widget.directory.submitCreate(
      name: name.text,
      description: description.text,
      members: selected,
      photo: photo,
      simulateFailure: simulateFailure,
      delay: widget.submissionDelay,
    );
    if (mounted && group != null) _close(group);
  }

  @override
  Widget build(BuildContext context) => PopScope<GroupController>(
    canPop: allowPop || !dirty,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && dirty) _confirmDiscard();
    },
    child: AppScaffold(
      appBar: AppHeader(title: const Text(GroupCopy.newGroup)),
      body: ListenableBuilder(
        listenable: widget.directory,
        builder: (context, _) {
          final submitting =
              widget.directory.creationStatus == GroupCreationStatus.submitting;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GroupPhotoPicker(
                name: name.text,
                photo: photo,
                enabled: !submitting,
                onChanged: (selection) => setState(() => photo = selection),
              ),
              const SizedBox(height: 16),
              Text(
                GroupCopy.groupDetails,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                readOnly: submitting,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: GroupCopy.groupName,
                  errorText: submitted && name.text.trim().isEmpty
                      ? GroupCopy.enterAGroupName
                      : null,
                ),
                onChanged: (_) {
                  if (submitted) setState(() {});
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                readOnly: submitting,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: GroupCopy.descriptionOptional,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_add_alt),
                title: const Text(GroupCopy.selectMembers),
                subtitle: Text(
                  selected.isEmpty
                      ? GroupCopy.chooseAtLeastOneContact
                      : GroupCopy.selectedCount(selected.length),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: submitting ? null : pickMembers,
              ),
              if (selected.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: selected
                      .map(
                        (contact) => InputChip(
                          label: Text(contact.name),
                          onDeleted: submitting
                              ? null
                              : () => setState(() => selected.remove(contact)),
                        ),
                      )
                      .toList(),
                ),
              if (submitted && selected.isEmpty)
                Text(
                  GroupCopy.chooseAtLeastOneContactError,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 24),
              if (widget.directory.creationStatus == GroupCreationStatus.failed)
                Text(
                  GroupCopy.groupCreationFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (submitting) ...[
                const Center(child: CircularProgressIndicator()),
                const Center(child: Text(GroupCopy.creatingGroup)),
                TextButton(
                  onPressed: widget.directory.cancelCreation,
                  child: const Text(GroupCopy.cancelCreation),
                ),
              ] else
                FilledButton(
                  onPressed: create,
                  child: Text(
                    widget.directory.creationStatus ==
                            GroupCreationStatus.failed
                        ? CommonCopy.retry
                        : GroupCopy.createGroup,
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
