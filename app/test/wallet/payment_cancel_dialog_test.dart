import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/payment_status_screen/payment_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'keep payment preserves the correct pending transaction and balance',
    (tester) async {
      final wallet = WalletController();
      addTearDown(wallet.dispose);
      final payment = wallet.startPayment(
        id: 'test-payment',
        credits: 100,
        method: PaymentMethod.mtn,
        phone: '670000000',
      );
      wallet.setPaymentStatus(payment.id, PaymentStatus.pending);
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentStatusScreen(controller: wallet, payment: payment),
        ),
      );
      await tester.tap(find.text('Cancel payment'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('100 Credits via MTN Mobile Money'),
        findsOneWidget,
      );
      await tester.tap(find.text('Keep payment'));
      await tester.pumpAndSettle();
      expect(payment.status, PaymentStatus.pending);
      expect(wallet.credits, 3000);
    },
  );
}
