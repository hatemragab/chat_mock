import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_receipt_field.dart';
import '../withdrawal_details_screen/withdrawal_details_screen.dart';

class WithdrawalReviewScreen extends StatefulWidget {
  const WithdrawalReviewScreen({
    super.key,
    required this.controller,
    required this.amount,
    required this.method,
    required this.destination,
  });
  final WalletController controller;
  final int amount;
  final PaymentMethod method;
  final String destination;
  @override
  State<WithdrawalReviewScreen> createState() => _WithdrawalReviewScreenState();
}

class _WithdrawalReviewScreenState extends State<WithdrawalReviewScreen> {
  late final id = widget.controller.newId('withdrawal');
  String? error;
  bool submitting = false;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.reviewWithdrawal)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final row in [
          (
            WalletCopy.amount,
            WalletCopy.amountWithUnit(widget.amount, WalletCopy.xaf),
          ),
          (
            WalletCopy.fee,
            WalletCopy.amountWithUnit(
              widget.controller.config.withdrawalFee,
              WalletCopy.xaf,
            ),
          ),
          (
            WalletCopy.netPayout,
            WalletCopy.amountWithUnit(
              widget.amount - widget.controller.config.withdrawalFee,
              WalletCopy.xaf,
            ),
          ),
          (WalletCopy.method, widget.method.label),
          (WalletCopy.destination, widget.destination),
        ])
          WalletReceiptField(label: row.$1, value: row.$2),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: submitting
              ? null
              : () {
                  if (submitting) return;
                  setState(() {
                    submitting = true;
                    error = null;
                  });
                  try {
                    final withdrawal = widget.controller.requestWithdrawal(
                      id: id,
                      amount: widget.amount,
                      method: widget.method,
                      destination: widget.destination,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => WithdrawalDetailsScreen(
                          controller: widget.controller,
                          withdrawal: withdrawal,
                        ),
                      ),
                    );
                  } on ArgumentError catch (exception) {
                    setState(() {
                      submitting = false;
                      error = exception.message.toString();
                    });
                  }
                },
          child: const Text(WalletCopy.confirmWithdrawal),
        ),
      ],
    ),
  );
}
