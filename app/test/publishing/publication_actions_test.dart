import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/publications_screen/publications_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'publication actions retain the item on cancel and delete only after confirmation',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..caption = 'A good day';
      expect(
        controller.publish(draft, controller.review(draft)),
        PublishResult.success,
      );
      final publication = controller.publications.single;
      await tester.pumpWidget(
        MaterialApp(home: PublicationsScreen(controller: controller)),
      );
      await tester.tap(find.byTooltip('Publication options'));
      await tester.pumpAndSettle();
      expect(find.text('Story viewers'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.active);
      await tester.tap(find.byTooltip('Publication options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.active);
      await tester.tap(find.byTooltip('Publication options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete publication'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.removed);
    },
  );

  testWidgets('open action uses the selected publication Story', (
    tester,
  ) async {
    final wallet = WalletController();
    final controller = PublishingController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    final draft = controller.createDraft(PublicationType.status)
      ..caption = 'My own Story';
    controller.publish(draft, controller.review(draft));
    await tester.pumpWidget(
      MaterialApp(home: PublicationsScreen(controller: controller)),
    );
    await tester.tap(find.byTooltip('Publication options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Story'));
    await tester.pumpAndSettle();
    expect(find.text('My own Story'), findsWidgets);
    expect(find.text('Alex Morgan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
