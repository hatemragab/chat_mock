import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/dialogs/delete_message_dialog/delete_message_dialog.dart';
import 'package:app/features/chats/ui/screens/chat_info_screen/chat_info_screen.dart';
import 'package:app/features/chats/ui/screens/chats_screen/chats_screen.dart';
import 'package:app/features/chats/ui/sheets/reaction_picker_sheet/reaction_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'delete conversation cancellation preserves history; confirmation hides and clears it',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final chat = chats.byId('sarah');
      final original = chat.messages.length;
      await tester.pumpWidget(
        MaterialApp(home: ChatsScreen(controller: chats)),
      );
      await tester.longPress(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete conversation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(chat.messages.length, original);
      expect(chat.hidden, isFalse);
      await tester.longPress(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete conversation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(chat.messages, isEmpty);
      expect(chat.hidden, isTrue);
      expect(find.text('Sarah Wilson'), findsNothing);
      chats.send(chat, 'Hello again');
      await tester.pump();
      expect(chat.hidden, isFalse);
      expect(find.text('Sarah Wilson'), findsOneWidget);
    },
  );

  testWidgets(
    'mute duration selection and unmute update the same conversation',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final chat = chats.byId('sarah');
      await tester.pumpWidget(
        MaterialApp(home: ChatsScreen(controller: chats)),
      );
      await tester.longPress(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mute'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('8 hours'));
      await tester.pumpAndSettle();
      expect(chat.muted, isTrue);
      expect(
        chat.mutedUntil!.difference(DateTime.now()).inMinutes,
        inInclusiveRange(479, 480),
      );
      await tester.longPress(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mute options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unmute'));
      await tester.pumpAndSettle();
      expect(chat.muted, isFalse);
      expect(chat.mutedUntil, isNull);
    },
  );

  testWidgets(
    'message deletion only offers everyone for eligible own messages',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteMessageDialog(canDeleteForEveryone: false),
          ),
        ),
      );
      expect(find.text('Delete for me'), findsOneWidget);
      expect(find.text('Delete for everyone'), findsNothing);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeleteMessageDialog(canDeleteForEveryone: true)),
        ),
      );
      expect(find.text('Delete for everyone'), findsOneWidget);
    },
  );

  testWidgets('reaction picker includes expanded options and removal', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReactionPickerSheet(currentReaction: '👍')),
      ),
    );
    expect(find.byTooltip('React with 🎉'), findsOneWidget);
    expect(find.text('Remove reaction'), findsOneWidget);
  });

  testWidgets('device-contact handoff is simulated and leaves chat untouched', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final chat = chats.byId('sarah');
    final original = chat.messages.length;
    await tester.pumpWidget(
      MaterialApp(
        home: ChatInfoScreen(controller: chats, chat: chat),
      ),
    );
    await tester.scrollUntilVisible(find.text('Delete device contact'), 300);
    await tester.ensureVisible(find.text('Delete device contact'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete device contact'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No contact is changed or deleted.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Open contacts'));
    await tester.pumpAndSettle();
    expect(chats.byId('sarah'), same(chat));
    expect(chat.messages.length, original);
  });

  testWidgets('a timed mute expires and notifies listeners', (tester) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final chat = chats.byId('sarah');
    var updates = 0;
    chats.addListener(() => updates++);
    chats.muteFor(chat, const Duration(seconds: 2));
    expect(chat.muted, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(chat.muted, isFalse);
    expect(updates, 2);
  });
}
