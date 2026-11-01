import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/models/group_photo.dart';
import 'package:app/features/groups/ui/screens/group_details_screen/group_details_screen.dart';
import 'package:app/features/groups/ui/widgets/group_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'saving a photo-only edit updates the room and removal restores initials',
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
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetailsScreen(controller: group),
                  ),
                ),
                child: const Text('Edit'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add group photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Morning coffee'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(group.photo, GroupPhoto.cafe);
      expect(group.conversation.avatarAsset, GroupPhoto.cafe.assetPath);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change group photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove group photo'));
      await tester.pumpAndSettle();
      expect(group.photo, GroupPhoto.cafe);
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(group.photo, GroupPhoto.none);
      expect(group.conversation.avatarAsset, isNull);
      expect(find.text('Edit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'photo changes obey permissions and cannot save after role loss',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      expect(
        group.updateIdentity(
          group.name,
          group.description,
          photo: GroupPhoto.garden,
        ),
        isTrue,
      );
      expect(group.conversation.avatarAsset, GroupPhoto.garden.assetPath);
      expect(group.updateIdentity('Renamed group', group.description), isTrue);
      expect(group.photo, GroupPhoto.garden);
      final pending = group.submitIdentity(
        'Draft',
        'Draft description',
        photo: GroupPhoto.studio,
      );
      group.setPerspective('amira');
      await tester.pump(const Duration(milliseconds: 400));
      expect(await pending, isFalse);
      expect(group.photo, GroupPhoto.garden);
      expect(group.name, 'Renamed group');
      expect(
        group.updateIdentity('Denied', '', photo: GroupPhoto.none),
        isFalse,
      );
      expect(group.photo, GroupPhoto.garden);
      group.setPerspective('alex');
      expect(
        group.updateIdentity(
          group.name,
          group.description,
          photo: GroupPhoto.none,
        ),
        isTrue,
      );
      expect(group.conversation.avatarAsset, isNull);
    },
  );

  testWidgets('discarding a photo-only edit preserves the saved group photo', (
    tester,
  ) async {
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    addTearDown(() {
      group.dispose();
      chats.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailsScreen(controller: group),
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add group photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Morning coffee'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<GroupPhotoPicker>(find.byType(GroupPhotoPicker)).photo,
      GroupPhoto.cafe,
    );
    expect(group.photo, GroupPhoto.none);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(group.photo, GroupPhoto.none);
    expect(find.text('Edit'), findsOneWidget);
  });
}
