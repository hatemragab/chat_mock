import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opening a reply or edit from review retains message context', (
    tester,
  ) async {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    final incoming = chat.messages.firstWhere((item) => !item.isMine);
    final own = chat.messages.firstWhere((item) => item.isMine);
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(
          controller: chats,
          chat: chat,
          initialReply: incoming,
        ),
      ),
    );
    await tester.pump();
    expect(
      find.textContaining('${incoming.author}: ${incoming.text}'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(
          controller: chats,
          chat: chat,
          initialEdit: own,
        ),
      ),
    );
    await tester.pump();
    expect(find.text(own.text), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    chats.dispose();
  });
}
