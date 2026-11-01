import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

class EditContactScreen extends StatefulWidget {
  const EditContactScreen({super.key, required this.controller, this.contact});
  final ChatsController controller;
  final ChatConversation? contact;
  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = widget.contact?.name ?? '';
    _phone.text = widget.contact?.phone ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(
      title: Text(
        widget.contact == null ? ChatCopy.addContact : ChatCopy.editContact,
      ),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            ChatCopy.contactEditorDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: ChatCopy.name),
            validator: (value) => value == null || value.trim().isEmpty
                ? ChatCopy.enterAName
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: ChatCopy.phoneNumber,
              hintText: ChatCopy.phoneHint,
            ),
            validator: (value) {
              final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
              if (digits.length < 7 || digits.length > 15) {
                return ChatCopy.enterAValidPhoneNumber;
              }
              final duplicate = widget.controller.conversations.any(
                (chat) =>
                    chat.kind == ChatKind.contact &&
                    chat != widget.contact &&
                    (chat.phone ?? '').replaceAll(RegExp(r'\D'), '') == digits,
              );
              return duplicate ? ChatCopy.duplicatePhone : null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                final contact = widget.contact;
                if (contact != null) {
                  if (widget.controller.updateContact(
                    contact,
                    _name.text,
                    _phone.text,
                  )) {
                    Navigator.pop(context, contact);
                  }
                  return;
                }
                Navigator.pop(
                  context,
                  widget.controller.addContact(_name.text, _phone.text),
                );
              }
            },
            child: const Text(ChatCopy.saveContact),
          ),
        ],
      ),
    ),
  );
}
