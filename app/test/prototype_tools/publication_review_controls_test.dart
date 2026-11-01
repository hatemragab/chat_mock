import 'package:app/features/prototype_tools/ui/widgets/publication_review_controls.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'review controls record unique and held views and reach Popular without revealing identities',
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
      final draft = publishing.createDraft(PublicationType.advertisement);
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final item = publishing.publications.single;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: publishing,
              builder: (_, _) => ListView(
                children: [PublicationReviewControls(publishing: publishing)],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Add contact view'));
      await tester.pump();
      await tester.tap(find.text('Add contact view'));
      await tester.pump();
      await tester.tap(find.text('Add held view'));
      await tester.pump();
      expect(item.qualifiedViews, 2);
      expect(item.heldViews, 1);
      expect(item.contactViewers, isEmpty);
      await tester.ensureVisible(find.text('Reach Popular threshold'));
      await tester.tap(find.text('Reach Popular threshold'));
      await tester.pump();
      expect(item.qualifiedViews, publishing.config.popularThreshold);
      expect(item.heldViews, 1);
      expect(item.totalViews, publishing.config.popularThreshold + 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ordinary Status exposes contact viewers and not held identities',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
      });
      final draft = publishing.createDraft(PublicationType.status);
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final item = publishing.publications.single;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: publishing,
              builder: (_, _) => ListView(
                children: [PublicationReviewControls(publishing: publishing)],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Add contact view'));
      await tester.pump();
      await tester.tap(find.text('Add held view'));
      await tester.pump();
      expect(item.contactViewers.values.single.name, 'Sarah Wilson');
      expect(item.heldViews, 1);
      expect(find.text('Reach Popular threshold'), findsNothing);
      await tester.tap(find.text('Open contact viewers'));
      await tester.pumpAndSettle();
      expect(find.text('Sarah Wilson'), findsOneWidget);
      expect(find.text('Held view'), findsNothing);
    },
  );
}
