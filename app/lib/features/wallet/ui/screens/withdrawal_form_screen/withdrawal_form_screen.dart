import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../sheets/payout_method_sheet/payout_method_sheet.dart';
import '../withdrawal_review_screen/withdrawal_review_screen.dart';

class WithdrawalFormScreen extends StatefulWidget {
  const WithdrawalFormScreen({
    super.key,
    required this.controller,
    this.initialAmount,
    this.initialDestination,
    this.validateInitially = false,
  });
  final WalletController controller;
  final int? initialAmount;
  final String? initialDestination;
  final bool validateInitially;
  @override
  State<WithdrawalFormScreen> createState() => _WithdrawalFormScreenState();
}

class _WithdrawalFormScreenState extends State<WithdrawalFormScreen> {
  late final amount = TextEditingController(
    text: widget.initialAmount?.toString(),
  );
  late final phone = TextEditingController(text: widget.initialDestination);
  PaymentMethod method = PaymentMethod.mtn;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.validateInitially) {
      error = widget.controller.withdrawalError(
        amount: widget.initialAmount ?? 0,
        destination: widget.initialDestination ?? '',
      );
    }
  }

  @override
  void dispose() {
    amount.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.withdrawCash)),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            WalletCopy.availableCash(widget.controller.cash),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            WalletCopy.withdrawalTerms(
              widget.controller.config.withdrawalMinimum,
              widget.controller.config.withdrawalFee,
            ),
          ),
          Text(
            WalletCopy.withdrawalFrequency(
              widget.controller.config.withdrawalsPerDay,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => error = null),
            decoration: const InputDecoration(
              labelText: WalletCopy.amountInXaf,
              border: OutlineInputBorder(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(WalletCopy.payoutMethod),
            subtitle: Text(method.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showModalBottomSheet<PaymentMethod>(
                context: context,
                builder: (_) => PayoutMethodSheet(
                  selected: method,
                  fee: widget.controller.config.withdrawalFee,
                ),
              );
              if (selected != null && mounted) {
                setState(() => method = selected);
              }
            },
          ),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() => error = null),
            decoration: const InputDecoration(
              labelText: WalletCopy.mobileMoneyNumber,
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
            onPressed: () {
              final value = int.tryParse(amount.text) ?? 0;
              final problem = widget.controller.withdrawalError(
                amount: value,
                destination: phone.text,
              );
              if (problem != null) {
                setState(() => error = problem);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => WithdrawalReviewScreen(
                    controller: widget.controller,
                    amount: value,
                    method: method,
                    destination: phone.text,
                  ),
                ),
              );
            },
            child: const Text(WalletCopy.reviewWithdrawal),
          ),
        ],
      ),
    ),
  );
}
