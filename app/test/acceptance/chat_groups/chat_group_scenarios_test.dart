import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/archived_chats_screen/archived_chats_screen.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_info_screen/group_info_screen.dart';
import 'package:app/features/groups/ui/screens/group_members_screen/group_members_screen.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an attachment shows sending progress then its sent status', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final chat = chats.byId('sarah');
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(controller: chats, chat: chat),
      ),
    );
    await tester.tap(find.byTooltip('Attach'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send attachment'));
    await tester.pump();
    final sent = chat.messages.last;
    expect(sent.status, DeliveryStatus.sending);
    expect(find.text('Uploading 0%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Uploading 25%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump();
    expect(sent.status, DeliveryStatus.sent);
    expect(find.textContaining('Uploading'), findsNothing);
    expect(
      chat.messages.where((message) => message.id == sent.id),
      hasLength(1),
    );
  });

  testWidgets('archived list updates to empty when the last chat is restored', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final chat = chats.byId('sarah');
    chats.archive(chat);
    await tester.pumpWidget(
      MaterialApp(home: ArchivedChatsScreen(controller: chats)),
    );
    expect(find.text('Sarah Wilson'), findsOneWidget);
    await tester.tap(find.byTooltip('Unarchive'));
    await tester.pump();
    expect(chat.archived, isFalse);
    expect(find.text('No archived chats'), findsOneWidget);
  });

  testWidgets('unsupported document remains a simulated download', (
    tester,
  ) async {
    final file = ChatMessage(
      id: 'unsupported',
      author: 'Sarah',
      text: 'design.sketch',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.document,
    );
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: file)),
    );
    expect(find.text('Unsupported file preview'), findsOneWidget);
    expect(find.text('Open sample'), findsNothing);
    await tester.tap(find.text('Download sample'));
    await tester.pump();
    expect(find.text('Saved in demo'), findsOneWidget);
  });

  testWidgets('group controls follow owner, admin and member perspectives', (
    tester,
  ) async {
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    addTearDown(group.dispose);
    addTearDown(chats.dispose);
    await tester.pumpWidget(
      MaterialApp(home: GroupInfoScreen(controller: group)),
    );
    expect(find.byTooltip('Edit group'), findsOneWidget);
    group.setPerspective('sarah');
    await tester.pump();
    expect(find.byTooltip('Edit group'), findsOneWidget);
    group.setPerspective('amira');
    await tester.pump();
    expect(find.byTooltip('Edit group'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(home: GroupMembersScreen(controller: group)),
    );
    expect(find.text('Add members'), findsNothing);
    await tester.tap(find.text('Sarah Wilson'));
    await tester.pumpAndSettle();
    expect(
      find.text('You do not have permission to manage this member.'),
      findsOneWidget,
    );
    expect(find.text('Remove member'), findsNothing);
  });

  testWidgets('removed and left group members can read but cannot send', (
    tester,
  ) async {
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    addTearDown(group.dispose);
    addTearDown(chats.dispose);
    final member = group.members.firstWhere((value) => value.id == 'amira');
    expect(group.remove(member), isTrue);
    group.setPerspective(member.id);
    await tester.pumpWidget(MaterialApp(home: GroupScreen(controller: group)));
    expect(
      find.text('You are no longer a member. History is read-only.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('The new concepts are ready for review.'), findsOneWidget);
    group.setPerspective('john');
    expect(group.leave(), isTrue);
    await tester.pump();
    expect(
      find.text('You left this group. History is read-only.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
    'adding members disables existing contacts and adds one only once',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(group.dispose);
      addTearDown(chats.dispose);
      await tester.pumpWidget(
        MaterialApp(home: GroupMembersScreen(controller: group)),
      );
      await tester.tap(find.text('Add members'));
      await tester.pumpAndSettle();
      final existing = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Sarah Wilson'),
      );
      expect(existing.value, isTrue);
      expect(existing.onChanged, isNull);
      await tester.tap(find.text('Karim Diallo'));
      await tester.pump();
      await tester.tap(find.text('Add 1 member'));
      await tester.pumpAndSettle();
      expect(
        group.activeMembers.where((member) => member.id == 'karim'),
        hasLength(1),
      );
      await tester.tap(find.text('Add members'));
      await tester.pumpAndSettle();
      final added = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Karim Diallo'),
      );
      expect(added.value, isTrue);
      expect(added.onChanged, isNull);
    },
  );
}
