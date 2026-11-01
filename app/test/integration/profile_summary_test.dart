import 'package:app/features/profile/ui/screens/profile_screen/profile_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile balance summary updates from the session wallet', (
    tester,
  ) async {
    final wallet = WalletController();
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          wallet: wallet,
          onWallet: () {},
          onAppearance: () {},
          onSignOut: () {},
          onPrototypeTools: () {},
          onPublishing: () {},
          onSettings: () {},
        ),
      ),
    );
    expect(find.text('3000 Credits · 350 Diamonds · 1000 XAF'), findsOneWidget);
    wallet.spendCredits(
      id: 'profile-test',
      amount: 10,
      description: 'Mock action',
    );
    await tester.pump();
    expect(find.text('2990 Credits · 350 Diamonds · 1000 XAF'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    wallet.dispose();
  });
}
