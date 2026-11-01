import 'package:flutter/material.dart';

import '../../copy/wallet_copy.dart';
import '../../models/wallet_models.dart';
import '../utils/wallet_amount_layout.dart';

/// Balance presentation shared across the three wallet balance kinds.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.kind,
    required this.amount,
    required this.onTap,
    this.pending = 0,
    this.frozen = 0,
  });

  final BalanceKind kind;
  final int amount;
  final int pending;
  final int frozen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final amountText = WalletCopy.amountWithUnit(amount, kind.unit);
        final stacked =
            constraints.maxWidth < 340 ||
            !walletAmountFitsInline(
              context,
              amountText,
              constraints.maxWidth,
              weight: FontWeight.bold,
            );
        final value = Text(
          amountText,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        );
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            child: Icon(switch (kind) {
              BalanceKind.credits => Icons.toll,
              BalanceKind.diamonds => Icons.diamond_outlined,
              BalanceKind.cash => Icons.account_balance_wallet_outlined,
            }),
          ),
          title: Text(kind.label),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kind == BalanceKind.diamonds
                    ? WalletCopy.pendingAndFrozen(pending, frozen)
                    : WalletCopy.available,
              ),
              if (stacked) value,
            ],
          ),
          trailing: stacked ? null : value,
          onTap: onTap,
        );
      },
    ),
  );
}
