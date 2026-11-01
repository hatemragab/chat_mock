import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/chat_info_screen/chat_info_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'editing a contact validates and updates its session and group identity',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      final sarah = chats.byId('sarah');
      chats.addContact('Existing Contact', '+237600000123');
      await tester.pumpWidget(
        MaterialApp(
          home: ChatInfoScreen(controller: chats, chat: sarah),
        ),
      );
      await tester.scrollUntilVisible(find.text('Edit contact'), 300);
      await tester.ensureVisible(find.text('Edit contact'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit contact'));
      await tester.pumpAndSettle();
      expect(find.text('Edit contact'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.widgetWithText(TextFormField, 'Phone number'),
            )
            .controller!
            .text,
        '+1 202 555 0101',
      );
      expect(
        find.textContaining('device contacts will not be changed'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Sarah Edited',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        '+237 600 000 123',
      );
      await tester.tap(find.text('Save contact'));
      await tester.pump();
      expect(
        find.text('This phone number is already in your contacts'),
        findsOneWidget,
      );
      expect(sarah.name, 'Sarah Wilson');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        '12',
      );
      await tester.tap(find.text('Save contact'));
      await tester.pump();
      expect(find.text('Enter a valid phone number'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        '+237600000999',
      );
      await tester.tap(find.text('Save contact'));
      await tester.pumpAndSettle();
      expect(sarah.name, 'Sarah Edited');
      expect(sarah.phone, '+237600000999');
      await tester.scrollUntilVisible(find.text('Sarah Edited'), -300);
      await tester.pumpAndSettle();
      expect(find.text('Sarah Edited'), findsOneWidget);
      expect(find.text('+237600000999'), findsOneWidget);
      expect(
        group.members.singleWhere((member) => member.id == 'sarah').name,
        'Sarah Edited',
      );
      expect(group.conversation.subtitle, contains('Sarah Edited'));
      expect(chats.canCommunicateWithContact(sarah), isTrue);
    },
  );

  test('controller refuses invalid or duplicate contact edits', () {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final first = chats.addContact('First', '+237600000111');
    final second = chats.addContact('Second', '+237600000222');
    expect(chats.updateContact(first, '', '+237600000111'), isFalse);
    expect(chats.updateContact(first, 'Updated', '+237 600 000 222'), isFalse);
    expect(first.name, 'First');
    expect(second.phone, '+237600000222');
    expect(chats.updateContact(first, 'Updated', '+237600000111'), isTrue);
    expect(first.name, 'Updated');
  });

  test(
    'fixture phone numbers are unique and saved across an unchanged edit',
    () {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final contacts = [
        'sarah',
        'amira',
        'john',
        'karim',
        'maya',
        'leo',
      ].map(chats.byId).toList();
      final numbers = contacts.map((contact) => contact.phone).toSet();
      expect(numbers, hasLength(6));
      expect(
        numbers.every(
          (number) => number != null && number.startsWith('+1 202 555 01'),
        ),
        isTrue,
      );
      final first = contacts.first;
      expect(chats.updateContact(first, first.name, first.phone!), isTrue);
      expect(
        chats.updateContact(contacts.last, contacts.last.name, first.phone!),
        isFalse,
      );
    },
  );

  test(
    'renaming a group member preserves ownership of seeded and new messages',
    () {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      final sarah = chats.byId('sarah');
      group.setPerspective('sarah');
      final historical = group.conversation.messages.singleWhere(
        (message) => message.text == 'Design review.pdf',
      );
      final sent = group.send('Current message')!;
      expect(group.isOwnMessage(historical), isTrue);
      expect(group.isOwnMessage(sent), isTrue);
      expect(
        chats.updateContact(sarah, 'New Display Name', sarah.phone!),
        isTrue,
      );
      expect(group.isOwnMessage(historical), isTrue);
      expect(group.isOwnMessage(sent), isTrue);
      group.setPerspective('amira');
      expect(group.isOwnMessage(historical), isFalse);
      expect(group.isOwnMessage(sent), isFalse);
    },
  );
}
