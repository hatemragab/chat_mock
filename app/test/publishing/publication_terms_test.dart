import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/category_screen/category_screen.dart';
import 'package:app/features/publishing/ui/screens/media_screen/media_screen.dart';
import 'package:app/features/publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import 'package:app/features/publishing/ui/widgets/publication_price_breakdown.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'category explains its content and configured fee before selecting media',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(
        wallet: wallet,
        config: const PublishingConfig(categoryFee: 9),
      );
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
      });
      final draft = publishing.createDraft(PublicationType.status);
      await tester.pumpWidget(
        MaterialApp(
          home: CategoryScreen(controller: publishing, draft: draft),
        ),
      );
      expect(
        find.text(
          'Everyday moments, personal updates and things you want to share.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text(
          'Creative work, interiors, art and thoughtfully made objects.',
        ),
        150,
      );
      expect(find.text('9 Credits category fee'), findsWidgets);
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      expect(find.byType(MediaScreen), findsOneWidget);
      expect(draft.category, 'Design');
      expect(draft.paidCategory, isTrue);
      expect(wallet.credits, 3000);
    },
  );

  testWidgets(
    'publication details retain original itemized prices after configuration changes and extension',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
      });
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..media = PublicationMedia.video
        ..paidCategory = true;
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      publishing.updateConfig(
        const PublishingConfig(
          categoryFee: 20,
          boostFee: 80,
          advertisementFee: 150,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: PublicationDetailsScreen(
            controller: publishing,
            publication: publication,
          ),
        ),
      );
      await tester.scrollUntilVisible(find.text('Original total'), 200);
      final breakdown = tester.widget<PublicationPriceBreakdown>(
        find.byType(PublicationPriceBreakdown),
      );
      expect(breakdown.price, same(publication.price));
      expect(breakdown.price.category, 5);
      expect(breakdown.price.boost, 50);
      expect(breakdown.price.advertisement, 100);
      expect(find.text('155 Credits'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Lifetime: 48 hours'), 150);
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Extend by 24 hours'), 150);
      await tester.tap(find.text('Extend by 24 hours'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('24-hour extension applied'),
        -150,
      );
      expect(
        publication.expiresAt.difference(publication.createdAt),
        const Duration(hours: 72),
      );
      expect(find.text('24-hour extension applied'), findsOneWidget);
      expect(publication.price.total, 155);
      expect(wallet.credits, 2845);
      expect(tester.takeException(), isNull);
    },
  );
}
