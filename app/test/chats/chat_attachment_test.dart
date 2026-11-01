import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/widgets/chat_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upload failure can be retried without creating a duplicate', () {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    chats.failNextUpload = true;
    final message = chats.send(
      chat,
      'Design brief.pdf',
      kind: MessageKind.document,
      upload: true,
    )!;
    for (var i = 0; i < 4; i++) {
      chats.advanceUpload(message);
    }
    expect(message.uploadState, UploadState.failed);
    expect(message.status, DeliveryStatus.failed);
    chats.retry(message);
    expect(message.uploadProgress, 0);
    for (var i = 0; i < 4; i++) {
      chats.advanceUpload(message);
    }
    expect(message.uploadState, UploadState.complete);
    expect(chat.messages.where((item) => item.id == message.id), hasLength(1));
    chats.dispose();
  });

  test(
    'queued attachment resumes on reconnect and restriction prevents sending',
    () {
      final chats = ChatsController();
      final chat = chats.byId('sarah');
      chats.setOnline(false);
      final message = chats.send(
        chat,
        'Sample photo',
        kind: MessageKind.photo,
        upload: true,
      )!;
      expect(message.uploadState, UploadState.queued);
      chats.setOnline(true);
      expect(message.uploadState, UploadState.uploading);
      chats.advanceUpload(message);
      chats.setOnline(false);
      expect(message.uploadState, UploadState.queued);
      chats.setOnline(true);
      for (var i = 0; i < 3; i++) {
        chats.advanceUpload(message);
      }
      expect(message.uploadState, UploadState.complete);
      chats.canMessage = () => false;
      expect(chats.send(chat, 'blocked'), isNull);
      expect(
        chats.send(
          chat,
          'blocked.pdf',
          kind: MessageKind.document,
          upload: true,
        ),
        isNull,
      );
      chats.dispose();
    },
  );

  testWidgets('attachment preview sends a typed file and opens its preview', (
    tester,
  ) async {
    final chats = ChatsController();
    addTearDown(chats.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(controller: chats, chat: chats.byId('sarah')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Attach'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document'));
    await tester.pumpAndSettle();
    expect(find.text('Preview attachment'), findsOneWidget);
    await tester.tap(find.text('Send attachment'));
    await tester.pump();
    expect(chats.byId('sarah').messages.last.kind, MessageKind.document);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design brief.pdf').last);
    await tester.pumpAndSettle();
    expect(find.text('File preview'), findsOneWidget);
    expect(find.text('Download sample'), findsOneWidget);
  });

  testWidgets('voice recording can lock, stop, and send its actual duration', (
    tester,
  ) async {
    final durations = <Duration>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            onSend: (_) => true,
            onAttachment: () {},
            onSendVoice: durations.add,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Record voice note'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byTooltip('Lock recording'));
    await tester.pump();
    expect(find.textContaining('Recording locked'), findsOneWidget);
    await tester.tap(find.byTooltip('Stop recording'));
    await tester.pump();
    expect(find.textContaining('Voice note ready'), findsOneWidget);
    await tester.tap(find.byTooltip('Send voice note'));
    await tester.pump();
    expect(durations.single, const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'reset restores seeded IDs, cancels uploads and preserves guards',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final seedIds = chats
          .byId('sarah')
          .messages
          .map((message) => message.id)
          .toList();
      chats.setSendGuard('design', () => false);
      final old = chats.send(
        chats.byId('sarah'),
        'Pending video',
        kind: MessageKind.video,
        upload: true,
      )!;
      chats.reset();
      expect(
        chats.byId('sarah').messages.map((message) => message.id),
        seedIds,
      );
      expect(chats.canSendTo(chats.byId('design')), isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(old.uploadProgress, 0);
    },
  );
  test('queued attachments do not resume while the room is restricted', () {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    var allowed = true;
    chats.setSendGuard(chat.id, () => allowed);
    chats.setOnline(false);
    final message = chats.send(
      chat,
      'Photo',
      kind: MessageKind.photo,
      upload: true,
    )!;
    allowed = false;
    chats.setOnline(true);
    chats.retry(message);
    expect(message.uploadState, UploadState.queued);
    allowed = true;
    chats.retry(message);
    expect(message.uploadState, UploadState.uploading);
    allowed = false;
    chats.advanceUpload(message);
    expect(message.uploadState, UploadState.queued);
    expect(message.uploadProgress, 0);
    chats.dispose();
  });
}
