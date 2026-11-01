import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/payment_review_screen/payment_review_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_review_screen/withdrawal_review_screen.dart';
import 'package:app/features/wallet/ui/screens/wallet_screen/wallet_screen.dart';
import 'package:app/features/wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import 'package:app/features/wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reentrant withdrawal confirmation reserves cash once', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: WithdrawalReviewScreen(
          controller: wallet,
          amount: 1000,
          method: PaymentMethod.mtn,
          destination: '+237600123456',
        ),
      ),
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirm withdrawal'),
    );
    wallet.addListener(() => button.onPressed!());
    await tester.tap(find.text('Confirm withdrawal'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(wallet.withdrawals, hasLength(1));
    expect(wallet.cash, 0);
    expect(wallet.activity, hasLength(1));
  });
  testWidgets('cancelled payment can be started again as a new mock attempt', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentReviewScreen(
          controller: wallet,
          credits: 100,
          method: PaymentMethod.mtn,
          phone: '+237600123456',
        ),
      ),
    );
    await tester.tap(find.text('Continue to provider'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel payment').last);
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to provider'));
    await tester.pumpAndSettle();
    expect(find.text('Processing'), findsOneWidget);
    expect(wallet.payments, hasLength(2));
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    expect(wallet.credits, 3100);
  });
  testWidgets('buy Credits remains uncredited until confirmation', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(home: WalletScreen(controller: wallet)),
    );
    await tester.tap(find.text('Buy Credits'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Mobile Money phone number'),
      '+237600123456',
    );
    await tester.tap(find.text('Review payment'));
    await tester.pumpAndSettle();
    expect(find.text('SmobilPay/Maviance'), findsOneWidget);
    await tester.tap(find.text('Continue to provider'));
    await tester.pumpAndSettle();
    expect(wallet.credits, 3000);
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    expect(wallet.credits, 3000);
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    expect(wallet.credits, 3100);
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('confirmed top-up returns to its interrupted review', (
    tester,
  ) async {
    final wallet = WalletController()..credits = 0;
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => InsufficientCreditsSheet(
                  controller: wallet,
                  requiredCredits: 10,
                ),
              ),
              child: const Text('Interrupted review'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Interrupted review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy Credits'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Mobile Money phone number'),
      '+237600123456',
    );
    await tester.ensureVisible(find.text('Review payment'));
    await tester.tap(find.text('Review payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to provider'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Interrupted review'), findsOneWidget);
    expect(find.text('Buy Credits'), findsNothing);
    expect(wallet.credits, 100);
  });

  for (final useSystemBack in [false, true]) {
    testWidgets(
      'confirmed top-up returns to the interrupted review on ${useSystemBack ? 'system' : 'app-bar'} back',
      (tester) async {
        final wallet = WalletController()..credits = 0;
        addTearDown(wallet.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => InsufficientCreditsSheet(
                      controller: wallet,
                      requiredCredits: 10,
                    ),
                  ),
                  child: const Text('Interrupted review'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Interrupted review'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buy Credits'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Mobile Money phone number'),
          '+237600123456',
        );
        await tester.ensureVisible(find.text('Review payment'));
        await tester.tap(find.text('Review payment'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue to provider'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Refresh status'));
        await tester.pump();
        await tester.tap(find.text('Refresh status'));
        await tester.pump();
        expect(wallet.credits, 100);
        expect(find.text('Confirmed'), findsOneWidget);
        if (useSystemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byTooltip('Back'));
        }
        await tester.pumpAndSettle();
        expect(find.text('Interrupted review'), findsOneWidget);
        expect(find.text('Review payment'), findsNothing);
        expect(wallet.payments, hasLength(1));
        expect(wallet.credits, 100);
      },
    );
  }

  testWidgets(
    'conversion retains input after rate changes and allows review again',
    (tester) async {
      final wallet = WalletController();
      addTearDown(wallet.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ConvertDiamondsScreen(controller: wallet)),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Diamonds to convert'),
        '10',
      );
      await tester.pump();
      await tester.tap(find.text('Review conversion'));
      await tester.pumpAndSettle();
      wallet.setConversionRate(6);
      await tester.pump();
      await tester.tap(find.text('Confirm conversion'));
      await tester.pump();
      expect(find.text('Submitting…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('conversion rate changed'), findsOneWidget);
      expect(wallet.diamonds, 350);
      expect(find.text('10'), findsWidgets);
      await tester.tap(find.text('Review conversion'));
      await tester.pumpAndSettle();
      expect(find.text('You receive 60 XAF'), findsWidgets);
    },
  );

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('wallet remains usable on a 320-wide $brightness layout', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final wallet = WalletController(seedActivity: true);
      addTearDown(wallet.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: WalletScreen(controller: wallet),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Withdraw Cash'), 200);
      await tester.tap(find.text('Withdraw Cash'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
