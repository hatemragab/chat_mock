import 'package:flutter/material.dart';

import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';

class CancelPaymentDialog extends StatelessWidget {
  const CancelPaymentDialog({super.key, required this.payment});
  final WalletPayment payment;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(WalletCopy.cancelPaymentQuestion),
    content: Text(
      WalletCopy.cancelPurchase(payment.credits, payment.method.label),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(WalletCopy.keepPayment),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(WalletCopy.cancelPayment),
      ),
    ],
  );
}
