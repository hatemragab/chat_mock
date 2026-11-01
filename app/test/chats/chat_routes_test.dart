import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/archived_chats_screen/archived_chats_screen.dart';
import 'package:app/features/chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import 'package:app/features/chats/ui/screens/starred_messages_screen/starred_messages_screen.dart';
import 'package:app/features/chats/ui/widgets/message_bubble.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'search opens the selected message in the permission-aware group',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(group.dispose);
      addTearDown(chats.dispose);
      for (var i = 0; i < 40; i++) {
        group.send('Message number $i');
      }
      final target = group.conversation.messages.firstWhere(
        (message) => message.text == 'Message number 17',
      );
      group.setPermissions(send: true);
      group.setPerspective('amira');
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ChatSearchScreen(
            controller: chats,
            specialMessageScreenBuilder: (chat, messageId) =>
                chat.id == 'design'
                ? GroupScreen(controller: group, initialMessageId: messageId)
                : null,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Message number 17');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Message number 17').last);
      await tester.pumpAndSettle();
      expect(find.byType(GroupScreen), findsOneWidget);
      expect(find.text('Only admins can send messages.'), findsOneWidget);
      final bubble = tester.widget<MessageBubble>(
        find.byWidgetPredicate(
          (widget) => widget is MessageBubble && widget.message.id == target.id,
        ),
      );
      expect(bubble.highlight, isTrue);
      final rect = tester.getRect(find.byWidget(bubble));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(802));
    },
  );

  testWidgets('archived and starred entries use the special group route', (
    tester,
  ) async {
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    addTearDown(group.dispose);
    addTearDown(chats.dispose);
    chats.archive(group.conversation);
    final message = group.conversation.messages.first;
    chats.toggleStar(message);
    Widget? destination(ChatConversation chat, String? messageId) =>
        chat.id == 'design'
        ? GroupScreen(controller: group, initialMessageId: messageId)
        : null;
    await tester.pumpWidget(
      MaterialApp(
        home: ArchivedChatsScreen(
          controller: chats,
          specialMessageScreenBuilder: destination,
        ),
      ),
    );
    await tester.tap(find.text('Design Team'));
    await tester.pumpAndSettle();
    expect(find.byType(GroupScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        home: StarredMessagesScreen(
          controller: chats,
          specialMessageScreenBuilder: destination,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(message.text));
    await tester.pumpAndSettle();
    expect(find.byType(GroupScreen), findsOneWidget);
    expect(
      tester.widget<GroupScreen>(find.byType(GroupScreen)).initialMessageId,
      message.id,
    );
  });
}
