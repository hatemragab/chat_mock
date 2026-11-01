import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_file_metadata.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import 'package:app/features/chats/ui/screens/shared_media_screen/shared_media_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'selected file shows its metadata, simulates open and download, and returns to source',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final chat = chats.byId('sarah');
      final file = chats.send(
        chat,
        'Customer proposal.pdf',
        kind: MessageKind.document,
        fileMetadata: const ChatFileMetadata(
          fileName: 'Customer proposal.pdf',
          mimeType: 'application/pdf',
          byteLength: 1536,
        ),
      )!;
      await tester.pumpWidget(
        MaterialApp(
          home: SharedMediaScreen(chat: chat, controller: chats),
        ),
      );
      await tester.tap(find.text('Files'));
      await tester.pump();
      await tester.tap(find.text(file.text));
      await tester.pumpAndSettle();
      expect(find.text('File type: application/pdf'), findsOneWidget);
      expect(find.text('File size: 1.5 KB'), findsOneWidget);
      await tester.tap(find.text('Open sample'));
      await tester.pump();
      expect(find.text('Opened in simulation'), findsOneWidget);
      await tester.tap(find.text('Download sample'));
      await tester.pump();
      expect(find.text('Saved in demo'), findsOneWidget);
      await tester.tap(find.text('Show in chat'));
      await tester.pumpAndSettle();
      final destination = tester.widget<ConversationScreen>(
        find.byType(ConversationScreen),
      );
      expect(destination.chat, same(chat));
      expect(destination.initialMessageId, file.id);
      expect(
        chat.messages.where((message) => message.id == file.id),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unsupported file metadata cannot expose an open action', (
    tester,
  ) async {
    final file = ChatMessage(
      id: 'unsupported',
      author: 'Sarah',
      text: 'Design preview.pdf',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.document,
      fileMetadata: const ChatFileMetadata(
        fileName: 'Design preview.pdf',
        mimeType: 'application/x-sketch',
        byteLength: 2 * 1024 * 1024,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: file)),
    );
    expect(find.text('File type: application/x-sketch'), findsOneWidget);
    expect(find.text('File size: 2.0 MB'), findsOneWidget);
    expect(find.text('Unsupported file preview'), findsOneWidget);
    expect(find.text('Open sample'), findsNothing);
    await tester.tap(find.text('Download sample'));
    await tester.pump();
    expect(find.text('Saved in demo'), findsOneWidget);
    expect(find.text('Open sample'), findsNothing);
  });
}
