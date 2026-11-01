import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'contact call entries invoke the selected type and respect blocking',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final sarah = chats.byId('sarah');
      final actions = <(String, bool)>[];
      chats.onStartCall = (chat, video) => actions.add((chat.id, video));
      await tester.pumpWidget(
        MaterialApp(
          home: ConversationScreen(controller: chats, chat: sarah),
        ),
      );
      await tester.tap(find.byTooltip('Audio call'));
      await tester.tap(find.byTooltip('Video call'));
      expect(actions, [('sarah', false), ('sarah', true)]);
      chats.toggleBlocked(sarah);
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.call_outlined),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.videocam_outlined),
            )
            .onPressed,
        isNull,
      );
    },
  );
}
