import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/analytics_screen/analytics_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('analytics reflects pending mock rewards after qualified views', (
    tester,
  ) async {
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.advertisement);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final item = publishing.publications.single;
    await tester.pumpWidget(
      MaterialApp(
        home: AnalyticsScreen(controller: publishing, publication: item),
      ),
    );
    expect(find.text('Pending Diamond rewards'), findsOneWidget);
    expect(
      find.text('Mock rate: 1 Diamond per 50 qualified unique views'),
      findsOneWidget,
    );
    for (var i = 0; i < 50; i++) {
      publishing.recordView(item, viewerId: 'view-$i', viewerName: 'Viewer');
    }
    await tester.pump();
    expect(item.pendingDiamondRewards, 1);
    expect(wallet.pendingDiamonds, 41);
    expect(find.text('1'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    publishing.dispose();
    wallet.dispose();
  });
}
