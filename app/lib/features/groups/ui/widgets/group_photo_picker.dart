import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../../onboarding/ui/screens/profile_photo_capture_screen/profile_photo_capture_screen.dart';
import '../../../onboarding/ui/sheets/photo_source_sheet/photo_source_sheet.dart';
import '../../copy/groups_copy.dart';
import '../../models/group_photo.dart';
import '../sheets/group_photo_library_sheet/group_photo_library_sheet.dart';

/// Edits a draft using local samples and the existing simulated camera flow.
class GroupPhotoPicker extends StatelessWidget {
  const GroupPhotoPicker({
    super.key,
    required this.name,
    required this.photo,
    required this.onChanged,
    this.enabled = true,
  });

  final String name;
  final GroupPhoto photo;
  final ValueChanged<GroupPhoto> onChanged;
  final bool enabled;

  Future<void> _choose(BuildContext context) async {
    final source = await showModalBottomSheet<PhotoSourceAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PhotoSourceSheet(
        hasPhoto: photo != GroupPhoto.none,
        label: GroupCopy.groupPhoto,
      ),
    );
    if (!context.mounted || source == null) return;
    if (source == PhotoSourceAction.remove) {
      onChanged(GroupPhoto.none);
      return;
    }
    final GroupPhoto? selection;
    if (source == PhotoSourceAction.camera) {
      final captured = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePhotoCaptureScreen()),
      );
      selection = captured == null ? null : GroupPhoto.studio;
    } else {
      selection = await showModalBottomSheet<GroupPhoto>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => GroupPhotoLibrarySheet(selected: photo),
      );
    }
    if (context.mounted && selection != null) onChanged(selection);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AppAvatar(
        name: name,
        radius: 42,
        textStyle: const TextStyle(fontSize: 30),
        image: photo.assetPath == null ? null : AssetImage(photo.assetPath!),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: enabled ? () => _choose(context) : null,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                photo == GroupPhoto.none
                    ? GroupCopy.addGroupPhoto
                    : GroupCopy.changeGroupPhoto,
              ),
            ),
            if (photo != GroupPhoto.none) Text(GroupCopy.photoLabel(photo)),
          ],
        ),
      ),
    ],
  );
}
