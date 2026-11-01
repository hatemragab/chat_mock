import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/widgets/mention_suggestions.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/prototype_tools/controllers/review_actions.dart';
import 'package:app/features/prototype_tools/ui/screens/review_catalog_screen/review_catalog_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Fixture {
  final wallet = WalletController();
  final chats = ChatsController();
  final stories = StoriesController();
  late final calls = CallsController(spendCredits: (_, _, _) => true);
  late final group = GroupController(chats: chats);
  late final business = BusinessController(wallet: wallet);
  late final publishing = PublishingController(wallet: wallet);
  late final actions = ReviewActions(
    chats: chats,
    calls: calls,
    group: group,
    business: business,
    publishing: publishing,
    stories: stories,
    wallet: wallet,
  );
  void dispose() {
    calls.dispose();
    group.dispose();
    business.dispose();
    publishing.dispose();
    stories.dispose();
    chats.dispose();
    wallet.dispose();
  }
}

void main() {
  test('transaction scenarios become available only for matching real session data', () {
    final f = Fixture();
    addTearDown(f.dispose);
    expect(f.actions.canOpen('P59'), isFalse);
    expect(f.actions.canOpen('V097'), isFalse);
    final payment = f.wallet.startPayment(
      id: 'test-payment',
      credits: 20,
      method: PaymentMethod.mtn,
      phone: '+237670000000',
    );
    expect(f.actions.canOpen('P59'), isTrue);
    expect(f.actions.canOpen('V097'), isTrue);
    expect(f.actions.canOpen('V098'), isFalse);
    f.wallet.setPaymentStatus(payment.id, PaymentStatus.pending);
    expect(f.actions.canOpen('V097'), isFalse);
    expect(f.actions.canOpen('V098'), isTrue);
    expect(f.wallet.credits, 3000);
  });

  testWidgets(
    'mention scenario opens the real composer with eligible suggestions',
    (tester) async {
      final f = Fixture();
      addTearDown(f.dispose);
      await tester.pumpWidget(
        MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
      );
      await tester.enterText(find.byType(TextField), 'V033');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mention suggestions'));
      await tester.pumpAndSettle();
      expect(find.byType(MentionSuggestions), findsOneWidget);
      expect(find.text('Sarah Wilson'), findsOneWidget);
    },
  );

  testWidgets('group receipt cases open real partial and all-read records', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    expect(f.actions.canOpen('V041'), isTrue);
    expect(f.actions.canOpen('V042'), isTrue);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await tester.enterText(find.byType(TextField), 'V041');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Partial group delivery/reads'));
    await tester.pumpAndSettle();
    expect(find.text('Read by'), findsOneWidget);
    expect(find.text('Delivered to'), findsOneWidget);
    expect(find.text('No one awaiting a read'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'V042');
    await tester.pumpAndSettle();
    await tester.tap(find.text('All group recipients read'));
    await tester.pumpAndSettle();
    expect(find.text('No one awaiting a read'), findsOneWidget);
  });

  testWidgets('conversion review cancels without mutation and confirms once', (
    tester,
  ) async {
    final f = Fixture();
    addTearDown(f.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReviewCatalogScreen(actions: f.actions)),
    );
    await tester.enterText(find.byType(TextField), 'S19');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diamond conversion review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(f.wallet.diamonds, 350);
    expect(f.wallet.cash, 1000);
    await tester.tap(find.text('Diamond conversion review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm conversion'));
    await tester.pumpAndSettle();
    expect(f.wallet.diamonds, 340);
    expect(f.wallet.cash, 1050);
    expect(
      f.wallet.activity
          .where((entry) => entry.reference.startsWith('review-conversion-'))
          .length,
      2,
    );
  });
}
