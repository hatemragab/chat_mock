import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../copy/wallet_copy.dart';
import '../../../models/wallet_models.dart';
import '../withdrawal_details_screen/withdrawal_details_screen.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key, required this.controller});
  final WalletController controller;
  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  WithdrawalStatus? filter;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(WalletCopy.withdrawalHistory)),
    body: ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final items = widget.controller.withdrawals
            .where((w) => filter == null || w.status == filter)
            .toList();
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final status in <WithdrawalStatus?>[
                    null,
                    WithdrawalStatus.pending,
                    WithdrawalStatus.inProgress,
                    WithdrawalStatus.approved,
                    WithdrawalStatus.paid,
                    WithdrawalStatus.rejected,
                    WithdrawalStatus.failed,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status?.label ?? CommonCopy.all),
                        selected: filter == status,
                        onSelected: (_) => setState(() => filter = status),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text(WalletCopy.noWithdrawals))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final w = items[index];
                        return ListTile(
                          title: Text(
                            WalletCopy.amountWithUnit(w.amount, WalletCopy.xaf),
                          ),
                          subtitle: Text(
                            WalletCopy.statusDetail(
                              w.status.label,
                              w.date.toLocal().toString().substring(0, 10),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => WithdrawalDetailsScreen(
                                controller: widget.controller,
                                withdrawal: w,
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
