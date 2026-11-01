import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../chats/controllers/chats_controller.dart';
import '../../../../chats/models/chat_models.dart';
import '../../../../chats/ui/screens/conversation_screen/conversation_screen.dart';
import '../../../../chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';
import '../../widgets/business_call_story_cover.dart';
import '../call_details_screen/call_details_screen.dart';
import '../call_screen/call_screen.dart';

enum _HistoryFilter { recent, missed, business }

extension on _HistoryFilter {
  String get label => switch (this) {
    _HistoryFilter.recent => CallsCopy.recent,
    _HistoryFilter.missed => CallsCopy.missed,
    _HistoryFilter.business => CallsCopy.business,
  };
}

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key, required this.controller, this.chats});
  final CallsController controller;
  final ChatsController? chats;
  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  _HistoryFilter filter = _HistoryFilter.recent;
  void openCall(CallSession call) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => CallScreen(controller: widget.controller, call: call),
    ),
  );

  Future<void> _startCall() async {
    final existing = widget.controller.active;
    if (existing != null) {
      widget.controller.setMinimized(false);
      openCall(existing);
      return;
    }
    final chats = widget.chats;
    String? name;
    ChatConversation? selectedContact;
    if (chats == null) {
      name = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final name in [
                'Sarah Wilson',
                'Amira Hassan',
                'John Davis',
                'Karim Diallo',
                'Maya Chen',
                'Leo Martin',
              ])
                ListTile(
                  title: Text(name),
                  onTap: () => Navigator.pop(sheetContext, name),
                ),
            ],
          ),
        ),
      );
    } else {
      final selection = await Navigator.push<List<ChatConversation>>(
        context,
        MaterialPageRoute(
          builder: (_) => RecipientPickerScreen(controller: chats),
        ),
      );
      if (selection != null &&
          selection.isNotEmpty &&
          mounted &&
          !chats.canCommunicateWithContact(selection.first)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(CallsCopy.mutualContactRequired)),
        );
      }
      if (selection != null &&
          selection.isNotEmpty &&
          chats.canCommunicateWithContact(selection.first)) {
        selectedContact = selection.first;
        name = selectedContact.name;
      }
    }
    if (!mounted || name == null) return;
    final selectedName = name;
    final kind = await showModalBottomSheet<CallKind>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(CallsCopy.callContact(selectedName)),
              subtitle: const Text(CallsCopy.personalCallsFree),
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text(CallsCopy.audioCall),
              onTap: () => Navigator.pop(sheetContext, CallKind.audio),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text(CallsCopy.videoCall),
              onTap: () => Navigator.pop(sheetContext, CallKind.video),
            ),
          ],
        ),
      ),
    );
    if (!mounted || kind == null) return;
    if (widget.controller.active != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CallsCopy.endCurrentCallFirst)),
      );
      return;
    }
    if (selectedContact != null &&
        !chats!.canCommunicateWithContact(selectedContact)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CallsCopy.mutualContactRequired)),
      );
      return;
    }
    openCall(
      widget.controller.start(
        name: selectedContact?.name ?? name,
        kind: kind,
        contactId: selectedContact?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, ?widget.chats]),
    builder: (context, _) {
      final calls = widget.controller.history
          .where(
            (call) =>
                filter == _HistoryFilter.recent ||
                (filter == _HistoryFilter.missed &&
                    call.phase == CallPhase.missed) ||
                (filter == _HistoryFilter.business && call.business),
          )
          .toList();
      return AppScaffold(
        appBar: AppHeader(title: const Text(CallsCopy.calls)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Wrap(
              spacing: 8,
              children: _HistoryFilter.values
                  .map(
                    (item) => ChoiceChip(
                      label: Text(item.label),
                      selected: filter == item,
                      onSelected: (_) => setState(() => filter = item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            if (widget.controller.active case final call?)
              ListTile(
                leading: call.business && call.story != null
                    ? BusinessCallStoryCover(story: call.story!, size: 44)
                    : const Icon(Icons.call),
                title: Text(CallsCopy.ongoingWith(call.name)),
                subtitle: const Text(CallsCopy.tapToReturn),
                onTap: () {
                  widget.controller.setMinimized(false);
                  openCall(call);
                },
              ),
            if (calls.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 35),
                child: Center(child: Text(CallsCopy.noCalls)),
              ),
            ...calls.map(
              (call) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: call.business && call.story != null
                    ? BusinessCallStoryCover(story: call.story!, size: 44)
                    : AppAvatar(name: call.name),
                title: Text(call.name),
                subtitle: Text(
                  CallsCopy.historyStatus(call.incoming, call.phase.label),
                ),
                trailing: Icon(
                  call.kind == CallKind.audio
                      ? Icons.call_outlined
                      : Icons.videocam_outlined,
                ),
                onTap: () {
                  final chats = widget.chats;
                  final matches =
                      chats?.conversations
                          .where(
                            (chat) =>
                                chat.kind == ChatKind.contact &&
                                (call.contactId != null
                                    ? chat.id == call.contactId
                                    : chat.name == call.name),
                          )
                          .toList() ??
                      <ChatConversation>[];
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (detailsContext) => CallDetailsScreen(
                        call: call,
                        controller: widget.controller,
                        onMessage: matches.length != 1 || chats == null
                            ? null
                            : () => Navigator.push(
                                detailsContext,
                                MaterialPageRoute<void>(
                                  builder: (_) => ConversationScreen(
                                    controller: chats,
                                    chat: matches.first,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _startCall,
              icon: const Icon(Icons.add_call),
              label: const Text(CallsCopy.startCall),
            ),
          ],
        ),
      );
    },
  );
}
