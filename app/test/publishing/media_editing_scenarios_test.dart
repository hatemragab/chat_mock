import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/audio_recorder_screen/audio_recorder_screen.dart';
import 'package:app/features/publishing/ui/screens/capture_screen/capture_screen.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/stories/ui/widgets/story_media_background.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('audio playback completes and re-record resets the sample', (
    tester,
  ) async {
    final wallet = WalletController();
    final controller = PublishingController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    final draft = controller.createDraft(PublicationType.status)
      ..media = PublicationMedia.audio;
    await tester.pumpWidget(
      MaterialApp(
        home: AudioRecorderScreen(controller: controller, draft: draft),
      ),
    );
    await tester.tap(find.text('Record'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Stop'));
    await tester.pump();
    await tester.tap(find.text('Play sample'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Play sample'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
    await tester.tap(find.text('Re-record'));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Use recording'), findsNothing);
  });

  testWidgets(
    'audio can be removed, re-recorded and previewed without losing caption',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..media = PublicationMedia.audio
        ..caption = 'Keep my caption';
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(controller: controller, draft: draft),
        ),
      );
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove audio'));
      await tester.pumpAndSettle();
      expect(draft.sample, isEmpty);
      await tester.ensureVisible(find.text('Play preview'));
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Play preview'),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byTooltip('Choose media'));
      await tester.tap(find.byTooltip('Choose media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record audio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Pause'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:02'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Stop'));
      await tester.pump();
      await tester.tap(find.text('Play sample'));
      await tester.pump(const Duration(milliseconds: 600));
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, greaterThan(0));
      await tester.ensureVisible(find.text('Use recording'));
      await tester.tap(find.text('Use recording'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'Audio recording · 3s');
      expect(draft.caption, 'Keep my caption');
      expect(find.textContaining('Audio recording · 3s'), findsOneWidget);
    },
  );

  testWidgets(
    'audio recorder imports a local sample and returns to the existing editor',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..media = PublicationMedia.audio
        ..caption = 'Existing draft';
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(controller: controller, draft: draft),
        ),
      );
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record audio'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Import sample'));
      await tester.tap(find.text('Import sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('City moments'));
      await tester.pumpAndSettle();
      expect(find.byType(EditorScreen), findsOneWidget);
      expect(draft.sample, 'City moments');
      expect(draft.caption, 'Existing draft');
    },
  );

  testWidgets(
    'video capture records, retakes and returns the final simulated clip',
    (tester) async {
      final wallet = WalletController();
      final controller = PublishingController(wallet: wallet);
      addTearDown(controller.dispose);
      addTearDown(wallet.dispose);
      final draft = controller.createDraft(PublicationType.status)
        ..media = PublicationMedia.video;
      await tester.pumpWidget(
        MaterialApp(
          home: CaptureScreen(controller: controller, draft: draft),
        ),
      );
      await tester.tap(find.byTooltip('Switch camera'));
      await tester.tap(find.text('Record video'));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Recording video · 3s'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.cameraswitch_outlined),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Stop recording'));
      await tester.pump();
      await tester.tap(find.text('Retake'));
      await tester.pump();
      await tester.tap(find.text('Record video'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Stop recording'));
      await tester.pump();
      await tester.tap(find.byTooltip('Use capture'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'Front camera sample · 2s video');
      expect(find.byType(EditorScreen), findsOneWidget);
    },
  );

  testWidgets('photo cover selection updates its local preview', (
    tester,
  ) async {
    final wallet = WalletController();
    final controller = PublishingController(wallet: wallet);
    addTearDown(controller.dispose);
    addTearDown(wallet.dispose);
    final draft = controller.createDraft(PublicationType.status)
      ..sample = 'City moments';
    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(controller: controller, draft: draft),
      ),
    );
    final before = tester
        .widget<StoryMediaBackground>(find.byType(StoryMediaBackground))
        .story
        .assetPath;
    await tester.ensureVisible(find.text('Change'));
    await tester.tap(find.text('Change'));
    await tester.pump();
    final after = tester
        .widget<StoryMediaBackground>(find.byType(StoryMediaBackground))
        .story
        .assetPath;
    expect(draft.cover, 'Artwork');
    expect(after, isNot(before));
  });
}
