import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_media_samples.dart';
import 'package:app/features/chats/models/chat_media_edits.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import 'package:app/features/chats/ui/screens/shared_media_screen/shared_media_screen.dart';
import 'package:app/features/chats/ui/widgets/chat_media_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected photo and video use their own bundled visuals', (
    tester,
  ) async {
    final photo = ChatMessage(
      id: 'photo',
      author: 'Sarah',
      text: 'Sample photo',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.photo,
    );
    final video = ChatMessage(
      id: 'video',
      author: 'Sarah',
      text: 'Sample video',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.video,
    );
    final photoAsset = ChatMediaSamples.assetFor(photo.kind, photo.text)!;
    final videoAsset = ChatMediaSamples.assetFor(video.kind, video.text)!;
    expect(photoAsset, isNot(videoAsset));
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: photo)),
    );
    expect(find.byKey(ValueKey('media-asset-$photoAsset')), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: video)),
    );
    expect(find.byKey(ValueKey('media-asset-$videoAsset')), findsOneWidget);
  });

  testWidgets('audio playback advances, pauses, and stops at its bound', (
    tester,
  ) async {
    final message = ChatMessage(
      id: 'voice',
      author: 'Sarah',
      text: 'Voice note · 0:02',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.audio,
    );
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: message)),
    );
    expect(find.text('00:00 / 00:02'), findsOneWidget);
    await tester.tap(find.byTooltip('Play'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01 / 00:02'), findsOneWidget);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:01 / 00:02'), findsOneWidget);
    await tester.tap(find.byTooltip('Play'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02 / 00:02'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('edited video keeps its caption and selected playback interval', (
    tester,
  ) async {
    const edits = ChatMediaEdits(
      caption: 'A selected moment ✨',
      rotation: 1,
      cropScale: 1.5,
      trimStart: .2,
      trimEnd: .5,
    );
    final message = ChatMessage(
      id: 'trimmed-video',
      author: 'Sarah',
      text: 'Sample video',
      time: DateTime(2026),
      isMine: false,
      kind: MessageKind.video,
      mediaEdits: edits,
    );
    await tester.pumpWidget(
      MaterialApp(home: MediaViewerScreen(message: message)),
    );
    expect(find.text(edits.caption), findsOneWidget);
    expect(find.text('00:00 / 00:09'), findsOneWidget);
    expect(
      tester.widget<ChatMediaVisual>(find.byType(ChatMediaVisual)).edits,
      edits,
    );
    await tester.tap(find.byTooltip('Play'));
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('00:09 / 00:09'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).max, 9000);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shared link stays offline and returns to its source message', (
    tester,
  ) async {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    final message = chats.send(chat, 'See https://example.com/design')!;
    await tester.pumpWidget(
      MaterialApp(
        home: SharedMediaScreen(chat: chat, controller: chats),
      ),
    );
    await tester.tap(find.text('Links'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(message.text));
    await tester.pumpAndSettle();
    expect(find.text('Link preview is unavailable offline.'), findsOneWidget);
    await tester.tap(find.text('Show in chat'));
    await tester.pumpAndSettle();
    final conversation = tester.widget<ConversationScreen>(
      find.byType(ConversationScreen),
    );
    expect(conversation.initialMessageId, message.id);
    await tester.pumpWidget(const SizedBox.shrink());
    chats.dispose();
  });
}
