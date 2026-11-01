import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/models/group_member.dart';
import 'package:app/features/groups/ui/sheets/group_member_actions_sheet/group_member_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scenario in [
    (id: 'D07', memberId: 'amira', action: 'Remove member', confirm: 'Remove'),
    (
      id: 'D08',
      memberId: 'amira',
      action: 'Promote to admin',
      confirm: 'Promote',
    ),
    (id: 'D09', memberId: 'sarah', action: 'Demote admin', confirm: 'Demote'),
    (
      id: 'D10',
      memberId: 'amira',
      action: 'Transfer ownership',
      confirm: 'Transfer',
    ),
  ]) {
    testWidgets(
      '${scenario.id} targets the member; cancel preserves state and confirm applies once',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chats = ChatsController();
        final group = GroupController(chats: chats);
        addTearDown(() {
          group.dispose();
          chats.dispose();
        });
        final member = group.members.firstWhere(
          (m) => m.id == scenario.memberId,
        );
        final initialRole = member.role;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => GroupMemberActionsSheet(
                      controller: group,
                      member: member,
                    ),
                  ),
                  child: const Text('Open member actions'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open member actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(scenario.action));
        await tester.pumpAndSettle();
        expect(find.textContaining(member.name), findsWidgets);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(member.active, isTrue);
        expect(member.role, initialRole);
        expect(find.text(scenario.action), findsOneWidget);
        await tester.tap(find.text(scenario.action));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, scenario.confirm));
        await tester.pumpAndSettle();
        expect(find.text('Open member actions'), findsOneWidget);
        switch (scenario.id) {
          case 'D07':
            expect(member.active, isFalse);
          case 'D08':
            expect(member.role, GroupRole.admin);
          case 'D09':
            expect(member.role, GroupRole.member);
          case 'D10':
            expect(member.role, GroupRole.owner);
            expect(
              group.members.firstWhere((m) => m.id == 'alex').role,
              GroupRole.admin,
            );
        }
      },
    );
  }
  testWidgets('S08 ordinary members cannot manage another member', (
    tester,
  ) async {
    final chats = ChatsController();
    final group = GroupController(chats: chats)..perspectiveId = 'john';
    addTearDown(() {
      group.dispose();
      chats.dispose();
    });
    final member = group.members.firstWhere((m) => m.id == 'amira');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GroupMemberActionsSheet(controller: group, member: member),
        ),
      ),
    );
    expect(find.text('Promote to admin'), findsNothing);
    expect(find.text('Demote admin'), findsNothing);
    expect(find.text('Transfer ownership'), findsNothing);
    expect(find.text('Remove member'), findsNothing);
    expect(
      find.text('You do not have permission to manage this member.'),
      findsOneWidget,
    );
  });
  testWidgets(
    'S08 last owner action is reachable on a small screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      final member = group.members.firstWhere((m) => m.id == 'amira');
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => GroupMemberActionsSheet(
                    controller: group,
                    member: member,
                  ),
                ),
                child: const Text('Open member actions'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open member actions'));
      await tester.pumpAndSettle();
      final sheet = find.byType(GroupMemberActionsSheet);
      await tester.scrollUntilVisible(
        find.text('Remove member'),
        100,
        scrollable: find
            .descendant(of: sheet, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(find.text('Remove member'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Amira Hassan?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(member.active, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
