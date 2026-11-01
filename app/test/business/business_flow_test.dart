import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opening a room requires confirmation and sending is free', (
    tester,
  ) async {
    final wallet = WalletController();
    final controller = BusinessController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: BusinessProfileScreen(
          controller: controller,
          story: StoriesController.stories.first,
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('Contact about this Story'), 150);
    await tester.tap(find.text('Contact about this Story'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Message room'));
    await tester.pumpAndSettle();
    expect(find.textContaining('opens a room for 24 hours'), findsOneWidget);
    await tester.tap(find.text('Open room'));
    await tester.pumpAndSettle();
    expect(wallet.credits, 2990);
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(wallet.credits, 2990);
  });
}
