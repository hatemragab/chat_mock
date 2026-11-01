import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../sheets/conversion_review_sheet/conversion_review_sheet.dart';

class ConvertDiamondsScreen extends StatefulWidget {
  const ConvertDiamondsScreen({
    super.key,
    required this.controller,
    this.initialAmount,
    this.openReviewOnStart = false,
  });
  final WalletController controller;
  final int? initialAmount;
  final bool openReviewOnStart;
  @override
  State<ConvertDiamondsScreen> createState() => _ConvertDiamondsScreenState();
}

class _ConvertDiamondsScreenState extends State<ConvertDiamondsScreen> {
  late final amount = TextEditingController(
    text: widget.initialAmount?.toString(),
  );
  String? error;
  bool reviewing = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.openReviewOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reviewConversion();
      });
    }
  }

  Future<void> _reviewConversion() async {
    final value = int.tryParse(amount.text) ?? 0;
    if (reviewing || submitting) return;
    if (value <= 0 || value > widget.controller.diamonds) {
      setState(() => error = WalletCopy.amountWithinBalance);
      return;
    }
    setState(() => reviewing = true);
    final rate = widget.controller.conversionRate;
    final conversionId = widget.controller.newId('conversion');
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => ConversionReviewSheet(diamonds: value, rate: rate),
    );
    if (!mounted) return;
    setState(() => reviewing = false);
    if (confirmed != true) return;
    setState(() {
      submitting = true;
      error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final success = widget.controller.convertDiamonds(
      id: conversionId,
      amount: value,
      reviewedRate: rate,
    );
    setState(() => submitting = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WalletCopy.conversionSucceeded)),
      );
      Navigator.pop(context);
    } else {
      setState(
        () => error = rate != widget.controller.conversionRate
            ? WalletCopy.rateChanged
            : WalletCopy.conversionFailed,
      );
    }
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.convertDiamonds)),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final value = int.tryParse(amount.text) ?? 0;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              WalletCopy.availableDiamonds(widget.controller.diamonds),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              WalletCopy.pendingAndFrozen(
                widget.controller.pendingDiamonds,
                widget.controller.frozenDiamonds,
              ),
            ),
            const SizedBox(height: 12),
            const Text(WalletCopy.unavailableDiamondsExplanation),
            const SizedBox(height: 20),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => error = null),
              decoration: InputDecoration(
                labelText: WalletCopy.diamondsToConvert,
                border: const OutlineInputBorder(),
                errorText: error,
              ),
            ),
            const SizedBox(height: 12),
            Text(WalletCopy.conversionRate(widget.controller.conversionRate)),
            Text(
              WalletCopy.cashReceived(value * widget.controller.conversionRate),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: reviewing || submitting ? null : _reviewConversion,
              child: Text(
                submitting
                    ? WalletCopy.submitting
                    : WalletCopy.reviewConversion,
              ),
            ),
          ],
        );
      },
    ),
  );
}
