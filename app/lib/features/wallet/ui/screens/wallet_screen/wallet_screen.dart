import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_balance_card.dart';
import '../balance_activity_screen/balance_activity_screen.dart';
import '../buy_credits_screen/buy_credits_screen.dart';
import '../convert_diamonds_screen/convert_diamonds_screen.dart';
import '../withdrawal_form_screen/withdrawal_form_screen.dart';
import '../withdrawal_history_screen/withdrawal_history_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.controller});
  final WalletController controller;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.wallet)),
    body: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            WalletCopy.yourBalances,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(WalletCopy.manageBalances),
          const SizedBox(height: 16),
          for (final entry in [
            (BalanceKind.credits, controller.credits),
            (BalanceKind.diamonds, controller.diamonds),
            (BalanceKind.cash, controller.cash),
          ])
            WalletBalanceCard(
              kind: entry.$1,
              amount: entry.$2,
              pending: controller.pendingDiamonds,
              frozen: controller.frozenDiamonds,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => BalanceActivityScreen(
                    controller: controller,
                    kind: entry.$1,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BuyCreditsScreen(controller: controller),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(WalletCopy.buyCredits),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ConvertDiamondsScreen(controller: controller),
              ),
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text(WalletCopy.convertDiamonds),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => WithdrawalFormScreen(controller: controller),
              ),
            ),
            icon: const Icon(Icons.outbox_outlined),
            label: const Text(WalletCopy.withdrawCash),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => WithdrawalHistoryScreen(controller: controller),
              ),
            ),
            child: const Text(WalletCopy.withdrawalHistory),
          ),
        ],
      ),
    ),
  );
}
