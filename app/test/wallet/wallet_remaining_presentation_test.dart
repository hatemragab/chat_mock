import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/dialogs/cancel_payment_dialog/cancel_payment_dialog.dart';
import 'package:app/features/wallet/ui/screens/balance_activity_screen/balance_activity_screen.dart';
import 'package:app/features/wallet/ui/screens/transaction_details_screen/transaction_details_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_details_screen/withdrawal_details_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_form_screen/withdrawal_form_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_history_screen/withdrawal_history_screen.dart';
import 'package:app/features/wallet/ui/screens/wallet_screen/wallet_screen.dart';
import 'package:app/features/wallet/ui/sheets/conversion_review_sheet/conversion_review_sheet.dart';
import 'package:app/features/wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import 'package:app/features/wallet/ui/sheets/payout_method_sheet/payout_method_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _reachable(
  WidgetTester tester,
  Finder target,
  double bottom,
) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  expect(tester.getBottomRight(target).dy, lessThanOrEqualTo(bottom));
  expect(tester.takeException(), isNull);
}

Widget _app(Widget screen, Brightness brightness, {bool keyboard = false}) =>
    MaterialApp(
      theme: AppTheme.create(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.3),
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
          viewInsets: EdgeInsets.only(bottom: keyboard ? 200 : 0),
        ),
        child: child!,
      ),
      home: screen,
    );

void main() {
  testWidgets(
    'withdrawal form explains and enforces the configured daily limit',
    (tester) async {
      final wallet = WalletController(
        config: const WalletConfig(withdrawalsPerDay: 1),
      )..cash = 2000;
      addTearDown(wallet.dispose);
      wallet.requestWithdrawal(
        id: 'already-submitted',
        amount: 1000,
        method: PaymentMethod.mtn,
        destination: '+12025550199',
      );
      await tester.pumpWidget(
        _app(
          WithdrawalFormScreen(
            controller: wallet,
            initialAmount: 1000,
            initialDestination: '+12025550199',
          ),
          Brightness.light,
        ),
      );
      expect(find.text('Up to 1 withdrawal per day.'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Review withdrawal'),
        120,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(find.text('Review withdrawal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review withdrawal'));
      await tester.pump();
      expect(find.text('Daily withdrawal limit reached.'), findsOneWidget);
      expect(wallet.withdrawals, hasLength(1));
      expect(wallet.cash, 1000);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'large balances and ledger amounts stay readable at $size, ${brightness.name}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController()..credits = 1234567890123;
          addTearDown(wallet.dispose);
          wallet.spendCredits(
            id: 'large',
            amount: 123456789012,
            description: 'Large mock action',
          );
          await tester.pumpWidget(
            _app(WalletScreen(controller: wallet), brightness),
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Credits'));
          await tester.pumpAndSettle();
          expect(find.text('-123456789012 Credits'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Large mock action'));
          await tester.pumpAndSettle();
          expect(find.byType(TransactionDetailsScreen), findsOneWidget);
          expect(find.text('-123456789012 Credits'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
      for (final overlay in [
        'conversion',
        'insufficient',
        'payout',
        'cancel payment',
      ]) {
        testWidgets(
          '$overlay overlay at $size, ${brightness.name}, keyboard and enlarged text',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final wallet = WalletController()..credits = 9;
            addTearDown(wallet.dispose);
            final payment = wallet.startPayment(
              id: 'pending-purchase',
              credits: 100,
              method: PaymentMethod.orange,
              phone: '+12025550199',
            );
            Object? result;
            await tester.pumpWidget(
              _app(
                Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () async {
                        result = overlay == 'cancel payment'
                            ? await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    CancelPaymentDialog(payment: payment),
                              )
                            : await showModalBottomSheet<Object>(
                                context: context,
                                builder: (_) => switch (overlay) {
                                  'conversion' => const ConversionReviewSheet(
                                    diamonds: 350,
                                    rate: 5,
                                  ),
                                  'insufficient' => InsufficientCreditsSheet(
                                    controller: wallet,
                                    requiredCredits: 155,
                                  ),
                                  _ => const PayoutMethodSheet(
                                    selected: PaymentMethod.mtn,
                                    fee: 100,
                                  ),
                                },
                              );
                      },
                      child: const Text('Open overlay'),
                    ),
                  ),
                ),
                brightness,
                keyboard: true,
              ),
            );
            await tester.tap(find.text('Open overlay'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final action = switch (overlay) {
              'conversion' => find.text('Confirm conversion'),
              'insufficient' => find.text('Cancel'),
              'payout' => find.text('Orange Mobile Money'),
              _ => find.text('Keep payment'),
            };
            await _reachable(tester, action, size.height - 200);
            await tester.tap(action);
            await tester.pumpAndSettle();
            if (overlay == 'conversion') expect(result, isTrue);
            if (overlay == 'payout') expect(result, PaymentMethod.orange);
            if (overlay == 'cancel payment') expect(result, isFalse);
            expect(wallet.credits, 9);
            expect(wallet.cash, 1000);
            expect(payment.status, PaymentStatus.processing);
            expect(find.text('Open overlay'), findsOneWidget);
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }

      testWidgets(
        'ledger pagination, filters and receipts at $size, ${brightness.name}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController();
          addTearDown(wallet.dispose);
          for (var i = 0; i < 12; i++) {
            wallet.spendCredits(
              id: 'spend-$i',
              amount: 10,
              description: 'Ledger entry $i',
            );
          }
          await tester.pumpWidget(
            _app(
              BalanceActivityScreen(
                controller: wallet,
                kind: BalanceKind.credits,
              ),
              brightness,
            ),
          );
          await tester.scrollUntilVisible(
            find.text('Load more'),
            160,
            scrollable: find
                .descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await _reachable(tester, find.text('Load more'), size.height - 16);
          await tester.tap(find.text('Load more'));
          await tester.pump();
          await tester.scrollUntilVisible(
            find.text('Ledger entry 0'),
            120,
            scrollable: find
                .descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await _reachable(
            tester,
            find.text('Ledger entry 0'),
            size.height - 16,
          );
          await tester.tap(find.text('Ledger entry 0'));
          await tester.pumpAndSettle();
          expect(find.byType(TransactionDetailsScreen), findsOneWidget);
          expect(find.text('-10 Credits'), findsOneWidget);
          expect(find.text('Spent'), findsOneWidget);
          await tester.scrollUntilVisible(find.text('spend-0'), 120);
          expect(find.text('spend-0'), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Received'));
          await tester.tap(find.text('Received'));
          await tester.pump();
          expect(
            find.text('No activity for this balance yet.'),
            findsOneWidget,
          );
          expect(wallet.credits, 2880);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        'history tracks rejection and links its recredit at $size, ${brightness.name}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController();
          addTearDown(wallet.dispose);
          final request = wallet.requestWithdrawal(
            id: 'payout',
            amount: 1000,
            method: PaymentMethod.orange,
            destination: '+12025550199',
          );
          await tester.pumpWidget(
            _app(WithdrawalHistoryScreen(controller: wallet), brightness),
          );
          await tester.tap(find.text('1000 XAF'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(find.text('Refresh status'), 160);
          await tester.tap(find.text('Refresh status'));
          await tester.pump();
          expect(request.status, WithdrawalStatus.inProgress);
          wallet.setWithdrawalStatus(
            request.id,
            WithdrawalStatus.rejected,
            reason: 'Mock destination check rejected',
          );
          await tester.pump();
          await tester.scrollUntilVisible(
            find.text('The reserved Cash was returned to your balance.'),
            140,
          );
          expect(
            find.text('The reserved Cash was returned to your balance.'),
            findsOneWidget,
          );
          expect(wallet.cash, 1000);
          wallet.setWithdrawalStatus(request.id, WithdrawalStatus.failed);
          expect(wallet.cash, 1000);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Rejected'));
          await tester.tap(find.text('Rejected'));
          await tester.pump();
          expect(
            find.text(
              'Rejected · ${request.date.toLocal().toString().substring(0, 10)}',
            ),
            findsOneWidget,
          );
          await tester.tap(find.text('1000 XAF'));
          await tester.pumpAndSettle();
          expect(find.byType(WithdrawalDetailsScreen), findsOneWidget);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            _app(
              TransactionDetailsScreen(
                activity: wallet.activity.firstWhere(
                  (entry) => entry.title == 'Withdrawal returned',
                ),
                controller: wallet,
              ),
              brightness,
            ),
          );
          expect(find.text('+1000 XAF'), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('Withdrawal requested'),
            160,
          );
          await _reachable(
            tester,
            find.text('Withdrawal requested'),
            size.height - 16,
          );
          await tester.tap(find.text('Withdrawal requested'));
          await tester.pumpAndSettle();
          expect(find.text('-1000 XAF'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
