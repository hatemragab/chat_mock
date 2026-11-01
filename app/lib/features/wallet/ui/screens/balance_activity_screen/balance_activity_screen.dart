import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../../widgets/wallet_ledger_row.dart';
import '../transaction_details_screen/transaction_details_screen.dart';

enum _ActivityFilter { all, received, spent }

extension on _ActivityFilter {
  String get label => switch (this) {
    _ActivityFilter.all => CommonCopy.all,
    _ActivityFilter.received => WalletCopy.received,
    _ActivityFilter.spent => WalletCopy.spent,
  };
}

class BalanceActivityScreen extends StatefulWidget {
  const BalanceActivityScreen({
    super.key,
    required this.controller,
    required this.kind,
  });
  final WalletController controller;
  final BalanceKind kind;
  @override
  State<BalanceActivityScreen> createState() => _BalanceActivityScreenState();
}

class _BalanceActivityScreenState extends State<BalanceActivityScreen> {
  _ActivityFilter filter = _ActivityFilter.all;
  int visible = 10;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: Text(WalletCopy.activityTitle(widget.kind.label))),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final entries = widget.controller.activity
            .where(
              (a) =>
                  a.kind == widget.kind &&
                  switch (filter) {
                    _ActivityFilter.all => true,
                    _ActivityFilter.received => a.amount > 0,
                    _ActivityFilter.spent => a.amount < 0,
                  },
            )
            .toList();
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  for (final option in _ActivityFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(option.label),
                        selected: filter == option,
                        onSelected: (_) => setState(() {
                          filter = option;
                          visible = 10;
                        }),
                      ),
                    ),
                ],
              ),
            ),
            if (entries.isEmpty)
              const Expanded(
                child: Center(child: Text(WalletCopy.noBalanceActivity)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length > visible
                      ? visible + 1
                      : entries.length,
                  itemBuilder: (context, index) {
                    if (index == visible) {
                      return TextButton(
                        onPressed: () => setState(() => visible += 10),
                        child: const Text(WalletCopy.loadMore),
                      );
                    }
                    final a = entries[index];
                    return WalletLedgerRow(
                      activity: a,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => TransactionDetailsScreen(
                            activity: a,
                            controller: widget.controller,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}
