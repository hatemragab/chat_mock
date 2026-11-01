import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_receipt_field.dart';

class WithdrawalDetailsScreen extends StatelessWidget {
  const WithdrawalDetailsScreen({
    super.key,
    required this.controller,
    required this.withdrawal,
  });
  final WalletController controller;
  final WalletWithdrawal withdrawal;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.withdrawalDetails)),
    body: ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final next = switch (withdrawal.status) {
          WithdrawalStatus.pending => WithdrawalStatus.inProgress,
          WithdrawalStatus.inProgress => WithdrawalStatus.approved,
          WithdrawalStatus.approved => WithdrawalStatus.paid,
          _ => null,
        };
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              withdrawal.status.label,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            for (final row in [
              (
                WalletCopy.amount,
                WalletCopy.amountWithUnit(withdrawal.amount, WalletCopy.xaf),
              ),
              (
                WalletCopy.fee,
                WalletCopy.amountWithUnit(withdrawal.fee, WalletCopy.xaf),
              ),
              (
                WalletCopy.netPayout,
                WalletCopy.amountWithUnit(withdrawal.net, WalletCopy.xaf),
              ),
              (WalletCopy.method, withdrawal.method.label),
              (WalletCopy.destination, withdrawal.destination),
              (WalletCopy.reference, withdrawal.id),
              (
                WalletCopy.date,
                withdrawal.date.toLocal().toString().substring(0, 16),
              ),
            ])
              WalletReceiptField(label: row.$1, value: row.$2),
            const SizedBox(height: 16),
            Text(
              WalletCopy.statusTimeline,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final event in withdrawal.events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  event.status == WithdrawalStatus.failed ||
                          event.status == WithdrawalStatus.rejected
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                ),
                title: Text(event.status.label),
                subtitle: Text(
                  WalletCopy.withdrawalEvent(event.date, event.reason),
                ),
              ),
            if (next != null) ...[
              FilledButton(
                onPressed: () =>
                    controller.setWithdrawalStatus(withdrawal.id, next),
                child: const Text(WalletCopy.refreshStatus),
              ),
            ],
            if (withdrawal.status == WithdrawalStatus.rejected ||
                withdrawal.status == WithdrawalStatus.failed)
              const Text(WalletCopy.reservedCashReturned),
          ],
        );
      },
    ),
  );
}
