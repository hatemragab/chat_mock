import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_info_screen/group_info_screen.dart';
import 'package:app/features/groups/ui/sheets/group_member_actions_sheet/group_member_actions_sheet.dart';
import 'package:app/features/groups/ui/widgets/group_member_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'group info preview opens member actions and replaces removed members',
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
      await tester.scrollUntilVisible(find.text('Amira Hassan'), 200);
      final preview = tester.widgetList<GroupMemberRow>(
        find.byType(GroupMemberRow),
      );
      expect(preview.map((row) => row.member.id), ['alex', 'sarah', 'amira']);
      expect(preview.first.isCurrentUser, isTrue);
      await tester.tap(find.text('Amira Hassan'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Remove member'),
        100,
        scrollable: find.descendant(
          of: find.byType(GroupMemberActionsSheet),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('Remove member'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Amira Hassan?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(group.activeMembers.map((member) => member.id), [
        'alex',
        'sarah',
        'john',
      ]);
      expect(find.text('Amira Hassan'), findsNothing);
      expect(find.text('John Davis'), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
