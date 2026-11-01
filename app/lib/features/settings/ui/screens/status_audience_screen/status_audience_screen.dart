import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../chats/models/chat_models.dart';
import '../../../../chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/settings_models.dart';

class StatusAudienceScreen extends StatefulWidget {
  const StatusAudienceScreen({super.key, required this.controller});
  final SettingsController controller;
  @override
  State<StatusAudienceScreen> createState() => _StatusAudienceScreenState();
}

class _StatusAudienceScreenState extends State<StatusAudienceScreen> {
  late StatusAudience audience = widget.controller.audience;
  late Set<String> ids = {...widget.controller.audienceContactIds};

  Future<void> _chooseContacts() async {
    final result = await Navigator.push<List<ChatConversation>>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipientPickerScreen(
          controller: widget.controller.chats,
          multiSelect: true,
          initialSelectedIds: ids,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(
      () => ids = result
          .where((contact) => !contact.blocked)
          .map((contact) => contact.id)
          .toSet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(title: const Text(SettingsCopy.statusAudience)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(SettingsCopy.chooseWhoCanSeeNewStatusUpdates),
                  RadioGroup<StatusAudience>(
                    groupValue: audience,
                    onChanged: (value) {
                      if (value != null) setState(() => audience = value);
                    },
                    child: Column(
                      children: [
                        const RadioListTile<StatusAudience>(
                          value: StatusAudience.contacts,
                          title: Text(SettingsCopy.myContacts),
                        ),
                        const RadioListTile<StatusAudience>(
                          value: StatusAudience.except,
                          title: Text(SettingsCopy.myContactsExcept),
                        ),
                        const RadioListTile<StatusAudience>(
                          value: StatusAudience.only,
                          title: Text(SettingsCopy.onlyShareWith),
                        ),
                      ],
                    ),
                  ),
                  if (audience != StatusAudience.contacts) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        audience == StatusAudience.except
                            ? SettingsCopy.excludeContacts
                            : SettingsCopy.selectContacts,
                      ),
                      subtitle: Text(SettingsCopy.selectedCount(ids.length)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _chooseContacts,
                    ),
                    if (ids.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(ids.clear),
                          child: const Text(SettingsCopy.clearSelection),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: audience == StatusAudience.only && ids.isEmpty
                      ? null
                      : () {
                          widget.controller.setAudience(audience, ids);
                          Navigator.pop(context);
                        },
                  child: const Text(CommonCopy.save),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
