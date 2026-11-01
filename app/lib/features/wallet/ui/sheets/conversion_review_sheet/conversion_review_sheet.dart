import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/wallet_copy.dart';

class ConversionReviewSheet extends StatelessWidget {
  const ConversionReviewSheet({
    super.key,
    required this.diamonds,
    required this.rate,
  });
  final int diamonds;
  final int rate;
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
            WalletCopy.reviewConversion,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(WalletCopy.conversionCalculation(diamonds, rate)),
          const SizedBox(height: 8),
          Text(
            WalletCopy.cashReceived(diamonds * rate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(WalletCopy.confirmConversion),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(CommonCopy.cancel),
          ),
        ],
      ),
    ),
  );
}
