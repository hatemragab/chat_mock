import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'removing and replacing media preserves the draft and prevents empty publication',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..caption = 'Keep this caption';
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(controller: controller, draft: draft),
        ),
      );
      await tester.ensureVisible(find.byTooltip('Replace or remove media'));
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();
      expect(draft.sample, isEmpty);
      expect(draft.caption, 'Keep this caption');
      expect(
        controller.publish(draft, controller.review(draft)),
        PublishResult.missingMedia,
      );
      await tester.tap(find.byTooltip('Choose media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('City moments'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'City moments');
      expect(draft.caption, 'Keep this caption');
      expect(
        controller.publish(draft, controller.review(draft)),
        PublishResult.success,
      );
    },
  );
}
