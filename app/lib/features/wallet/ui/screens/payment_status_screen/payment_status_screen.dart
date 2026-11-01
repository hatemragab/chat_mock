import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../dialogs/cancel_payment_dialog/cancel_payment_dialog.dart';
import '../../widgets/wallet_receipt_field.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({
    super.key,
    required this.controller,
    required this.payment,
  });
  final WalletController controller;
  final WalletPayment payment;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.paymentStatus)),
    body: ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final label = switch (payment.status) {
          PaymentStatus.processing => WalletCopy.processing,
          PaymentStatus.pending => WalletCopy.pending,
          PaymentStatus.failed => WalletCopy.failed,
          PaymentStatus.cancelled => WalletCopy.cancelled,
          PaymentStatus.confirmed => WalletCopy.confirmed,
        };
        final terminal =
            payment.status == PaymentStatus.confirmed ||
            payment.status == PaymentStatus.cancelled;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(switch (payment.status) {
              PaymentStatus.confirmed => Icons.check_circle_outline,
              PaymentStatus.cancelled => Icons.cancel_outlined,
              PaymentStatus.failed => Icons.error_outline,
              _ => Icons.hourglass_top,
            }, size: 54),
            const SizedBox(height: 16),
            Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              payment.status == PaymentStatus.confirmed
                  ? WalletCopy.paymentConfirmed(payment.credits)
                  : WalletCopy.creditOnlyOnConfirmation,
            ),
            WalletReceiptField(
              label: WalletCopy.provider,
              value: WalletCopy.paymentProvider(payment.method.label),
            ),
            WalletReceiptField(label: WalletCopy.reference, value: payment.id),
            if (!terminal) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => controller.setPaymentStatus(
                  payment.id,
                  switch (payment.status) {
                    PaymentStatus.failed => PaymentStatus.processing,
                    PaymentStatus.processing => PaymentStatus.pending,
                    _ => PaymentStatus.confirmed,
                  },
                ),
                child: Text(
                  payment.status == PaymentStatus.failed
                      ? CommonCopy.retry
                      : WalletCopy.refreshStatus,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final cancel = await showDialog<bool>(
                    context: context,
                    builder: (_) => CancelPaymentDialog(payment: payment),
                  );
                  if (cancel == true) {
                    controller.setPaymentStatus(
                      payment.id,
                      PaymentStatus.cancelled,
                    );
                  }
                },
                child: const Text(WalletCopy.cancelPayment),
              ),
            ] else
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  payment.status == PaymentStatus.confirmed,
                ),
                child: const Text(CommonCopy.done),
              ),
          ],
        );
      },
    ),
  );
}
