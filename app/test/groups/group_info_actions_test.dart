import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/add_group_members_screen/add_group_members_screen.dart';
import 'package:app/features/groups/ui/screens/group_info_screen/group_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'group info provides a direct permission-aware add-member action',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(home: GroupInfoScreen(controller: group)),
      );
      await tester.scrollUntilVisible(find.text('Add members'), 200);
      await tester.tap(find.text('Add members'));
      await tester.pumpAndSettle();
      expect(find.byType(AddGroupMembersScreen), findsOneWidget);
      await tester.tap(find.text('Karim Diallo'));
      await tester.pump();
      await tester.tap(find.text('Add 1 member'));
      await tester.pumpAndSettle();
      expect(
        group.activeMembers.where((member) => member.id == 'karim'),
        hasLength(1),
      );
      group.setPerspective('amira');
      await tester.pump();
      expect(find.text('Add members'), findsNothing);
    },
  );

  for (final left in [false, true]) {
    testWidgets(
      'group info deletes only local history after confirmation (left: $left)',
      (tester) async {
        final chats = ChatsController();
        final group = GroupController(chats: chats)..setPerspective('amira');
        if (left) group.leave();
        addTearDown(() {
          group.dispose();
          chats.dispose();
        });
        final originalCount = group.conversation.messages.length;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupInfoScreen(controller: group),
                    ),
                  ),
                  child: const Text('Open info'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open info'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Delete conversation'), 200);
        await tester.tap(find.text('Delete conversation'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('You remain a group member.'),
          left ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(group.conversation.messages, hasLength(originalCount));
        expect(group.conversation.hidden, isFalse);
        await tester.tap(find.text('Delete conversation'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        expect(group.conversation.messages, isEmpty);
        expect(group.conversation.hidden, isTrue);
        expect(group.left, left);
        expect(group.perspective.active, !left);
        expect(find.text('Open info'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
