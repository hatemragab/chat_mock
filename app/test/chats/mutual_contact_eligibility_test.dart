import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/controllers/group_directory.dart';
import 'package:app/features/groups/models/group_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected recipients are removed when blocked or reset', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final temporaryGroup = chats.addGroup('Temporary group');
    await tester.pumpWidget(
      MaterialApp(
        home: RecipientPickerScreen(
          controller: chats,
          multiSelect: true,
          includeGroups: true,
        ),
      ),
    );
    await tester.tap(find.text('Sarah Wilson'));
    await tester.pump();
    expect(find.text('Continue (1)'), findsOneWidget);
    chats.toggleBlocked(chats.byId('sarah'));
    await tester.pump();
    expect(find.text('Continue (0)'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Continue (0)'),
          )
          .onPressed,
      isNull,
    );
    chats.toggleBlocked(chats.byId('sarah'));
    await tester.pump();
    expect(find.text('Continue (0)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), temporaryGroup.name);
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, temporaryGroup.name));
    await tester.pump();
    expect(find.text('Continue (1)'), findsOneWidget);
    chats.reset();
    await tester.pump();
    expect(find.text('Continue (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('unmatched contacts cannot send, receive, or be added to groups', () {
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    final directory = GroupDirectory(chats: chats, initialGroup: group);
    addTearDown(() {
      directory.dispose();
      group.dispose();
      chats.dispose();
    });
    final unmatched = chats.addContact('New Contact', '+237670123456');
    final matched = chats.byId('sarah');
    expect(chats.canCommunicateWithContact(unmatched), isFalse);
    expect(chats.send(unmatched, 'Hello'), isNull);
    expect(chats.receiveContactMessage(unmatched, 'Hello'), isNull);
    expect(unmatched.messages, isEmpty);
    expect(chats.canCommunicateWithContact(matched), isTrue);
    expect(chats.send(matched, 'Hello'), isNotNull);
    expect(
      group.addMembers([GroupMember(id: unmatched.id, name: unmatched.name)]),
      isFalse,
    );
    expect(
      () =>
          directory.create(name: 'Team', description: '', members: [unmatched]),
      throwsArgumentError,
    );
  });

  testWidgets(
    'saving an unmatched contact stays in the picker and explains why',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      await tester.pumpWidget(
        MaterialApp(home: RecipientPickerScreen(controller: chats)),
      );
      await tester.tap(find.text('Add contact'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'New Contact',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        '+237670123456',
      );
      await tester.tap(find.text('Save contact'));
      await tester.pumpAndSettle();
      expect(find.text('Select contact'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'New Contact');
      await tester.pump();
      expect(find.text('Waiting for a mutual match'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'New Contact'),
      );
      expect(tile.onTap, isNull);
    },
  );

  testWidgets(
    'unmatched contact conversation disables message and call controls',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final unmatched = chats.addContact('New Contact', '+237670123456');
      var calls = 0;
      chats.onStartCall = (_, _) => calls++;
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationScreen(controller: chats, chat: unmatched),
        ),
      );
      expect(find.text('Waiting for a mutual contact match.'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.call_outlined),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.videocam_outlined),
            )
            .onPressed,
        isNull,
      );
      expect(calls, 0);
    },
  );
}
