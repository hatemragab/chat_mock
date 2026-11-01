import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../copy/groups_copy.dart';
import '../../../models/group_photo.dart';

class GroupPhotoLibrarySheet extends StatelessWidget {
  const GroupPhotoLibrarySheet({super.key, required this.selected});

  final GroupPhoto selected;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              GroupCopy.chooseGroupPhoto,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final photo in GroupPhoto.values.where(
            (photo) => photo != GroupPhoto.none,
          ))
            ListTile(
              leading: AppAvatar(
                name: GroupCopy.photoLabel(photo),
                image: AssetImage(photo.assetPath!),
              ),
              title: Text(GroupCopy.photoLabel(photo)),
              trailing: selected == photo ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, photo),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
