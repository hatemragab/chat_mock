import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/attachment_preview_screen/attachment_preview_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final linkedChats in [false, true]) {
    testWidgets(
      'Business attachments retain edits and recheck expiry before send (linked: $linkedChats)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chats = ChatsController();
        final wallet = WalletController();
        final stories = StoriesController();
        final business = BusinessController(
          wallet: wallet,
          chats: linkedChats ? chats : null,
          stories: stories,
        );
        addTearDown(() {
          business.dispose();
          stories.dispose();
          wallet.dispose();
          chats.dispose();
        });
        final story = StoriesController.stories.first;
        expect(
          business.openRoom(story, confirmed: true),
          OpenRoomResult.opened,
        );
        final balance = wallet.credits;
        final room = business.roomFor(story.id)!;
        await tester.pumpWidget(
          MaterialApp(
            home: BusinessConversationScreen(
              controller: business,
              story: story,
            ),
          ),
        );
        await openPhoto(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Caption'),
          'Business photo',
        );
        await tester.ensureVisible(find.text('Rotate (0°)'));
        await tester.tap(find.text('Rotate (0°)'));
        await tester.pump();
        await tester.tap(find.text('Send attachment'));
        await tester.pumpAndSettle();
        expect(room.messages.last.mediaEdits!.caption, 'Business photo');
        expect(room.messages.last.mediaEdits!.rotation, 1);
        expect(room.messages.last.assetPath, 'assets/story/green_corner.png');
        final count = room.messages.length;
        await openPhoto(tester);
        await tester.enterText(
          find.widgetWithText(TextField, 'Caption'),
          'Keep this draft',
        );
        business.advance(const Duration(hours: 24));
        await tester.pump();
        await tester.tap(find.text('Send attachment'));
        await tester.pumpAndSettle();
        expect(find.byType(AttachmentPreviewScreen), findsOneWidget);
        expect(find.text('Keep this draft'), findsOneWidget);
        expect(find.textContaining('Your draft is preserved.'), findsOneWidget);
        expect(room.messages, hasLength(count));
        expect(wallet.credits, balance);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

Future<void> openPhoto(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Attach'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Photo library'));
  await tester.pumpAndSettle();
}
