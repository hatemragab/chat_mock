import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/prototype_tools/ui/widgets/direct_receipt_review_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('delivery remains reviewable when read receipts are disabled', (
    tester,
  ) async {
    final chats = ChatsController()..readReceiptsEnabled = () => false;
    final chat = chats.byId('sarah');
    final first = chats.send(chat, 'First')!;
    final second = chats.send(chat, 'Second')!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: chats,
            builder: (_, _) => DirectReceiptReviewControls(chats: chats),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Advance direct-message receipt'));
    await tester.pump();
    expect(first.status, DeliveryStatus.delivered);
    await tester.tap(find.text('Advance direct-message receipt'));
    await tester.pump();
    expect(second.status, DeliveryStatus.delivered);
    expect(find.text('Read receipts are disabled.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    chats.dispose();
  });
}
