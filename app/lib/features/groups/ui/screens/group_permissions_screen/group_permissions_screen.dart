import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/group_controller.dart';
import '../../../copy/groups_copy.dart';

class GroupPermissionsScreen extends StatelessWidget {
  const GroupPermissionsScreen({super.key, required this.controller});
  final GroupController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => AppScaffold(
      appBar: AppHeader(title: const Text(GroupCopy.groupPermissions)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            controller.isManager
                ? GroupCopy.permissionsDescription
                : GroupCopy.permissionsReadOnly,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SwitchListTile(
            title: const Text(GroupCopy.onlyAdminsCanSend),
            value: controller.onlyAdminsCanSend,
            onChanged: controller.isManager
                ? (value) => controller.setPermissions(send: value)
                : null,
          ),
          SwitchListTile(
            title: const Text(GroupCopy.onlyAdminsCanEditGroupDetails),
            value: controller.onlyAdminsCanEdit,
            onChanged: controller.isManager
                ? (value) => controller.setPermissions(edit: value)
                : null,
          ),
          SwitchListTile(
            title: const Text(GroupCopy.onlyAdminsCanManageMembers),
            value: controller.onlyAdminsCanManage,
            onChanged: controller.isManager
                ? (value) => controller.setPermissions(manage: value)
                : null,
          ),
        ],
      ),
    ),
  );
}
