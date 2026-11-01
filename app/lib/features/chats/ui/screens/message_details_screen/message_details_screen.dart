import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../copy/chats_copy.dart';
import '../../../models/chat_models.dart';

class MessageDetailsScreen extends StatelessWidget {
  const MessageDetailsScreen({
    super.key,
    required this.message,
    this.group = false,
    this.canSeeGroupReceipts,
    this.updates,
  });
  final ChatMessage message;
  final bool group;
  final bool? canSeeGroupReceipts;
  final Listenable? updates;

  String _time(DateTime time) => ChatCopy.clockTime(time);

  Widget _screen(BuildContext context) {
    final transmitted = switch (message.status) {
      DeliveryStatus.sent ||
      DeliveryStatus.delivered ||
      DeliveryStatus.read => true,
      _ => false,
    };
    final transmissionLabel = switch (message.status) {
      DeliveryStatus.queued => ChatCopy.queued,
      DeliveryStatus.sending => ChatCopy.sending,
      DeliveryStatus.failed => ChatCopy.failedToSend,
      _ => ChatCopy.sent,
    };
    final read = message.recipients
        .where((r) => r.status == RecipientDeliveryStatus.read)
        .toList();
    final delivered = message.recipients
        .where((r) => r.status == RecipientDeliveryStatus.delivered)
        .toList();
    final pending = message.recipients
        .where((r) => r.status == RecipientDeliveryStatus.pending)
        .toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(ChatCopy.messageInfo)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(message.text, style: Theme.of(context).textTheme.titleMedium),
          const Divider(height: 32),
          if (group && !(canSeeGroupReceipts ?? message.isMine))
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text(ChatCopy.groupReceiptsSenderOnly),
            )
          else if (group) ...[
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text(ChatCopy.readBy),
              subtitle: Text(
                read.isEmpty
                    ? ChatCopy.noOneYet
                    : ChatCopy.memberCount(read.length),
              ),
            ),
            ...read.map(
              (receipt) => ListTile(
                contentPadding: const EdgeInsets.only(left: 56),
                title: Text(receipt.memberName),
                subtitle: Text(
                  receipt.readAt == null
                      ? ChatCopy.read
                      : ChatCopy.readAt(_time(receipt.readAt!)),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text(ChatCopy.deliveredTo),
              subtitle: Text(
                delivered.isEmpty
                    ? ChatCopy.noOneAwaitingARead
                    : ChatCopy.memberCount(delivered.length),
              ),
            ),
            ...delivered.map(
              (receipt) => ListTile(
                contentPadding: const EdgeInsets.only(left: 56),
                title: Text(receipt.memberName),
                subtitle: Text(
                  receipt.deliveredAt == null
                      ? ChatCopy.delivered
                      : ChatCopy.deliveredAt(_time(receipt.deliveredAt!)),
                ),
              ),
            ),
            if (pending.isNotEmpty) ...[
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text(ChatCopy.pendingDelivery),
                subtitle: Text(ChatCopy.memberCount(pending.length)),
              ),
              ...pending.map(
                (receipt) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 56),
                  title: Text(receipt.memberName),
                ),
              ),
            ],
          ] else ...[
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text(ChatCopy.read),
              subtitle: Text(
                message.status == DeliveryStatus.read
                    ? message.readAt == null
                          ? ChatCopy.read
                          : ChatCopy.readAt(_time(message.readAt!))
                    : ChatCopy.notYetRead,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text(ChatCopy.delivered),
              subtitle: Text(
                message.status == DeliveryStatus.delivered ||
                        message.status == DeliveryStatus.read
                    ? message.deliveredAt == null
                          ? ChatCopy.delivered
                          : ChatCopy.deliveredAt(_time(message.deliveredAt!))
                    : ChatCopy.pending,
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(transmissionLabel),
            subtitle: Text(
              transmitted
                  ? _time(message.time)
                  : ChatCopy.createdAt(_time(message.time)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => updates == null
      ? _screen(context)
      : ListenableBuilder(
          listenable: updates!,
          builder: (context, _) => _screen(context),
        );
}
