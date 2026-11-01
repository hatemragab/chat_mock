import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/audio_recorder_screen/audio_recorder_screen.dart';
import 'package:app/features/publishing/ui/screens/capture_screen/capture_screen.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/publishing/ui/screens/media_screen/media_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'photo replacement respects shared camera permission and keeps the draft on cancel',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status)
        ..caption = 'Keep this';
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
        settings.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: MediaScreen(
            controller: publishing,
            draft: draft,
            settings: settings,
          ),
        ),
      );
      await tester.tap(find.text('City moments'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      expect(find.text('Camera access'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'City moments');
      expect(draft.caption, 'Keep this');
      expect(settings.permissions['Camera'], MockPermission.denied);
      expect(find.byType(CaptureScreen), findsNothing);
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow in demo'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Camera'], MockPermission.allowed);
      expect(find.byType(CaptureScreen), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Capture'));
      await tester.pump();
      await tester.tap(find.byTooltip('Use capture'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'Camera sample');
      expect(draft.caption, 'Keep this');
    },
  );

  testWidgets(
    'audio replacement recovers shared microphone access and preserves the draft',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats)
        ..setPermission('Microphone', MockPermission.permanentlyDenied);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status)
        ..media = PublicationMedia.audio
        ..caption = 'Voice caption';
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
        settings.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EditorScreen(
            controller: publishing,
            draft: draft,
            settings: settings,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record audio'));
      await tester.pumpAndSettle();
      expect(find.text('Microphone access'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        settings.permissions['Microphone'],
        MockPermission.permanentlyDenied,
      );
      expect(draft.sample, 'Morning light');
      expect(draft.caption, 'Voice caption');
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record audio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Microphone'], MockPermission.allowed);
      expect(find.byType(AudioRecorderScreen), findsOneWidget);
      await tester.tap(find.text('Record'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Stop'));
      await tester.pump();
      await tester.tap(find.text('Use recording'));
      await tester.pumpAndSettle();
      expect(draft.sample, 'Audio recording · 1s');
      expect(draft.caption, 'Voice caption');
    },
  );

  testWidgets(
    'standalone media flow carries its local camera permission into the editor',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status);
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: MediaScreen(controller: publishing, draft: draft),
        ),
      );
      await tester.ensureVisible(find.text('Capture sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capture sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow in demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Capture'));
      await tester.pump();
      await tester.tap(find.byTooltip('Use capture'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Replace or remove media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      expect(find.byType(CaptureScreen), findsOneWidget);
      expect(find.text('Camera access'), findsNothing);
    },
  );
}
