import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_photo.dart';
import '../../dialogs/discard_changes_dialog/discard_changes_dialog.dart';
import '../../widgets/group_photo_picker.dart';

enum GroupUpdateReviewState { normal, submitting, failed }

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({
    super.key,
    required this.controller,
    this.reviewState = GroupUpdateReviewState.normal,
  });
  final GroupController controller;
  final GroupUpdateReviewState reviewState;
  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name = TextEditingController(
    text: widget.controller.name,
  );
  late final TextEditingController description = TextEditingController(
    text: widget.controller.description,
  );
  bool allowPop = false;
  bool confirming = false;
  bool _firstSubmission = true;
  late GroupPhoto photo = widget.controller.photo;
  bool get dirty =>
      name.text != widget.controller.name ||
      description.text != widget.controller.description ||
      photo != widget.controller.photo;

  @override
  void initState() {
    super.initState();
    name.addListener(_changed);
    description.addListener(_changed);
    if (widget.reviewState != GroupUpdateReviewState.normal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _save();
      });
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _confirmDiscard() async {
    if (confirming) return;
    confirming = true;
    widget.controller.cancelUpdate();
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => const DiscardChangesDialog(
        description: GroupCopy.unsavedGroupDescription,
      ),
    );
    confirming = false;
    if (discard == true && mounted) _close();
  }

  void _close() {
    setState(() => allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    widget.controller.cancelUpdate();
    name.removeListener(_changed);
    description.removeListener(_changed);
    name.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final isReviewSubmission =
        _firstSubmission && widget.reviewState != GroupUpdateReviewState.normal;
    _firstSubmission = false;
    final saved = await widget.controller.submitIdentity(
      name.text,
      description.text,
      delay:
          isReviewSubmission &&
              widget.reviewState == GroupUpdateReviewState.submitting
          ? const Duration(seconds: 5)
          : const Duration(milliseconds: 400),
      simulateFailure:
          isReviewSubmission &&
          widget.reviewState == GroupUpdateReviewState.failed,
      photo: photo,
    );
    if (mounted && saved) _close();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: allowPop || !dirty,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && dirty) _confirmDiscard();
    },
    child: AppScaffold(
      appBar: AppHeader(title: const Text(GroupCopy.editGroup)),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: GroupPhotoPicker(
                  name: name.text,
                  photo: photo,
                  enabled:
                      widget.controller.canEdit &&
                      widget.controller.updateStatus !=
                          GroupUpdateStatus.submitting,
                  onChanged: (selection) => setState(() => photo = selection),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                readOnly:
                    !widget.controller.canEdit ||
                    widget.controller.updateStatus ==
                        GroupUpdateStatus.submitting,
                decoration: const InputDecoration(
                  labelText: GroupCopy.groupName,
                ),
                maxLength: 60,
                validator: (value) => value == null || value.trim().isEmpty
                    ? GroupCopy.enterAGroupName
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: description,
                readOnly:
                    !widget.controller.canEdit ||
                    widget.controller.updateStatus ==
                        GroupUpdateStatus.submitting,
                decoration: const InputDecoration(
                  labelText: GroupCopy.description,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (widget.controller.updateStatus == GroupUpdateStatus.failed)
                Text(
                  GroupCopy.groupUpdateFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (widget.controller.updateStatus ==
                  GroupUpdateStatus.submitting) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                const Center(child: Text(GroupCopy.updatingGroup)),
                TextButton(
                  onPressed: widget.controller.cancelUpdate,
                  child: const Text(GroupCopy.cancelUpdate),
                ),
              ] else
                ElevatedButton(
                  onPressed: widget.controller.canEdit ? _save : null,
                  child: Text(
                    widget.controller.updateStatus == GroupUpdateStatus.failed
                        ? CommonCopy.retry
                        : GroupCopy.saveChanges,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
