import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

/// Displays a shared link without fetching it or opening a network destination.
class LinkPreviewScreen extends StatefulWidget {
  const LinkPreviewScreen({
    super.key,
    required this.message,
    this.onShowSource,
  });
  final ChatMessage message;
  final VoidCallback? onShowSource;
  @override
  State<LinkPreviewScreen> createState() => _LinkPreviewScreenState();
}

class _LinkPreviewScreenState extends State<LinkPreviewScreen> {
  bool copied = false;
  @override
  Widget build(BuildContext context) {
    final match = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    ).firstMatch(widget.message.text);
    final link = match?.group(0) ?? '';
    return AppScaffold(
      appBar: AppHeader(title: const Text(ChatCopy.sharedLink)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.link, size: 56),
          const SizedBox(height: 16),
          SelectableText(link, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            ChatCopy.linkPreviewIsUnavailableOffline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: link.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (mounted) setState(() => copied = true);
                  },
            icon: const Icon(Icons.copy),
            label: Text(copied ? ChatCopy.copied : ChatCopy.copyLink),
          ),
          if (widget.onShowSource != null)
            TextButton.icon(
              onPressed: widget.onShowSource,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text(ChatCopy.showInChat),
            ),
        ],
      ),
    );
  }
}
