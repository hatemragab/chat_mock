import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/sheets/business_contact_sheet/business_contact_sheet.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reopen confirmation identifies source and cancel never debits', (
    tester,
  ) async {
    final wallet = WalletController();
    final business = BusinessController(wallet: wallet);
    addTearDown(business.dispose);
    addTearDown(wallet.dispose);
    final story = StoriesController.stories.first;
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    business.advance(const Duration(hours: 25));
    final balance = wallet.credits;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessContactSheet(controller: business, story: story),
        ),
      ),
    );
    await tester.tap(find.text('Message room'));
    await tester.pumpAndSettle();
    expect(find.text('Reopen Maison Studio message room?'), findsOneWidget);
    expect(find.textContaining('Spaces that feel like home'), findsWidgets);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(wallet.credits, balance);
    expect(business.isActive(business.roomFor(story.id)!), isFalse);
  });

  testWidgets('limit dialog identifies the Story and does not charge', (
    tester,
  ) async {
    final wallet = WalletController();
    final business = BusinessController(
      wallet: wallet,
      config: const BusinessConfig(maxOpenings: 1),
    );
    addTearDown(business.dispose);
    addTearDown(wallet.dispose);
    final story = StoriesController.stories.first;
    expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
    business.advance(const Duration(hours: 25));
    final balance = wallet.credits;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusinessContactSheet(controller: business, story: story),
        ),
      ),
    );
    await tester.tap(find.text('Message room'));
    await tester.pumpAndSettle();
    expect(find.text('Interaction limit reached'), findsOneWidget);
    expect(find.textContaining(story.title), findsWidgets);
    expect(wallet.credits, balance);
  });
}
