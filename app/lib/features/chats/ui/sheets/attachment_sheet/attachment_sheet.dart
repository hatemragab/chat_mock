import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_section_heading.dart';

import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

/// Offers local sample media without requesting access to a real device.
class AttachmentSheet extends StatelessWidget {
  const AttachmentSheet({super.key, required this.onSelected});
  final void Function(MessageKind kind, String name) onSelected;

  @override
  Widget build(BuildContext context) {
    const entries = <(IconData, String, MessageKind, String)>[
      (
        Icons.photo_outlined,
        ChatCopy.photoLibrary,
        MessageKind.photo,
        'Sample photo',
      ),
      (
        Icons.videocam_outlined,
        ChatCopy.videoLibrary,
        MessageKind.video,
        'Sample video',
      ),
      (
        Icons.camera_alt_outlined,
        ChatCopy.camera,
        MessageKind.photo,
        'Sample camera photo',
      ),
      (
        Icons.description_outlined,
        ChatCopy.document,
        MessageKind.document,
        'Design brief.pdf',
      ),
      (Icons.audiotrack, ChatCopy.audio, MessageKind.audio, 'Sample audio'),
      (
        Icons.person_outline,
        ChatCopy.contact,
        MessageKind.contact,
        'Sarah Wilson',
      ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: const AppSectionHeading(title: ChatCopy.shareASample),
            ),
            for (final entry in entries)
              ListTile(
                leading: Icon(entry.$1),
                title: Text(entry.$2),
                subtitle: const Text(ChatCopy.simulatedSelection),
                onTap: () => onSelected(entry.$3, entry.$4),
              ),
          ],
        ),
      ),
    );
  }
}
