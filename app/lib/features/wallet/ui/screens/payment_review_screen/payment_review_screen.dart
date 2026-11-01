import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_receipt_field.dart';
import '../payment_status_screen/payment_status_screen.dart';

class PaymentReviewScreen extends StatefulWidget {
  const PaymentReviewScreen({
    super.key,
    required this.controller,
    required this.credits,
    required this.method,
    required this.phone,
  });
  final WalletController controller;
  final int credits;
  final PaymentMethod method;
  final String phone;
  @override
  State<PaymentReviewScreen> createState() => _PaymentReviewScreenState();
}

class _PaymentReviewScreenState extends State<PaymentReviewScreen> {
  String? paymentId;
  bool submitted = false;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.reviewPayment)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          WalletCopy.amountWithUnit(widget.credits, WalletCopy.credits),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        for (final item in [
          (
            WalletCopy.total,
            WalletCopy.amountWithUnit(
              widget.credits * widget.controller.config.xafPerCredit,
              WalletCopy.xaf,
            ),
          ),
          (WalletCopy.method, widget.method.label),
          (WalletCopy.number, widget.phone),
          (WalletCopy.provider, WalletCopy.providerName),
        ])
          WalletReceiptField(label: item.$1, value: item.$2),
        const SizedBox(height: 24),
        const Text(WalletCopy.paymentSimulation),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: submitted
              ? null
              : () async {
                  setState(() => submitted = true);
                  final payment = widget.controller.startPayment(
                    id: paymentId ??= widget.controller.newId('payment'),
                    credits: widget.credits,
                    method: widget.method,
                    phone: widget.phone,
                  );
                  final confirmed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (_) => PaymentStatusScreen(
                        controller: widget.controller,
                        payment: payment,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  // Back navigation can close the status page without a
                  // result even after the payment has been confirmed. The
                  // payment itself is the source of truth for returning to
                  // the interrupted action.
                  if (confirmed == true ||
                      payment.status == PaymentStatus.confirmed) {
                    Navigator.pop(context, true);
                  } else {
                    setState(() {
                      if (payment.status == PaymentStatus.cancelled) {
                        paymentId = null;
                      }
                      submitted = false;
                    });
                  }
                },
          child: const Text(WalletCopy.continueToProvider),
        ),
      ],
    ),
  );
}
