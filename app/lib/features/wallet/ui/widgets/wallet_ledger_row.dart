import 'package:flutter/material.dart';

import '../../copy/wallet_copy.dart';
import '../../models/wallet_models.dart';
import '../utils/wallet_amount_layout.dart';

/// A ledger entry used in balance history and related transaction activity.
class WalletLedgerRow extends StatelessWidget {
  const WalletLedgerRow({
    super.key,
    required this.activity,
    this.onTap,
    this.showDate = true,
  });

  final WalletActivity activity;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final value = WalletCopy.signedAmount(
        activity.amount,
        activity.kind.unit,
      );
      final inline = walletAmountFitsInline(
        context,
        value,
        constraints.maxWidth,
      );
      return ListTile(
        title: Text(activity.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WalletCopy.statusDetail(
                activity.status,
                showDate
                    ? activity.date.toLocal().toString().substring(0, 16)
                    : activity.kind.label,
              ),
            ),
            if (!inline) Text(value),
          ],
        ),
        trailing: inline ? Text(value) : null,
        onTap: onTap,
      );
    },
  );
}
