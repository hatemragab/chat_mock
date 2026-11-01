import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../screens/buy_credits_screen/buy_credits_screen.dart';

/// Leaves the interrupted route in place so the caller can re-review its action.
class InsufficientCreditsSheet extends StatelessWidget {
  const InsufficientCreditsSheet({
    super.key,
    required this.controller,
    required this.requiredCredits,
  });
  final WalletController controller;
  final int requiredCredits;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            WalletCopy.notEnoughCredits,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(WalletCopy.requiredCredits(requiredCredits)),
          Text(WalletCopy.availableCredits(controller.credits)),
          Text(
            WalletCopy.missingCredits(
              (requiredCredits - controller.credits).clamp(0, requiredCredits),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<bool>(
                  builder: (_) => BuyCreditsScreen(
                    controller: controller,
                    returnAfterConfirmation: true,
                  ),
                ),
              );
            },
            child: const Text(WalletCopy.buyCredits),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.cancel),
          ),
        ],
      ),
    ),
  );
}
