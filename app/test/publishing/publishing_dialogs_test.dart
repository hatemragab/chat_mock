import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/publishing/ui/screens/price_review_screen/price_review_screen.dart';
import 'package:app/features/publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import 'package:app/features/publishing/ui/sheets/boost_options_sheet/boost_options_sheet.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'changed prices require reviewing itemized terms; cancelling preserves the draft',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.advertisement)
        ..paidCategory = true
        ..media = PublicationMedia.video;
      await tester.pumpWidget(
        MaterialApp(
          home: PriceReviewScreen(controller: controller, draft: draft),
        ),
      );
      controller.updateConfig(
        const PublishingConfig(
          categoryFee: 10,
          boostFee: 60,
          advertisementFee: 100,
        ),
      );
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Category: 5 → 10 Credits'), findsOneWidget);
      expect(find.text('Total: 155 → 170 Credits'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(wallet.credits, 3000);
      expect(controller.publications, isEmpty);
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review updated price'));
      await tester.pumpAndSettle();
      expect(find.text('170 Credits'), findsOneWidget);
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(wallet.credits, 2830);
      expect(controller.publications, hasLength(1));
    },
  );

  testWidgets(
    'full image slots show contextual guidance and retain the draft',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(
        wallet: wallet,
        config: const PublishingConfig(photoSlots: 1),
      );
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final first = controller.createDraft(PublicationType.status);
      expect(
        controller.publish(first, controller.review(first)),
        PublishResult.success,
      );
      final second = controller.createDraft(PublicationType.status)
        ..caption = 'Keep me';
      await tester.pumpWidget(
        MaterialApp(
          home: PriceReviewScreen(controller: controller, draft: second),
        ),
      );
      await tester.tap(find.text('Publish'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Photo Status limit reached'), findsOneWidget);
      expect(find.textContaining('1 of 1 photo Status slots'), findsOneWidget);
      expect(second.caption, 'Keep me');
      expect(controller.publications, hasLength(1));
    },
  );

  testWidgets(
    'boost choices preserve draft on cancel and require video Boost',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final photo = controller.createDraft(PublicationType.status);
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(controller: controller, draft: photo),
        ),
      );
      await tester.ensureVisible(find.text('Boost'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boost'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(photo.boosted, isFalse);
      photo.media = PublicationMedia.video;
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(
            key: const ValueKey('video'),
            controller: controller,
            draft: photo,
          ),
        ),
      );
      await tester.ensureVisible(find.text('Boost'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boost'));
      await tester.pumpAndSettle();
      expect(
        find.text('Boost is required for video and audio.'),
        findsOneWidget,
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
        isNull,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(BoostOptionsSheet),
          matching: find.text('Continue'),
        ),
      );
      await tester.pumpAndSettle();
      expect(photo.effectiveBoost, isTrue);
    },
  );

  testWidgets(
    'publication delete dialog identifies the target and cancel does not remove it',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..caption = 'My story';
      controller.publish(draft, controller.review(draft));
      final publication = controller.publications.single;
      await tester.pumpWidget(
        MaterialApp(
          home: PublicationDetailsScreen(
            controller: controller,
            publication: publication,
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Delete publication'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete publication'));
      await tester.pumpAndSettle();
      expect(find.textContaining('“My story”'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(publication.status, PublicationStatus.active);
    },
  );
}
