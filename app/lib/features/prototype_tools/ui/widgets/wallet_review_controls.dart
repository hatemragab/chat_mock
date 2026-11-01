import 'package:flutter/material.dart';

import '../../copy/prototype_tools_copy.dart';

import '../../../wallet/controllers/wallet_controller.dart';
import '../../../wallet/models/wallet_models.dart';

class WalletReviewControls extends StatelessWidget {
  const WalletReviewControls({super.key, required this.wallet});
  final WalletController wallet;

  @override
  Widget build(BuildContext context) {
    final payments = wallet.payments;
    final withdrawals = wallet.withdrawals;
    final payment = payments.isEmpty ? null : payments.last;
    final withdrawal = withdrawals.isEmpty ? null : withdrawals.first;
    final nextWithdrawal = switch (withdrawal?.status) {
      WithdrawalStatus.pending => WithdrawalStatus.inProgress,
      WithdrawalStatus.inProgress => WithdrawalStatus.approved,
      WithdrawalStatus.approved => WithdrawalStatus.paid,
      _ => null,
    };
    final paymentCanChange =
        payment != null &&
        payment.status != PaymentStatus.confirmed &&
        payment.status != PaymentStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          PrototypeToolsCopy.diamondConversion,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(PrototypeToolsCopy.conversionRate(wallet.conversionRate)),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: () =>
                  wallet.setConversionRate(wallet.conversionRate + 1),
              child: const Text(PrototypeToolsCopy.increaseRateByOneXaf),
            ),
            OutlinedButton(
              onPressed: wallet.conversionRate == wallet.config.xafPerDiamond
                  ? null
                  : () => wallet.setConversionRate(wallet.config.xafPerDiamond),
              child: const Text(PrototypeToolsCopy.restoreDefaultRate),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(PrototypeToolsCopy.failNextConversion),
          subtitle: const Text(PrototypeToolsCopy.conversionFailureDescription),
          value: wallet.failNextConversion,
          onChanged: wallet.setConversionFailure,
        ),
        const SizedBox(height: 16),
        Text(
          PrototypeToolsCopy.paymentAndPayout,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (payment == null)
          const Text(PrototypeToolsCopy.noPaymentDescription)
        else ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(PrototypeToolsCopy.latestPayment),
            subtitle: Text(
              PrototypeToolsCopy.paymentSummary(
                payment.credits,
                payment.status.name,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final outcome in [
                PaymentStatus.pending,
                PaymentStatus.failed,
                PaymentStatus.cancelled,
                PaymentStatus.confirmed,
              ])
                OutlinedButton(
                  onPressed: paymentCanChange
                      ? () => wallet.setPaymentStatus(payment.id, outcome)
                      : null,
                  child: Text(outcome.name),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (withdrawal == null)
          const Text(PrototypeToolsCopy.noWithdrawalDescription)
        else ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(PrototypeToolsCopy.latestWithdrawal),
            subtitle: Text(
              PrototypeToolsCopy.withdrawalSummary(
                withdrawal.amount,
                withdrawal.status.label,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (nextWithdrawal != null)
                OutlinedButton(
                  onPressed: () =>
                      wallet.setWithdrawalStatus(withdrawal.id, nextWithdrawal),
                  child: Text(
                    PrototypeToolsCopy.advanceWithdrawal(nextWithdrawal.label),
                  ),
                ),
              if (nextWithdrawal != null)
                OutlinedButton(
                  onPressed: () => wallet.setWithdrawalStatus(
                    withdrawal.id,
                    WithdrawalStatus.rejected,
                  ),
                  child: const Text(PrototypeToolsCopy.reject),
                ),
              if (nextWithdrawal != null)
                OutlinedButton(
                  onPressed: () => wallet.setWithdrawalStatus(
                    withdrawal.id,
                    WithdrawalStatus.failed,
                  ),
                  child: const Text(PrototypeToolsCopy.fail),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
