import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/controllers/group_directory.dart';
import 'package:app/features/groups/models/group_photo.dart';
import 'package:app/features/groups/ui/screens/create_group_screen/create_group_screen.dart';
import 'package:app/features/groups/ui/widgets/group_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final observeChats in [false, true]) {
    testWidgets(
      'cancellation from ${observeChats ? 'chat mutation' : 'progress'} listeners prevents a late room',
      (tester) async {
        final chats = ChatsController();
        final seed = GroupController(chats: chats);
        final directory = GroupDirectory(chats: chats, initialGroup: seed);
        addTearDown(() {
          directory.dispose();
          seed.dispose();
          chats.dispose();
        });
        var cancelled = false;
        void cancel() {
          if (cancelled) return;
          if (observeChats &&
              !chats.conversations.any(
                (chat) => chat.name == 'Cancelled room',
              )) {
            return;
          }
          if (!observeChats &&
              directory.creationStatus != GroupCreationStatus.submitting) {
            return;
          }
          cancelled = true;
          directory.cancelCreation();
        }

        if (observeChats) {
          chats.addListener(cancel);
        } else {
          directory.addListener(cancel);
        }
        final pending = directory.submitCreate(
          name: 'Cancelled room',
          description: '',
          members: [chats.byId('sarah')],
        );
        await tester.pump(const Duration(seconds: 1));
        expect(await pending, isNull);
        expect(cancelled, isTrue);
        expect(directory.groups, hasLength(1));
        expect(
          chats.conversations.where(
            (chat) => chat.name == 'Cancelled room' && !chat.hidden,
          ),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final reset in [false, true]) {
    testWidgets(
      'creation listeners can ${reset ? 'reset' : 'cancel'} without completing twice',
      (tester) async {
        final chats = ChatsController();
        final seed = GroupController(chats: chats);
        final directory = GroupDirectory(chats: chats, initialGroup: seed);
        addTearDown(() {
          directory.dispose();
          seed.dispose();
          chats.dispose();
        });
        var handled = false;
        directory.addListener(() {
          if (handled || directory.groups.length == 1) return;
          handled = true;
          if (reset) {
            directory.reset();
          } else {
            directory.cancelCreation();
          }
        });
        final pending = directory.submitCreate(
          name: 'Committed team',
          description: '',
          members: [chats.byId('sarah')],
        );
        await tester.pump(const Duration(milliseconds: 400));
        final result = await pending;
        expect(handled, isTrue);
        expect(directory.creationStatus, GroupCreationStatus.idle);
        if (reset) {
          expect(result, isNull);
          expect(directory.groups, hasLength(1));
        } else {
          expect(result, isNotNull);
          expect(directory.forChat(result!.chatId), same(result));
          expect(directory.groups, hasLength(2));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('failed group creation retains photo and all details for retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final seed = GroupController(chats: chats);
    final directory = GroupDirectory(chats: chats, initialGroup: seed);
    addTearDown(() {
      directory.dispose();
      seed.dispose();
      chats.dispose();
    });
    GroupController? created;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  created = await Navigator.push<GroupController>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateGroupScreen(
                        directory: directory,
                        simulateFirstFailure: true,
                      ),
                    ),
                  ),
              child: const Text('New group'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('New group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add group photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Green garden'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Group name'),
      'Customer team',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description (optional)'),
      'Our local demo',
    );
    await tester.ensureVisible(find.text('Select members'));
    await tester.tap(find.text('Select members'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Wilson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue (1)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create group'));
    await tester.tap(find.text('Create group'));
    await tester.pump();
    expect(directory.creationStatus, GroupCreationStatus.submitting);
    expect(find.text('Creating group…'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(directory.creationStatus, GroupCreationStatus.failed);
    expect(directory.groups, hasLength(1));
    expect(find.text('Customer team'), findsOneWidget);
    expect(find.text('Our local demo'), findsOneWidget);
    expect(find.text('Sarah Wilson'), findsOneWidget);
    expect(
      tester.widget<GroupPhotoPicker>(find.byType(GroupPhotoPicker)).photo,
      GroupPhoto.garden,
    );
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(directory.groups, hasLength(2));
    expect(created?.name, 'Customer team');
    expect(created?.description, 'Our local demo');
    expect(created?.photo, GroupPhoto.garden);
    expect(created?.activeMembers.map((member) => member.id), [
      'alex',
      'sarah',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled creation never adds a group after its delay', (
    tester,
  ) async {
    final chats = ChatsController();
    final seed = GroupController(chats: chats);
    final directory = GroupDirectory(chats: chats, initialGroup: seed);
    addTearDown(() {
      directory.dispose();
      seed.dispose();
      chats.dispose();
    });
    final pending = directory.submitCreate(
      name: 'Cancelled',
      description: '',
      members: [chats.byId('sarah')],
      photo: GroupPhoto.studio,
    );
    directory.cancelCreation();
    expect(await pending, isNull);
    await tester.pump(const Duration(seconds: 1));
    expect(directory.creationStatus, GroupCreationStatus.idle);
    expect(directory.groups, hasLength(1));
    expect(
      chats.conversations.where((chat) => chat.name == 'Cancelled'),
      isEmpty,
    );
  });
}
