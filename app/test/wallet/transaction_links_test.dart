import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/transaction_details_screen/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('conversion links Diamond and Cash ledger entries', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    expect(
      wallet.convertDiamonds(id: 'conversion', amount: 10, reviewedRate: 5),
      isTrue,
    );
    final diamond = wallet.activity.firstWhere(
      (entry) => entry.kind == BalanceKind.diamonds,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailsScreen(activity: diamond, controller: wallet),
      ),
    );
    await tester.scrollUntilVisible(find.text('Diamond conversion'), 200);
    expect(find.text('Related activity'), findsOneWidget);
    await tester.tap(find.text('Diamond conversion'));
    await tester.pumpAndSettle();
    expect(find.text('+50 XAF'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    expect(find.text('-10 Diamonds'), findsOneWidget);
  });

  testWidgets('withdrawal receipt links tracking and reflects recredit', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    final withdrawal = wallet.requestWithdrawal(
      id: 'withdrawal',
      amount: 1000,
      method: PaymentMethod.orange,
      destination: '+237600123456',
    );
    final receipt = wallet.activity.single;
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailsScreen(activity: receipt, controller: wallet),
      ),
    );
    await tester.scrollUntilVisible(find.text('View withdrawal'), 200);
    await tester.tap(find.text('View withdrawal'));
    await tester.pumpAndSettle();
    expect(find.text('Withdrawal details'), findsOneWidget);
    wallet.setWithdrawalStatus(withdrawal.id, WithdrawalStatus.failed);
    await tester.pump();
    expect(wallet.cash, 1000);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Failed'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Withdrawal returned'), 200);
    await tester.tap(find.text('Withdrawal returned'));
    await tester.pumpAndSettle();
    expect(find.text('+1000 XAF'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
  });

  testWidgets('confirmed purchase receipt links to its payment status', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    final payment = wallet.startPayment(
      id: 'payment',
      credits: 100,
      method: PaymentMethod.mtn,
      phone: '+237600123456',
    );
    wallet.setPaymentStatus(payment.id, PaymentStatus.confirmed);
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailsScreen(
          activity: wallet.activity.single,
          controller: wallet,
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('View payment'), 200);
    await tester.tap(find.text('View payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment status'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(wallet.credits, 3100);
    expect(wallet.activity, hasLength(1));
  });
}
