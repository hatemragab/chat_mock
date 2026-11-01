import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/wallet_screen/wallet_screen.dart';
import 'package:app/features/wallet/ui/screens/payment_review_screen/payment_review_screen.dart';
import 'package:app/features/wallet/ui/screens/payment_status_screen/payment_status_screen.dart';
import 'package:app/features/wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_review_screen/withdrawal_review_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_details_screen/withdrawal_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> reach(WidgetTester tester, String text, double bottom) async {
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(text),
    120,
    scrollable: find
        .descendant(
          of: find.byType(ListView).first,
          matching: find.byType(Scrollable),
        )
        .first,
  );
  final target = find.text(text).last;
  await Scrollable.ensureVisible(tester.element(target), alignment: .5);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  expect(tester.getBottomRight(target).dy, lessThanOrEqualTo(bottom));
  expect(tester.takeException(), isNull);
}

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      for (final scenario in [
        'balances',
        'payment review',
        'conversion',
        'withdrawal review',
        'Business profile',
        'report',
      ]) {
        testWidgets('$scenario at $size, ${brightness.name}, enlarged text', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController();
          final chats = ChatsController();
          final settings = SettingsController(chats: chats);
          final keyboard =
              scenario == 'conversion' ||
              scenario == 'Business profile' ||
              scenario == 'report';
          final screen = switch (scenario) {
            'balances' => WalletScreen(controller: wallet),
            'payment review' => PaymentReviewScreen(
              controller: wallet,
              credits: 100,
              method: PaymentMethod.orange,
              phone: '+1 (202) 555-0199',
            ),
            'conversion' => ConvertDiamondsScreen(controller: wallet),
            'withdrawal review' => WithdrawalReviewScreen(
              controller: wallet,
              amount: 1000,
              method: PaymentMethod.orange,
              destination: '+1 (202) 555-0199',
            ),
            'Business profile' => EditBusinessProfileScreen(
              controller: settings,
            ),
            _ => const ReportScreen(
              target: 'Maison Studio Story',
              targetId: 'maison',
            ),
          };
          await tester.pumpWidget(
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
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: scenario);
          final bottom = size.height - (keyboard ? 200 : 16);
          switch (scenario) {
            case 'balances':
              await reach(tester, 'Convert Diamonds', bottom);
              await tester.tap(find.text('Convert Diamonds'));
              await tester.pumpAndSettle();
              expect(find.byType(ConvertDiamondsScreen), findsOneWidget);
            case 'payment review':
              await reach(tester, 'Continue to provider', bottom);
              await tester.tap(find.text('Continue to provider'));
              await tester.pumpAndSettle();
              expect(find.byType(PaymentStatusScreen), findsOneWidget);
              await reach(tester, 'Refresh status', bottom);
              await tester.tap(find.text('Refresh status'));
              await tester.pump();
              expect(wallet.payments.single.status, PaymentStatus.pending);
              expect(wallet.credits, 3000);
            case 'conversion':
              await tester.enterText(
                find.widgetWithText(TextField, 'Diamonds to convert'),
                '999',
              );
              await reach(tester, 'Review conversion', bottom);
              await tester.tap(find.text('Review conversion'));
              await tester.pump();
              expect(
                find.text('Enter an amount within your available balance.'),
                findsOneWidget,
              );
              expect(wallet.diamonds, 350);
            case 'withdrawal review':
              await reach(tester, 'Confirm withdrawal', bottom);
              await tester.tap(find.text('Confirm withdrawal'));
              await tester.pumpAndSettle();
              expect(find.byType(WithdrawalDetailsScreen), findsOneWidget);
              expect(wallet.cash, 0);
              await reach(tester, 'Refresh status', bottom);
              await tester.tap(find.text('Refresh status'));
              await tester.pump();
              expect(
                wallet.withdrawals.single.status,
                WithdrawalStatus.inProgress,
              );
            case 'Business profile':
              await reach(tester, 'Save', bottom);
              await tester.tap(find.text('Save'));
              await tester.pump();
              await tester.scrollUntilVisible(
                find.text('Enter a Business name.'),
                -120,
                scrollable: find
                    .descendant(
                      of: find.byType(ListView).first,
                      matching: find.byType(Scrollable),
                    )
                    .first,
              );
              expect(find.text('Enter a Business name.'), findsOneWidget);
              expect(settings.businessProfile.isComplete, isFalse);
            case 'report':
              await tester.ensureVisible(find.text('Spam'));
              await tester.tap(find.text('Spam'));
              await tester.pump();
              await reach(tester, 'Submit report', bottom);
              await tester.tap(find.text('Submit report'));
              await tester.pump(const Duration(milliseconds: 350));
              await tester.pump();
              expect(find.text('Report submitted'), findsOneWidget);
          }
          expect(tester.takeException(), isNull, reason: scenario);
          await tester.pumpWidget(const SizedBox.shrink());
          settings.dispose();
          chats.dispose();
          wallet.dispose();
        });
      }
    }
  }
}
