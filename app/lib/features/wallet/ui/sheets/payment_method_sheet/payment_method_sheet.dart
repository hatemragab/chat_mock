import 'package:flutter/material.dart';

import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';

class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key, required this.selected});
  final PaymentMethod selected;
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
            WalletCopy.paymentMethod,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(WalletCopy.secureSimulatedPayment),
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
