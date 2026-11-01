import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_state_view.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/chats_controller.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';
import '../../navigation/chat_destination.dart';
import '../link_preview_screen/link_preview_screen.dart';
import '../media_viewer_screen/media_viewer_screen.dart';

class SharedMediaScreen extends StatefulWidget {
  const SharedMediaScreen({
    super.key,
    required this.chat,
    this.controller,
    this.specialMessageScreenBuilder,
  });
  final ChatConversation chat;
  final ChatsController? controller;
  final SpecialMessageScreenBuilder? specialMessageScreenBuilder;
  @override
  State<SharedMediaScreen> createState() => _SharedMediaScreenState();
}

class _SharedMediaScreenState extends State<SharedMediaScreen> {
  int selected = 0;

  void _open(ChatMessage message) {
    final navigator = Navigator.of(context);
    final controller = widget.controller;
    final canShowSource =
        controller != null &&
        (widget.chat.kind == ChatKind.contact ||
            widget.specialMessageScreenBuilder != null);
    void showSource() {
      if (controller == null ||
          !widget.chat.messages.contains(message) ||
          message.deleted) {
        return;
      }
      navigator.pop();
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => chatDestination(
            controller: controller,
            chat: widget.chat,
            messageId: message.id,
            specialMessageScreenBuilder: widget.specialMessageScreenBuilder,
          ),
        ),
      );
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => selected == 2
            ? LinkPreviewScreen(
                message: message,
                onShowSource: canShowSource ? showSource : null,
              )
            : MediaViewerScreen(
                message: message,
                onShowSource: canShowSource ? showSource : null,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.chat.messages
        .where(
          (message) =>
              !message.deleted &&
              switch (selected) {
                0 =>
                  message.kind == MessageKind.photo ||
                      message.kind == MessageKind.video ||
                      message.kind == MessageKind.audio,
                1 => message.kind == MessageKind.document,
                _ => RegExp(
                  r'https?://[^\s]+',
                  caseSensitive: false,
                ).hasMatch(message.text),
              },
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(ChatCopy.mediaFilesAndLinks)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text(ChatCopy.media)),
                ButtonSegment(value: 1, label: Text(ChatCopy.files)),
                ButtonSegment(value: 2, label: Text(ChatCopy.links)),
              ],
              selected: {selected},
              onSelectionChanged: (value) =>
                  setState(() => selected = value.first),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const AppStateView(title: ChatCopy.nothingSharedHereYet)
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final message = items[index];
                      final icon = selected == 2
                          ? Icons.link
                          : switch (message.kind) {
                              MessageKind.document =>
                                Icons.description_outlined,
                              MessageKind.audio => Icons.audiotrack,
                              MessageKind.video => Icons.videocam_outlined,
                              _ => Icons.image_outlined,
                            };
                      return ListTile(
                        leading: Icon(icon),
                        title: Text(
                          message.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _open(message),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
