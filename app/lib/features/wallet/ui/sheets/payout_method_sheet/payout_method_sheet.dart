import 'package:flutter/material.dart';

import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';

class PayoutMethodSheet extends StatelessWidget {
  const PayoutMethodSheet({
    super.key,
    required this.selected,
    required this.fee,
  });
  final PaymentMethod selected;
  final int fee;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WalletCopy.payoutMethod,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(WalletCopy.payoutFee(fee)),
          for (final method in PaymentMethod.values)
            ListTile(
              title: Text(method.label),
              trailing: selected == method
                  ? const Icon(Icons.check_circle)
                  : null,
              onTap: () => Navigator.pop(context, method),
            ),
        ],
      ),
    ),
  );
}
