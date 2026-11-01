import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('photo edits change preview and remain in the draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final wallet = WalletController();
    final controller = PublishingController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    final draft = controller.createDraft(PublicationType.status);
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(controller: controller, draft: draft),
      ),
    );
    await tester.enterText(find.byType(TextField), 'A short caption');
    await tester.ensureVisible(find.text('Rotate (0°)'));
    await tester.tap(find.text('Rotate (0°)'));
    await tester.pump();
    expect(draft.rotation, 1);
    expect(find.text('A short caption'), findsWidgets);
    await tester.ensureVisible(find.byType(Slider));
    await tester.drag(find.byType(Slider), const Offset(60, 0));
    await tester.pump();
    expect(draft.cropScale, greaterThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('video preview playback is bounded by the selected trim', (
    tester,
  ) async {
    final wallet = WalletController();
    final controller = PublishingController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    final draft = controller.createDraft(PublicationType.status)
      ..media = PublicationMedia.video
      ..trimStart = .2
      ..trimEnd = .3;
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(controller: controller, draft: draft),
      ),
    );
    await tester.ensureVisible(find.text('Play preview'));
    await tester.tap(find.text('Play preview'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pause preview'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Play preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
