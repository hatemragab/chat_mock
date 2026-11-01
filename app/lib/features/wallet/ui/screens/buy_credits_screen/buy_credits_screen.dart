import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../sheets/payment_method_sheet/payment_method_sheet.dart';
import '../payment_review_screen/payment_review_screen.dart';

class BuyCreditsScreen extends StatefulWidget {
  const BuyCreditsScreen({
    super.key,
    required this.controller,
    this.returnAfterConfirmation = false,
  });
  final WalletController controller;

  /// Returns to the interrupted review after a confirmed top-up.
  final bool returnAfterConfirmation;
  @override
  State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen> {
  final amount = TextEditingController(text: '100');
  final phone = TextEditingController();
  PaymentMethod method = PaymentMethod.mtn;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credits = int.tryParse(amount.text) ?? 0;
    return AppScaffold(
      appBar: AppHeader(title: const Text(WalletCopy.buyCredits)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            WalletCopy.chooseAmount,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final value in [100, 500, 1000])
                ChoiceChip(
                  label: Text('$value'),
                  selected: credits == value,
                  onSelected: (_) => setState(() => amount.text = '$value'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: WalletCopy.credits,
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            WalletCopy.estimatedTotal(
              credits * widget.controller.config.xafPerCredit,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(WalletCopy.paymentMethod),
            subtitle: Text(method.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showModalBottomSheet<PaymentMethod>(
                context: context,
                builder: (_) => PaymentMethodSheet(selected: method),
              );
              if (selected != null && mounted) {
                setState(() => method = selected);
              }
            },
          ),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: WalletCopy.mobileMoneyPhone,
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              if (credits <= 0 || !WalletController.validPhone(phone.text)) {
                setState(() => error = WalletCopy.invalidCreditAmountAndPhone);
                return;
              }
              final confirmed = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (_) => PaymentReviewScreen(
                    controller: widget.controller,
                    credits: credits,
                    method: method,
                    phone: phone.text,
                  ),
                ),
              );
              if (confirmed == true &&
                  widget.returnAfterConfirmation &&
                  context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(WalletCopy.reviewPayment),
          ),
        ],
      ),
    );
  }
}
