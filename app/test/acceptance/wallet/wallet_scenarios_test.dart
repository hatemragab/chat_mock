import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/balance_activity_screen/balance_activity_screen.dart';
import 'package:app/features/wallet/ui/screens/buy_credits_screen/buy_credits_screen.dart';
import 'package:app/features/wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_details_screen/withdrawal_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final method in PaymentMethod.values) {
    testWidgets('${method.label} selection carries through mock payment', (
      tester,
    ) async {
      final wallet = WalletController();
      addTearDown(wallet.dispose);
      await tester.pumpWidget(
        MaterialApp(home: BuyCreditsScreen(controller: wallet)),
      );
      await tester.tap(find.text('Payment method'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(method.label).last);
      await tester.pumpAndSettle();
      expect(find.text(method.label), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Mobile Money phone number'),
        '+237600123456',
      );
      await tester.ensureVisible(find.text('Review payment'));
      await tester.tap(find.text('Review payment'));
      await tester.pumpAndSettle();
      expect(find.text(method.label), findsOneWidget);
      expect(find.text('SmobilPay/Maviance'), findsOneWidget);
      await tester.tap(find.text('Continue to provider'));
      await tester.pumpAndSettle();
      expect(wallet.payments.single.method, method);
      expect(wallet.credits, 3000);
      expect(find.text('SmobilPay/Maviance · ${method.label}'), findsOneWidget);
      await tester.tap(find.text('Refresh status'));
      await tester.pump();
      await tester.tap(find.text('Refresh status'));
      await tester.pump();
      expect(wallet.credits, 3100);
      expect(wallet.activity.single.description, contains(method.label));
    });
  }

  testWidgets('balance activity shows empty state per balance and filter', (
    tester,
  ) async {
    final wallet = WalletController(seedActivity: true);
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: BalanceActivityScreen(
          controller: wallet,
          kind: BalanceKind.credits,
        ),
      ),
    );
    expect(find.text('Story Boost'), findsOneWidget);
    await tester.tap(find.text('Received'));
    await tester.pump();
    expect(find.text('No activity for this balance yet.'), findsOneWidget);
    await tester.tap(find.text('Spent'));
    await tester.pump();
    expect(find.text('Story Boost'), findsOneWidget);
    expect(find.text('No activity for this balance yet.'), findsNothing);
  });

  testWidgets('pending and frozen Diamonds cannot be converted', (
    tester,
  ) async {
    final wallet = WalletController()..frozenDiamonds = 25;
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ConvertDiamondsScreen(controller: wallet)),
    );
    expect(find.text('350 available Diamonds'), findsOneWidget);
    expect(find.text('40 pending · 25 frozen'), findsOneWidget);
    expect(
      find.text('Pending or frozen Diamonds cannot be converted.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Diamonds to convert'),
      '351',
    );
    await tester.tap(find.text('Review conversion'));
    await tester.pump();
    expect(
      find.text('Enter an amount within your available balance.'),
      findsOneWidget,
    );
    expect(wallet.diamonds, 350);
    expect(wallet.pendingDiamonds, 40);
    expect(wallet.frozenDiamonds, 25);
    expect(wallet.cash, 1000);
  });

  testWidgets('withdrawal advances through approved and paid once', (
    tester,
  ) async {
    final wallet = WalletController();
    addTearDown(wallet.dispose);
    final withdrawal = wallet.requestWithdrawal(
      id: 'payout-1',
      amount: 1000,
      method: PaymentMethod.orange,
      destination: '+237600123456',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WithdrawalDetailsScreen(
          controller: wallet,
          withdrawal: withdrawal,
        ),
      ),
    );
    expect(wallet.cash, 0);
    await tester.scrollUntilVisible(find.text('Refresh status'), 300);
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Refresh status'), 300);
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    expect(withdrawal.status, WithdrawalStatus.approved);
    expect(withdrawal.events.map((event) => event.status), [
      WithdrawalStatus.pending,
      WithdrawalStatus.inProgress,
      WithdrawalStatus.approved,
    ]);
    expect(wallet.activity.single.status, 'Approved');
    expect(find.text('Approved'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Refresh status'), 300);
    await tester.tap(find.text('Refresh status'));
    await tester.pump();
    expect(withdrawal.status, WithdrawalStatus.paid);
    expect(withdrawal.events.last.status, WithdrawalStatus.paid);
    expect(wallet.activity.single.status, 'Paid');
    expect(find.text('Paid'), findsWidgets);
    expect(wallet.cash, 0);
    expect(find.text('Refresh status'), findsNothing);
    wallet.setWithdrawalStatus(withdrawal.id, WithdrawalStatus.failed);
    expect(wallet.cash, 0);
    expect(withdrawal.events, hasLength(4));
  });

  testWidgets('activity filters fit a narrow screen with enlarged text', (
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: BalanceActivityScreen(
          controller: wallet,
          kind: BalanceKind.credits,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Spent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spent'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Spent'))
          .selected,
      isTrue,
    );
    expect(find.text('Story Boost'), findsOneWidget);
  });
}
