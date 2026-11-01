import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_person_row.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_selectable_person_row.dart';
import '../../../../../shared/widgets/app_state_view.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';
import '../edit_contact_screen/edit_contact_screen.dart';

class RecipientPickerScreen extends StatefulWidget {
  const RecipientPickerScreen({
    super.key,
    required this.controller,
    this.multiSelect = false,
    this.existingIds = const {},
    this.includeGroups = false,
    this.initialSelectedIds = const {},
  });
  final ChatsController controller;
  final bool multiSelect;
  final Set<String> existingIds;
  final bool includeGroups;
  final Set<String> initialSelectedIds;
  @override
  State<RecipientPickerScreen> createState() => _RecipientPickerScreenState();
}

class _RecipientPickerScreenState extends State<RecipientPickerScreen> {
  String query = '';
  final Set<String> selected = {};

  bool _eligible(ChatConversation chat) => chat.kind == ChatKind.contact
      ? widget.controller.canCommunicateWithContact(chat)
      : widget.includeGroups && widget.controller.canSendTo(chat);

  @override
  void initState() {
    super.initState();
    selected.addAll(
      widget.initialSelectedIds.where(
        (id) => widget.controller.conversations.any(
          (chat) =>
              chat.id == id &&
              !widget.existingIds.contains(id) &&
              _eligible(chat),
        ),
      ),
    );
    widget.controller.addListener(_contactsChanged);
  }

  void _pruneSelection() {
    selected.removeWhere(
      (id) => !widget.controller.conversations.any(
        (chat) =>
            chat.id == id &&
            !widget.existingIds.contains(id) &&
            _eligible(chat),
      ),
    );
  }

  void _contactsChanged() {
    _pruneSelection();
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant RecipientPickerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_contactsChanged);
      widget.controller.addListener(_contactsChanged);
    }
    _pruneSelection();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_contactsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = widget.controller.conversations
        .where(
          (chat) =>
              (chat.kind == ChatKind.contact ||
                  (widget.includeGroups && chat.kind == ChatKind.group)) &&
              chat.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(
        title: Text(
          widget.multiSelect
              ? ChatCopy.selectRecipients
              : ChatCopy.selectContact,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hintText: ChatCopy.searchContacts,
              query: query,
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          if (selected.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: selected
                    .map(
                      (id) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InputChip(
                          label: Text(widget.controller.byId(id).name),
                          onDeleted: () => setState(() => selected.remove(id)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_add_alt_1)),
            title: const Text(ChatCopy.addContact),
            onTap: () async {
              final contact = await Navigator.push<ChatConversation>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditContactScreen(controller: widget.controller),
                ),
              );
              if (contact != null && context.mounted) {
                if (!_eligible(contact)) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(ChatCopy.contactSavedWaitingForMatch),
                    ),
                  );
                } else if (widget.multiSelect) {
                  setState(() => selected.add(contact.id));
                } else {
                  Navigator.pop(context, [contact]);
                }
              }
            },
          ),
          Expanded(
            child: contacts.isEmpty
                ? const AppStateView(title: ChatCopy.noContactsFound)
                : ListView(
                    children: contacts.map((chat) {
                      final existing = widget.existingIds.contains(chat.id);
                      final disabled = existing || !_eligible(chat);
                      final subtitle = disabled
                          ? existing
                                ? ChatCopy.alreadyAdded
                                : chat.kind == ChatKind.contact &&
                                      !chat.mutuallyMatched
                                ? ChatCopy.waitingForMutualMatch
                                : ChatCopy.cannotSendToThisConversation
                          : chat.subtitle;
                      if (widget.multiSelect) {
                        return AppSelectablePersonRow(
                          name: chat.name,
                          subtitle: subtitle,
                          selected: selected.contains(chat.id) || existing,
                          onChanged: disabled
                              ? null
                              : (_) => setState(
                                  () => selected.contains(chat.id)
                                      ? selected.remove(chat.id)
                                      : selected.add(chat.id),
                                ),
                        );
                      }
                      return AppPersonRow(
                        name: chat.name,
                        subtitle: subtitle,
                        subtitleMaxLines: 2,
                        enabled: !disabled,
                        onTap: () => Navigator.pop(context, [chat]),
                      );
                    }).toList(),
                  ),
          ),
          if (widget.multiSelect)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () => Navigator.pop(
                            context,
                            selected.map(widget.controller.byId).toList(),
                          ),
                    child: Text(ChatCopy.continueWithCount(selected.length)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
