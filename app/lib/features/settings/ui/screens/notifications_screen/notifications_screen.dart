import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../notifications/models/demo_notification.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/settings_models.dart';
import '../permissions_screen/permissions_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.controller});
  final SettingsController controller;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationDelivery? lastDelivery;

  void _preview(NotificationKind kind) {
    final (sender, message) = switch (kind) {
      NotificationKind.message => (
        'Sarah Wilson',
        'Are we still meeting later?',
      ),
      NotificationKind.group => (
        'Design Team',
        'The new concepts are ready for review.',
      ),
      NotificationKind.call => ('Amira Hassan', SettingsCopy.incomingCall),
    };
    final result = widget.controller.notifications.receive(
      kind: kind,
      sender: sender,
      message: message,
    );
    setState(() => lastDelivery = result);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final center = controller.notifications;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, center]),
      builder: (context, _) => AppScaffold(
        appBar: AppHeader(title: const Text(SettingsCopy.notifications)),
        body: ListView(
          children: [
            ListTile(
              title: const Text(SettingsCopy.notificationPermission),
              subtitle: Text(
                controller.permissions['Notifications'] ==
                        MockPermission.allowed
                    ? SettingsCopy.allowedInThisDemo
                    : SettingsCopy.notAllowedInThisDemo,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PermissionsScreen(controller: controller),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text(SettingsCopy.messages),
              value: controller.messageNotifications,
              onChanged: controller.setMessageNotifications,
            ),
            SwitchListTile(
              title: const Text(SettingsCopy.groups),
              value: controller.groupNotifications,
              onChanged: controller.setGroupNotifications,
            ),
            SwitchListTile(
              title: const Text(SettingsCopy.calls),
              value: controller.callNotifications,
              onChanged: controller.setCallNotifications,
            ),
            SwitchListTile(
              title: const Text(SettingsCopy.showPreviews),
              value: controller.previews,
              onChanged: controller.setPreviews,
            ),
            SwitchListTile(
              title: const Text(SettingsCopy.vibration),
              value: controller.vibration,
              onChanged: controller.setVibration,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SettingsCopy.previewNotifications,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(SettingsCopy.notificationPreviewDescription),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final option in [
                        (NotificationKind.message, SettingsCopy.message),
                        (NotificationKind.group, SettingsCopy.group),
                        (NotificationKind.call, SettingsCopy.call),
                      ])
                        OutlinedButton(
                          onPressed: () => _preview(option.$1),
                          child: Text(option.$2),
                        ),
                    ],
                  ),
                  if (lastDelivery != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(switch (lastDelivery!) {
                        NotificationDelivery.delivered =>
                          SettingsCopy.previewAddedBelow,
                        NotificationDelivery.permissionDenied =>
                          SettingsCopy
                              .allowNotificationPermissionToShowThisPreview,
                        NotificationDelivery.preferenceDisabled =>
                          SettingsCopy.thisNotificationTypeIsTurnedOff,
                        NotificationDelivery.blocked =>
                          SettingsCopy.notificationsFromThisAccountAreBlocked,
                      }),
                    ),
                ],
              ),
            ),
            if (center.items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Text(SettingsCopy.noNotificationPreviewsYet),
              )
            else
              ...center.items.map(
                (item) => ListTile(
                  leading: Icon(switch (item.kind) {
                    NotificationKind.message => Icons.chat_bubble_outline,
                    NotificationKind.group => Icons.groups_outlined,
                    NotificationKind.call => Icons.call_outlined,
                  }),
                  title: Text(
                    item.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.body(showPreview: controller.previews),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => center.dismiss(item.id),
                    icon: const Icon(Icons.close),
                    tooltip: SettingsCopy.dismissNotification,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
