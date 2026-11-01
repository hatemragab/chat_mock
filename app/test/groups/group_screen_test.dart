import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('group chat becomes read only when admin-only send is enabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final group = GroupController(chats: chats);
    addTearDown(group.dispose);
    addTearDown(chats.dispose);
    await tester.pumpWidget(MaterialApp(home: GroupScreen(controller: group)));
    expect(find.text('Design Team'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    group.setPermissions(send: true);
    group.setPerspective('amira');
    await tester.pump();
    expect(find.text('Only admins can send messages.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    group.setPerspective('sarah');
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
  });
}
