import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/attachment_preview_screen/attachment_preview_screen.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import 'package:app/features/chats/ui/widgets/chat_media_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'photo edits survive a short-phone keyboard, send, forward and viewer navigation',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final chat = chats.byId('sarah');
      final inset = ValueNotifier(0.0);
      addTearDown(chats.dispose);
      addTearDown(inset.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ValueListenableBuilder<double>(
            valueListenable: inset,
            builder: (_, keyboard, _) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewInsets: EdgeInsets.only(bottom: keyboard),
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            ),
          ),
          home: ConversationScreen(controller: chats, chat: chat),
        ),
      );
      await openMedia(tester, 'Photo library');
      await tapVisible(tester, find.text('Rotate (0°)'));
      final crop = tester.widget<Slider>(find.byType(Slider));
      crop.onChanged!(1.5);
      await tester.pump();
      inset.value = 220;
      await tester.pump();
      final caption = find.widgetWithText(TextField, 'Caption');
      await scrollTo(tester, caption);
      await tester.enterText(caption, 'A local photo caption');
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomLeft(find.text('Send attachment')).dy,
        lessThan(420),
      );
      inset.value = 0;
      await tester.pump();
      await tapVisible(tester, find.text('Replace media'));
      await tester.tap(find.text('Studio photo'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Change cover'));
      await tester.tap(find.text('Send attachment'));
      await tester.pumpAndSettle();
      final message = chat.messages.last;
      expect(message.kind, MessageKind.photo);
      expect(message.text, 'Studio photo');
      expect(message.mediaEdits!.caption, 'A local photo caption');
      expect(message.mediaEdits!.rotation, 1);
      expect(message.mediaEdits!.cropScale, 1.5);
      expect(message.mediaEdits!.artworkCover, isTrue);
      expect(message.assetPath, 'assets/story/green_corner.png');
      final recipient = chats.byId('amira');
      chats.forward(message, [recipient]);
      expect(recipient.messages.last.mediaEdits, same(message.mediaEdits));
      expect(recipient.messages.last.assetPath, message.assetPath);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(message.uploadState, UploadState.complete);
      await tapVisible(tester, find.text('A local photo caption'));
      expect(find.byType(MediaViewerScreen), findsOneWidget);
      expect(find.text('A local photo caption'), findsOneWidget);
      final visual = tester.widget<ChatMediaVisual>(
        find.descendant(
          of: find.byType(MediaViewerScreen),
          matching: find.byType(ChatMediaVisual),
        ),
      );
      expect(visual.edits, same(message.mediaEdits));
      expect(visual.assetPath, message.assetPath);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('video replacement and trim bound editor and sent playback', (
    tester,
  ) async {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    addTearDown(chats.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(controller: chats, chat: chat),
      ),
    );
    await openMedia(tester, 'Video library');
    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      const RangeValues(.2, .3),
    );
    await tester.pump();
    await tapVisible(tester, find.text('Play'));
    await tester.pump(const Duration(seconds: 4));
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .3,
    );
    expect(find.text('Play'), findsOneWidget);
    await tapVisible(tester, find.text('Replace media'));
    await tester.tap(find.text('Garden video'));
    await tester.pumpAndSettle();
    final caption = find.widgetWithText(TextField, 'Caption');
    await scrollTo(tester, caption);
    await tester.enterText(caption, 'Trimmed clip');
    await tester.tap(find.text('Send attachment'));
    await tester.pumpAndSettle();
    final message = chat.messages.last;
    expect(message.text, 'Garden video');
    expect(message.assetPath, 'assets/story/green_corner.png');
    expect(
      (message.mediaEdits!.trimStart, message.mediaEdits!.trimEnd),
      (.2, .3),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(message.uploadState, UploadState.complete);
    await tapVisible(tester, find.text('Trimmed clip'));
    expect(find.byType(MediaViewerScreen), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).max, 3000);
    await tapVisible(tester, find.byTooltip('Play'));
    await tester.pump(const Duration(seconds: 4));
    expect(tester.widget<Slider>(find.byType(Slider)).value, 3000);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('closing a media editor creates no message', (tester) async {
    final chats = ChatsController();
    final chat = chats.byId('sarah');
    addTearDown(chats.dispose);
    final before = chat.messages.length;
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(controller: chats, chat: chat),
      ),
    );
    await openMedia(tester, 'Photo library');
    await tester.enterText(
      find.widgetWithText(TextField, 'Caption'),
      'Discard me',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AttachmentPreviewScreen), findsNothing);
    expect(chat.messages, hasLength(before));
  });
}

Future<void> openMedia(WidgetTester tester, String source) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Attach'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(source));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final scrollable = find.byType(Scrollable).first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(finder, 120, scrollable: scrollable);
    }
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
