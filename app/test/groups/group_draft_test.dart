import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_details_screen/group_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'discard confirmation preserves or abandons an edited group draft',
    (tester) async {
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroupDetailsScreen(controller: group),
                  ),
                ),
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Group name'),
        'Renamed team',
      );
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Renamed team'), findsOneWidget);
      expect(group.name, 'Design Team');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Open editor'), findsOneWidget);
      expect(group.name, 'Design Team');
    },
  );
}
