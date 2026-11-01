import 'package:flutter/material.dart';

import '../../copy/prototype_tools_copy.dart';

import '../../../chats/controllers/chats_controller.dart';
import '../../../chats/models/chat_models.dart';

class DirectReceiptReviewControls extends StatelessWidget {
  const DirectReceiptReviewControls({super.key, required this.chats});
  final ChatsController chats;

  @override
  Widget build(BuildContext context) {
    (ChatConversation, ChatMessage)? candidate;
    final readEnabled = chats.readReceiptsEnabled?.call() ?? true;
    var hasDeliveredWithoutRead = false;
    for (final chat in chats.conversations) {
      if (chat.kind != ChatKind.contact || chat.blocked || chat.hidden) {
        continue;
      }
      for (final message in chat.messages) {
        if (message.isMine &&
            !message.deleted &&
            message.status == DeliveryStatus.delivered &&
            !readEnabled) {
          hasDeliveredWithoutRead = true;
          continue;
        }
        if (message.isMine &&
            !message.deleted &&
            (message.status == DeliveryStatus.sent ||
                message.status == DeliveryStatus.delivered)) {
          candidate = (chat, message);
          break;
        }
      }
      if (candidate != null) break;
    }
    final next = candidate?.$2.status == DeliveryStatus.sent
        ? DeliveryStatus.delivered
        : DeliveryStatus.read;
    final available =
        candidate != null &&
        chats.online &&
        (next != DeliveryStatus.read || readEnabled);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.done_all),
      title: const Text(PrototypeToolsCopy.advanceDirectMessageReceipt),
      subtitle: Text(
        candidate == null && hasDeliveredWithoutRead
            ? PrototypeToolsCopy.readReceiptsAreDisabled
            : candidate == null
            ? PrototypeToolsCopy.sendADirectMessageToReviewDelivery
            : PrototypeToolsCopy.receiptProgress(
                candidate.$1.name,
                candidate.$2.status.name,
                next.name,
              ),
      ),
      enabled: available,
      onTap: available
          ? () => chats.advanceDirectReceipt(candidate!.$1, candidate.$2, next)
          : null,
    );
  }
}
