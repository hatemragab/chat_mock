import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('frequency status follows the mock calendar independently of input', () {
    var now = DateTime(2026, 1, 1, 23, 59);
    final wallet = WalletController(clock: () => now);
    addTearDown(wallet.dispose);
    expect(wallet.withdrawalFrequencyLimitReached, isFalse);
    for (var attempt = 0; attempt < 2; attempt++) {
      final id = 'frequency-$attempt';
      wallet.requestWithdrawal(
        id: id,
        amount: 1000,
        method: PaymentMethod.mtn,
        destination: '+237600123456',
      );
      wallet.setWithdrawalStatus(id, WithdrawalStatus.failed);
    }
    expect(wallet.withdrawalFrequencyLimitReached, isTrue);
    wallet.cash = 0;
    expect(wallet.withdrawalFrequencyLimitReached, isTrue);
    now = now.add(const Duration(minutes: 1));
    expect(wallet.withdrawalFrequencyLimitReached, isFalse);
    wallet.reset();
    expect(wallet.withdrawalFrequencyLimitReached, isFalse);
  });

  group('WalletController', () {
    late WalletController wallet;
    setUp(() => wallet = WalletController(clock: () => DateTime(2026, 1, 1)));
    tearDown(() => wallet.dispose());

    test(
      'pending and failed payments do not credit, confirmation credits once',
      () {
        final payment = wallet.startPayment(
          id: 'one',
          credits: 100,
          method: PaymentMethod.mtn,
          phone: '+237600123456',
        );
        wallet.setPaymentStatus(payment.id, PaymentStatus.pending);
        expect(wallet.credits, 3000);
        wallet.setPaymentStatus(payment.id, PaymentStatus.failed);
        expect(wallet.credits, 3000);
        wallet.setPaymentStatus(payment.id, PaymentStatus.processing);
        wallet.setPaymentStatus(payment.id, PaymentStatus.confirmed);
        wallet.setPaymentStatus(payment.id, PaymentStatus.confirmed);
        expect(wallet.credits, 3100);
        expect(
          wallet.activity.where((entry) => entry.reference == 'one'),
          hasLength(1),
        );
      },
    );
    test('reset does not reuse IDs for new payment attempts', () {
      final oldId = wallet.newId('payment');
      wallet.startPayment(
        id: oldId,
        credits: 100,
        method: PaymentMethod.mtn,
        phone: '+237600123456',
      );
      wallet.reset();
      final newId = wallet.newId('payment');
      final newPayment = wallet.startPayment(
        id: newId,
        credits: 200,
        method: PaymentMethod.mtn,
        phone: '+237600123456',
      );
      expect(newId, isNot(oldId));
      expect(
        () => wallet.setPaymentStatus(oldId, PaymentStatus.confirmed),
        throwsArgumentError,
      );
      expect(newPayment.status, PaymentStatus.processing);
      expect(wallet.credits, 3000);
      wallet.setPaymentStatus(newId, PaymentStatus.confirmed);
      wallet.setPaymentStatus(newId, PaymentStatus.confirmed);
      expect(wallet.credits, 3200);
    });
    test('converts only available diamonds at the reviewed rate once', () {
      expect(
        wallet.convertDiamonds(id: 'a', amount: 351, reviewedRate: 5),
        isFalse,
      );
      expect(
        wallet.convertDiamonds(id: 'a', amount: 10, reviewedRate: 4),
        isFalse,
      );
      expect(
        wallet.convertDiamonds(id: 'a', amount: 10, reviewedRate: 5),
        isTrue,
      );
      expect(
        wallet.convertDiamonds(id: 'a', amount: 10, reviewedRate: 5),
        isTrue,
      );
      expect(wallet.diamonds, 340);
      expect(wallet.pendingDiamonds, 40);
      expect(wallet.cash, 1050);
      expect(wallet.activity, hasLength(2));
    });
    test(
      'withdrawals reserve cash once and rejected payouts recredit once',
      () {
        final withdrawal = wallet.requestWithdrawal(
          id: 'w',
          amount: 1000,
          method: PaymentMethod.orange,
          destination: '+237600123456',
        );
        wallet.requestWithdrawal(
          id: 'w',
          amount: 1000,
          method: PaymentMethod.orange,
          destination: '+237600123456',
        );
        expect(wallet.cash, 0);
        expect(withdrawal.net, 900);
        wallet.setWithdrawalStatus('w', WithdrawalStatus.inProgress);
        wallet.setWithdrawalStatus('w', WithdrawalStatus.rejected);
        wallet.setWithdrawalStatus('w', WithdrawalStatus.rejected);
        wallet.setWithdrawalStatus('w', WithdrawalStatus.failed);
        expect(wallet.cash, 1000);
        expect(wallet.activity, hasLength(2));
        expect(withdrawal.status, WithdrawalStatus.rejected);
      },
    );
    test(
      'withdrawal validates amount, destination, balance and daily limit',
      () {
        expect(
          wallet.withdrawalError(amount: 999, destination: '+237600123456'),
          contains('Minimum'),
        );
        expect(
          wallet.withdrawalError(amount: 1001, destination: '+237600123456'),
          contains('exceeds'),
        );
        expect(
          wallet.withdrawalError(amount: 1000, destination: '12'),
          contains('valid'),
        );
        for (var i = 0; i < 2; i++) {
          wallet.requestWithdrawal(
            id: '$i',
            amount: 1000,
            method: PaymentMethod.mtn,
            destination: '+237600123456',
          );
          wallet.setWithdrawalStatus('$i', WithdrawalStatus.failed);
        }
        expect(
          wallet.withdrawalError(amount: 1000, destination: '+237600123456'),
          contains('limit'),
        );
      },
    );
    test('credit spending is idempotent and fails without funds', () {
      expect(
        wallet.spendCredits(
          id: 'room',
          amount: 10,
          description: 'Business room',
        ),
        isTrue,
      );
      expect(
        wallet.spendCredits(
          id: 'room',
          amount: 10,
          description: 'Business room',
        ),
        isTrue,
      );
      expect(wallet.credits, 2990);
      expect(
        wallet.spendCredits(id: 'big', amount: 3000, description: 'Call'),
        isFalse,
      );
      expect(wallet.credits, 2990);
    });

    test(
      'a changed rate or simulated failure preserves the conversion balance',
      () {
        wallet.setConversionRate(6);
        expect(
          wallet.convertDiamonds(id: 'old', amount: 10, reviewedRate: 5),
          isFalse,
        );
        wallet.setConversionFailure(true);
        expect(
          wallet.convertDiamonds(id: 'retry', amount: 10, reviewedRate: 6),
          isFalse,
        );
        expect(wallet.diamonds, 350);
        expect(wallet.cash, 1000);
        expect(
          wallet.convertDiamonds(id: 'retry', amount: 10, reviewedRate: 6),
          isTrue,
        );
        expect(
          wallet.convertDiamonds(id: 'retry', amount: 10, reviewedRate: 6),
          isTrue,
        );
        expect(wallet.diamonds, 340);
        expect(wallet.cash, 1060);
      },
    );

    test(
      'withdrawal timeline records terminal failures and recredits only once',
      () {
        final withdrawal = wallet.requestWithdrawal(
          id: 'timeline',
          amount: 1000,
          method: PaymentMethod.mtn,
          destination: '+237600123456',
        );
        wallet.setWithdrawalStatus('timeline', WithdrawalStatus.inProgress);
        wallet.setWithdrawalStatus(
          'timeline',
          WithdrawalStatus.failed,
          reason: 'Provider unavailable',
        );
        wallet.setWithdrawalStatus('timeline', WithdrawalStatus.failed);
        expect(withdrawal.events.map((event) => event.status), [
          WithdrawalStatus.pending,
          WithdrawalStatus.inProgress,
          WithdrawalStatus.failed,
        ]);
        expect(withdrawal.events.last.reason, 'Provider unavailable');
        expect(wallet.cash, 1000);
        expect(
          wallet.activity.where(
            (entry) => entry.title == 'Withdrawal returned',
          ),
          hasLength(1),
        );
        expect(
          wallet.activity
              .firstWhere((entry) => entry.title == 'Withdrawal requested')
              .status,
          'Failed',
        );
      },
    );
  });

  test(
    'seeded activity and configured conversion rate are restored on reset',
    () {
      final wallet = WalletController(
        seedActivity: true,
        config: const WalletConfig(xafPerDiamond: 7),
      );
      expect(wallet.activity, hasLength(3));
      wallet.setConversionRate(9);
      wallet.reset();
      expect(wallet.activity, hasLength(3));
      expect(wallet.conversionRate, 7);
      expect(wallet.credits, 3000);
      wallet.dispose();
    },
  );
}
