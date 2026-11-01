import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../copy/chats_copy.dart';
import '../../models/chat_models.dart';
import 'chat_media_visual.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.group,
    required this.onLongPress,
    this.highlight = false,
    this.isMine,
    this.groupedWithPrevious = false,
    this.groupedWithNext = false,
    this.onTap,
    this.onRetry,
  });
  final ChatMessage message;
  final bool group;
  final VoidCallback onLongPress;
  final bool highlight;
  final bool? isMine;
  final bool groupedWithPrevious;
  final bool groupedWithNext;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (message.kind == MessageKind.system) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final mine = isMine ?? message.isMine;
    final color = mine
        ? (dark ? AppColors.darkOutgoing : AppColors.lightOutgoing)
        : (dark ? AppColors.darkIncoming : AppColors.lightIncoming);
    final status = switch (message.status) {
      DeliveryStatus.queued => Icons.schedule,
      DeliveryStatus.sending => Icons.schedule,
      DeliveryStatus.sent => Icons.done,
      DeliveryStatus.delivered => Icons.done_all,
      DeliveryStatus.read => Icons.done_all,
      DeliveryStatus.failed => Icons.error_outline,
    };
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .76,
        ),
        child: GestureDetector(
          onLongPress: onLongPress,
          onTap: message.deleted ? null : onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            padding: const EdgeInsets.fromLTRB(11, 8, 10, 6),
            decoration: BoxDecoration(
              color: highlight
                  ? Theme.of(context).colorScheme.primaryContainer
                  : color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(!mine && groupedWithPrevious ? 4 : 12),
                topRight: Radius.circular(mine && groupedWithPrevious ? 4 : 12),
                bottomLeft: Radius.circular(
                  mine ? 12 : (groupedWithNext ? 4 : 2),
                ),
                bottomRight: Radius.circular(
                  mine ? (groupedWithNext ? 4 : 2) : 12,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (group && !mine && !groupedWithPrevious)
                  Text(
                    message.author,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                if (message.quote != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      message.quote!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                if (!message.deleted &&
                    message.mediaEdits != null &&
                    message.assetPath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ChatMediaVisual(
                      assetPath: message.assetPath!,
                      edits: message.mediaEdits,
                      height: 130,
                    ),
                  ),
                if (!message.deleted && message.kind != MessageKind.text)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(switch (message.kind) {
                      MessageKind.photo => Icons.photo_outlined,
                      MessageKind.video => Icons.videocam_outlined,
                      MessageKind.document => Icons.description_outlined,
                      MessageKind.audio => Icons.play_circle_outline,
                      MessageKind.contact => Icons.person_outline,
                      _ => Icons.message_outlined,
                    }),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: message.deleted
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                if (!message.deleted &&
                    message.mediaEdits?.caption.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(message.mediaEdits!.caption),
                  ),
                if (message.uploadState == UploadState.uploading) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: message.uploadProgress,
                    minHeight: 3,
                  ),
                  Text(
                    ChatCopy.uploadProgress(
                      (message.uploadProgress * 100).round(),
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
                if (message.uploadState == UploadState.queued)
                  Text(
                    ChatCopy.waitingForConnection,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (message.uploadState == UploadState.failed)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text(ChatCopy.uploadFailedRetry),
                  ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.reaction != null) Text(message.reaction!),
                    if (message.starred) const Icon(Icons.star, size: 12),
                    if (message.pinned) const Icon(Icons.push_pin, size: 12),
                    Text(
                      ChatCopy.clockTime(message.time),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (mine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        status,
                        size: 14,
                        color: message.status == DeliveryStatus.read
                            ? Colors.blue
                            : null,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
