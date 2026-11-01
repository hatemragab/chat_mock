import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/widgets/chat_day_separator.dart';
import 'package:app/features/chats/ui/widgets/message_bubble.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final target in <String?>[null, 'second']) {
    testWidgets(
      'Business timeline groups participant messages and marks days (target $target)',
      (tester) async {
        final wallet = WalletController();
        final business = BusinessController(wallet: wallet);
        addTearDown(() {
          business.dispose();
          wallet.dispose();
        });
        final story = StoriesController.stories.first;
        expect(
          business.openRoom(story, confirmed: true),
          OpenRoomResult.opened,
        );
        final room = business.roomFor(story.id)!;
        ChatMessage message(String id, String authorId, DateTime time) =>
            ChatMessage(
              id: id,
              author: 'Alex Morgan',
              authorId: authorId,
              text: id,
              time: time,
              isMine: true,
            );
        room.messages.addAll([
          message('first', 'business-recipient', DateTime(2026, 1, 1, 10)),
          message('second', 'business-recipient', DateTime(2026, 1, 1, 10, 5)),
          message('third', 'business-customer', DateTime(2026, 1, 2, 10)),
        ]);
        await tester.pumpWidget(
          MaterialApp(
            home: BusinessConversationScreen(
              controller: business,
              story: story,
              initialMessageId: target,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ChatDaySeparator), findsNWidgets(2));
        final first = tester.widget<MessageBubble>(
          find.byWidgetPredicate(
            (widget) => widget is MessageBubble && widget.message.id == 'first',
          ),
        );
        final second = tester.widget<MessageBubble>(
          find.byWidgetPredicate(
            (widget) =>
                widget is MessageBubble && widget.message.id == 'second',
          ),
        );
        final third = tester.widget<MessageBubble>(
          find.byWidgetPredicate(
            (widget) => widget is MessageBubble && widget.message.id == 'third',
          ),
        );
        expect(first.isMine, isFalse);
        expect(first.groupedWithNext, isTrue);
        expect(second.groupedWithPrevious, isTrue);
        expect(second.groupedWithNext, isFalse);
        expect(third.isMine, isTrue);
        expect(third.groupedWithPrevious, isFalse);
        if (target != null) expect(second.highlight, isTrue);
      },
    );
  }
}
