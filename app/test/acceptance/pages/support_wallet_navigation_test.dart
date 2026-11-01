import 'package:app/features/support/ui/screens/about_screen/about_screen.dart';
import 'package:app/features/support/ui/screens/help_screen/help_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/ui/screens/wallet_screen/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'help search opens the selected article and retains the query on return',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
      await tester.enterText(find.byType(TextField), 'wallet');
      await tester.pumpAndSettle();
      expect(find.text('Wallet and Credits'), findsOneWidget);
      expect(find.text('Privacy and blocking'), findsNothing);
      await tester.tap(find.text('Wallet and Credits'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Diamonds are rewards'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('wallet'), findsOneWidget);
      expect(find.text('Wallet and Credits'), findsOneWidget);
      expect(find.text('Privacy and blocking'), findsNothing);
      await tester.enterText(find.byType(TextField), 'unmatched topic');
      await tester.pumpAndSettle();
      expect(find.text('No help articles match your search.'), findsOneWidget);
    },
  );

  testWidgets('about opens the correct legal document and returns to about', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(find.text('Using Whizpee'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Your privacy'), findsOneWidget);
    expect(find.text('Using Whizpee'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Prototype · Version 1.0'), findsOneWidget);
  });

  testWidgets(
    'wallet activity keeps balance and selected transaction context on return',
    (tester) async {
      final wallet = WalletController(seedActivity: true);
      addTearDown(wallet.dispose);
      await tester.pumpWidget(
        MaterialApp(home: WalletScreen(controller: wallet)),
      );
      await tester.tap(find.text('Credits').first);
      await tester.pumpAndSettle();
      expect(find.text('Story Boost'), findsOneWidget);
      expect(find.text('Promotion reward'), findsNothing);
      await tester.tap(find.text('Spent'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Story Boost'));
      await tester.pumpAndSettle();
      expect(find.text('-50 Credits'), findsOneWidget);
      expect(find.text('seed-publication'), findsOneWidget);
      expect(find.text('Boosted a Status.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Spent'))
            .selected,
        isTrue,
      );
      expect(find.text('Story Boost'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diamonds').first);
      await tester.pumpAndSettle();
      expect(find.text('Promotion reward'), findsOneWidget);
      expect(find.text('Story Boost'), findsNothing);
    },
  );
}
