import 'package:app/features/prototype_tools/ui/widgets/wallet_review_controls.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'review controls update conversion rate and simulate a retryable failure',
    (tester) async {
      final wallet = WalletController();
      addTearDown(wallet.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: wallet,
              builder: (_, _) =>
                  ListView(children: [WalletReviewControls(wallet: wallet)]),
            ),
          ),
        ),
      );
      final reviewedRate = wallet.conversionRate;
      await tester.tap(find.text('Increase rate by 1 XAF'));
      await tester.pump();
      expect(wallet.conversionRate, reviewedRate + 1);
      expect(
        wallet.convertDiamonds(
          id: 'conversion',
          amount: 10,
          reviewedRate: reviewedRate,
        ),
        isFalse,
      );
      expect(wallet.diamonds, 350);
      await tester.tap(find.text('Fail next conversion'));
      await tester.pump();
      expect(wallet.failNextConversion, isTrue);
      expect(
        wallet.convertDiamonds(
          id: 'conversion',
          amount: 10,
          reviewedRate: wallet.conversionRate,
        ),
        isFalse,
      );
      expect(wallet.failNextConversion, isFalse);
      expect(wallet.diamonds, 350);
      expect(
        wallet.convertDiamonds(
          id: 'conversion',
          amount: 10,
          reviewedRate: wallet.conversionRate,
        ),
        isTrue,
      );
      expect(
        wallet.convertDiamonds(
          id: 'conversion',
          amount: 10,
          reviewedRate: wallet.conversionRate,
        ),
        isTrue,
      );
      expect(wallet.diamonds, 340);
      expect(wallet.cash, 1060);
      await tester.pump();
      await tester.tap(find.text('Restore default rate'));
      await tester.pump();
      expect(wallet.conversionRate, reviewedRate);
    },
  );
}
