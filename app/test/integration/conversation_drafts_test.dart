import 'package:app/app/app.dart';
import 'package:app/app/ui/screens/home_shell/home_shell.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/copy/chats_copy.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final grouped in [false, true]) {
    testWidgets(
      '${grouped ? 'group' : 'direct'} draft keeps its caret and focus when offline context changes',
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
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
                viewInsets: const EdgeInsets.only(bottom: 220),
                padding: const EdgeInsets.only(top: 24, bottom: 20),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
              ),
              child: child!,
            ),
            home: grouped
                ? GroupScreen(controller: group)
                : ConversationScreen(
                    controller: chats,
                    chat: chats.byId('sarah'),
                  ),
          ),
        );
        final field = find.widgetWithText(TextField, 'Message');
        await tester.enterText(field, 'Unfinished draft');
        final text = tester.widget<TextField>(field).controller!;
        text.selection = const TextSelection.collapsed(offset: 5);
        await tester.pump();

        for (final online in [false, true]) {
          chats.setOnline(online);
          await tester.pump();
          expect(
            find.text(ChatCopy.offlineQueueDescription),
            online ? findsNothing : findsOneWidget,
          );
          final currentField = tester.widget<TextField>(field);
          expect(currentField.controller, same(text));
          expect(text.text, 'Unfinished draft');
          expect(text.selection.baseOffset, 5);
          expect(currentField.focusNode!.hasFocus, isTrue);
          expect(
            tester.getBottomLeft(find.byTooltip('Send')).dy,
            lessThanOrEqualTo(420),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'group perspectives retain separate drafts and deletion clears them',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      addTearDown(() {
        group.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(home: GroupScreen(controller: group)),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'Owner draft',
      );
      group.setPerspective('sarah');
      await tester.pump();
      expect(find.text('Owner draft'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'Admin draft',
      );
      group.setPerspective('alex');
      await tester.pump();
      expect(find.text('Owner draft'), findsOneWidget);
      expect(find.text('Admin draft'), findsNothing);
      chats.deleteConversation(group.conversation);
      expect(chats.draftFor('design:member:alex'), isEmpty);
      expect(chats.draftFor('design:member:sarah'), isEmpty);
    },
  );

  testWidgets(
    'direct chat draft survives navigation and clears after send or reset',
    (tester) async {
      await tester.pumpWidget(const WhizpeeApp());
      await tester.pumpAndSettle();
      final shell = tester.widget<HomeShell>(find.byType(HomeShell));
      await tester.tap(find.text('Chats').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sarah Wilson').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'A draft',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sarah Wilson').first);
      await tester.pumpAndSettle();
      expect(find.text('A draft'), findsOneWidget);
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      expect(shell.chats.draftFor('sarah'), isEmpty);
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'Another draft',
      );
      shell.chats.reset();
      expect(shell.chats.draftFor('sarah'), isEmpty);
    },
  );

  testWidgets(
    'Business drafts survive expiry and are private to the active perspective',
    (tester) async {
      final wallet = WalletController();
      final business = BusinessController(wallet: wallet);
      final story = StoriesController.stories.first;
      addTearDown(() {
        business.dispose();
        wallet.dispose();
      });
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessConversationScreen(controller: business, story: story),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'Customer draft',
      );
      business.advance(const Duration(hours: 24));
      await tester.pump();
      expect(
        find.text('This room has expired. History is read-only.'),
        findsOneWidget,
      );
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      await tester.pump();
      expect(find.text('Customer draft'), findsOneWidget);
      business.setPerspective(BusinessPerspective.recipient);
      await tester.pump();
      expect(find.text('Customer draft'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'Recipient draft',
      );
      business.setPerspective(BusinessPerspective.customer);
      await tester.pump();
      expect(find.text('Customer draft'), findsOneWidget);
      expect(find.text('Recipient draft'), findsNothing);
      business.reset();
      expect(business.draftFor(story.id), isEmpty);
    },
  );
}
