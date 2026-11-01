import '../../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../controllers/settings_controller.dart';
import '../../../../models/settings_models.dart';

class ContactMatchingPanel extends StatelessWidget {
  const ContactMatchingPanel({
    super.key,
    required this.controller,
    required this.onReviewPermission,
  });
  final SettingsController controller;
  final VoidCallback onReviewPermission;

  @override
  Widget build(BuildContext context) {
    final allowed =
        controller.permissions['Contacts'] == MockPermission.allowed;
    final state = controller.contactMatchingState;
    final matches = controller.matchedContacts;
    final isMatching = state == ContactMatchingState.matching;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          SettingsCopy.contactMatching,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(SettingsCopy.matchingDescription),
        const SizedBox(height: 12),
        if (!allowed) ...[
          const Text(SettingsCopy.matchingPermissionUnavailable),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onReviewPermission,
            child: const Text(SettingsCopy.reviewContactsPermission),
          ),
        ] else if (isMatching) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text(SettingsCopy.findingMutualContacts),
          TextButton(
            onPressed: controller.cancelContactMatching,
            child: const Text(SettingsCopy.cancelMatching),
          ),
        ] else ...[
          if (state == ContactMatchingState.failed)
            Text(
              SettingsCopy.matchingFailureDescription,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else if (state == ContactMatchingState.empty ||
              (state == ContactMatchingState.matched && matches.isEmpty))
            const Text(SettingsCopy.noMatchingContactsYet)
          else if (state == ContactMatchingState.matched) ...[
            Text(SettingsCopy.mutualMatchCount(matches.length)),
            ...matches.map(
              (contact) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  child: Text(
                    contact.name.isEmpty ? '?' : contact.name.substring(0, 1),
                  ),
                ),
                title: Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ] else
            const Text(SettingsCopy.matchingHasNotBeenRunInThisSession),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: controller.startContactMatching,
            icon: const Icon(Icons.sync),
            label: Text(
              state == ContactMatchingState.failed
                  ? SettingsCopy.retryMatching
                  : state == ContactMatchingState.idle
                  ? SettingsCopy.findContacts
                  : SettingsCopy.matchAgain,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }
}
