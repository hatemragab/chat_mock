import 'package:flutter/material.dart';

/// A readable label/value pair for wallet reviews and transaction receipts.
class WalletReceiptField extends StatelessWidget {
  const WalletReceiptField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value),
  );
}
