import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_ledger_row.dart';
import '../../widgets/wallet_receipt_field.dart';
import '../payment_status_screen/payment_status_screen.dart';
import '../withdrawal_details_screen/withdrawal_details_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.activity,
    this.controller,
  });
  final WalletActivity activity;
  final WalletController? controller;

  @override
  Widget build(BuildContext context) {
    Widget details(WalletActivity current) {
      final wallet = controller;
      final related =
          wallet?.activity
              .where(
                (entry) =>
                    entry.reference == current.reference &&
                    entry.id != current.id,
              )
              .toList() ??
          <WalletActivity>[];
      final withdrawal = wallet?.withdrawals
          .where((item) => item.id == current.reference)
          .firstOrNull;
      final payment = wallet?.payments
          .where((item) => item.id == current.reference)
          .firstOrNull;
      return AppScaffold(
        appBar: AppHeader(title: const Text(WalletCopy.transactionDetails)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              WalletCopy.signedAmount(current.amount, current.kind.unit),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            for (final row in [
              (WalletCopy.type, current.title),
              (
                WalletCopy.direction,
                current.amount < 0 ? WalletCopy.spent : WalletCopy.received,
              ),
              (WalletCopy.status, current.status),
              (WalletCopy.reference, current.reference),
              (
                WalletCopy.date,
                current.date.toLocal().toString().substring(0, 16),
              ),
              (WalletCopy.details, current.description),
            ])
              WalletReceiptField(label: row.$1, value: row.$2),
            if (withdrawal != null)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text(WalletCopy.viewWithdrawal),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => WithdrawalDetailsScreen(
                      controller: wallet!,
                      withdrawal: withdrawal,
                    ),
                  ),
                ),
              ),
            if (payment != null)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text(WalletCopy.viewPayment),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (_) => PaymentStatusScreen(
                      controller: wallet!,
                      payment: payment,
                    ),
                  ),
                ),
              ),
            if (related.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                WalletCopy.relatedActivity,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final entry in related)
                WalletLedgerRow(
                  activity: entry,
                  showDate: false,
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => TransactionDetailsScreen(
                        activity: entry,
                        controller: wallet,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    }

    final wallet = controller;
    if (wallet == null) return details(activity);
    return ListenableBuilder(
      listenable: wallet,
      builder: (context, _) {
        final matching = wallet.activity.where(
          (entry) => entry.id == activity.id,
        );
        return details(matching.isEmpty ? activity : matching.first);
      },
    );
  }
}
