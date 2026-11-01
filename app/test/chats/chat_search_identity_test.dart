import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_media_edits.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('global message search finds the selected attachment caption', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    final chat = chats.byId('sarah');
    final message = chats.send(
      chat,
      'Sample photo',
      kind: MessageKind.photo,
      mediaEdits: const ChatMediaEdits(caption: 'Weekend picnic'),
    )!;
    await tester.pumpWidget(
      MaterialApp(home: ChatSearchScreen(controller: chats)),
    );
    await tester.enterText(find.byType(TextField), 'picnic');
    await tester.pump();
    await tester.tap(find.text('Sample photo\nWeekend picnic'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ConversationScreen>(find.byType(ConversationScreen))
          .initialMessageId,
      message.id,
    );
  });

  testWidgets(
    'global identity search opens empty chats, retains query and refreshes session edits',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final contact = chats.byId('sarah')..messages.clear();
      addTearDown(chats.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: ChatSearchScreen(controller: chats),
        ),
      );
      await tester.enterText(find.byType(TextField), '  sArAh  ');
      await tester.pump();
      expect(find.text('Conversations'), findsOneWidget);
      await tester.tap(find.text('Sarah Wilson'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ConversationScreen>(find.byType(ConversationScreen)).chat,
        same(contact),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '  sArAh  ',
      );
      chats.renameConversation(contact.id, 'Sarah New');
      await tester.pump();
      expect(find.text('Sarah New'), findsOneWidget);
      expect(find.text('Sarah Wilson'), findsNothing);
      chats.deleteConversation(contact);
      await tester.pump();
      expect(find.text('Sarah New'), findsNothing);
      expect(
        find.text('No matching conversations or messages'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(find.text('Search your conversations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
