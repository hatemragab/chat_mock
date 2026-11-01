import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallet ledger preserves typed purposes through payout tracking', () {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    final payout = wallet.requestWithdrawal(
      id: 'payout',
      amount: 1000,
      method: PaymentMethod.orange,
      destination: '+12025550199',
    );
    final reserved = wallet.activity.single;
    expect(reserved.purpose, WalletActivityPurpose.withdrawalReservation);
    wallet.setWithdrawalStatus(payout.id, WithdrawalStatus.inProgress);
    wallet.setWithdrawalStatus(payout.id, WithdrawalStatus.rejected);
    wallet.setWithdrawalStatus(payout.id, WithdrawalStatus.failed);
    final reservations = wallet.activity.where(
      (entry) => entry.purpose == WalletActivityPurpose.withdrawalReservation,
    );
    final returns = wallet.activity.where(
      (entry) => entry.purpose == WalletActivityPurpose.withdrawalReturn,
    );
    expect(reservations, hasLength(1));
    expect(reservations.single.id, reserved.id);
    expect(reservations.single.status, WithdrawalStatus.rejected.label);
    expect(returns, hasLength(1));
    expect(returns.single.amount, 1000);
    expect(wallet.cash, 1000);
  });

  test(
    'purchase, spend, reward and paired conversion use distinct purposes',
    () {
      final wallet = WalletController();
      addTearDown(wallet.dispose);
      final payment = wallet.startPayment(
        id: 'purchase',
        credits: 100,
        method: PaymentMethod.mtn,
        phone: '+12025550199',
      );
      wallet.setPaymentStatus(payment.id, PaymentStatus.confirmed);
      wallet.spendCredits(
        id: 'spend',
        amount: 10,
        description: 'Customer chosen action',
      );
      wallet.addPendingPromotionReward(id: 'reward', amount: 5);
      wallet.convertDiamonds(id: 'conversion', amount: 10, reviewedRate: 5);
      expect(wallet.activity.map((entry) => entry.purpose).toSet(), {
        WalletActivityPurpose.creditPurchase,
        WalletActivityPurpose.creditSpend,
        WalletActivityPurpose.promotionReward,
        WalletActivityPurpose.conversionDebit,
        WalletActivityPurpose.conversionCredit,
      });
      final conversion = wallet.activity.where(
        (entry) => entry.reference == 'conversion',
      );
      expect(
        conversion
            .singleWhere(
              (entry) => entry.purpose == WalletActivityPurpose.conversionDebit,
            )
            .kind,
        BalanceKind.diamonds,
      );
      expect(
        conversion
            .singleWhere(
              (entry) =>
                  entry.purpose == WalletActivityPurpose.conversionCredit,
            )
            .kind,
        BalanceKind.cash,
      );
      final legacy = WalletActivity(
        id: 'legacy',
        kind: BalanceKind.cash,
        amount: 1,
        title: 'Legacy entry',
        reference: 'ref',
        date: DateTime(2026),
        status: 'Complete',
        description: 'Legacy constructor',
      );
      expect(legacy.purpose, WalletActivityPurpose.other);
    },
  );
}
