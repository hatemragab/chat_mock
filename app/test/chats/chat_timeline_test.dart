import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/utils/chat_timeline.dart';
import 'package:app/features/chats/ui/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('day labels use local calendar dates and preserve older dates', () {
    final now = DateTime(2026, 3, 1, 1);
    expect(ChatTimeline.dayLabel(DateTime(2026, 3, 1), now: now), 'Today');
    expect(ChatTimeline.dayLabel(DateTime(2026, 2, 28), now: now), 'Yesterday');
    expect(
      ChatTimeline.dayLabel(DateTime(2025, 12, 31), now: now),
      '31 Dec 2025',
    );
  });

  testWidgets(
    'group timeline separates days and groups consecutive sender messages',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10);
      final today = DateTime(now.year, now.month, now.day, 10);
      ChatMessage message(
        String id,
        String text,
        DateTime time, {
        MessageKind kind = MessageKind.text,
      }) => ChatMessage(
        id: id,
        author: 'Sarah',
        authorId: 'sarah',
        text: text,
        time: time,
        isMine: false,
        kind: kind,
      );
      final chat = ChatConversation(
        id: 'test-group',
        name: 'Group',
        kind: ChatKind.group,
        messages: [
          message('a', 'First', yesterday),
          message('b', 'Second', yesterday.add(const Duration(minutes: 2))),
          message(
            'event',
            'Sarah joined',
            yesterday.add(const Duration(minutes: 3)),
            kind: MessageKind.system,
          ),
          message(
            'c',
            'After event',
            yesterday.add(const Duration(minutes: 4)),
          ),
          message('d', 'New day', today),
        ],
      );
      final chats = ChatsController()..conversations.add(chat);
      addTearDown(chats.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationScreen(
            controller: chats,
            chat: chat,
            initialMessageId: 'a',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      final bubbles = tester
          .widgetList<MessageBubble>(find.byType(MessageBubble))
          .toList();
      final first = bubbles.firstWhere((bubble) => bubble.message.id == 'a');
      final second = bubbles.firstWhere((bubble) => bubble.message.id == 'b');
      final after = bubbles.firstWhere((bubble) => bubble.message.id == 'c');
      final tomorrow = bubbles.firstWhere((bubble) => bubble.message.id == 'd');
      expect(first.groupedWithNext, isTrue);
      expect(second.groupedWithPrevious, isTrue);
      expect(second.groupedWithNext, isFalse);
      expect(after.groupedWithPrevious, isFalse);
      expect(after.groupedWithNext, isFalse);
      expect(tomorrow.groupedWithPrevious, isFalse);
      expect(find.text('Sarah'), findsNWidgets(3));
      expect(
        find.ancestor(
          of: find.text('Sarah joined'),
          matching: find.byType(Center),
        ),
        findsWidgets,
      );
    },
  );
}
