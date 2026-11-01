import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/publishing/ui/screens/capture_screen/capture_screen.dart';
import 'package:app/features/publishing/ui/screens/audio_recorder_screen/audio_recorder_screen.dart';
import 'package:app/features/publishing/ui/screens/media_screen/media_screen.dart';
import 'package:app/features/publishing/ui/screens/publishing_screen/publishing_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'camera capture requests simulated permission without using hardware',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status);
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
      await tester.ensureVisible(find.text('Capture sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Capture sample'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('device camera will not be used'),
        findsOneWidget,
      );
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Camera'], MockPermission.denied);
      expect(find.byType(CaptureScreen), findsNothing);
      await tester.tap(find.text('Capture sample'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow in demo'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Camera'], MockPermission.allowed);
      expect(find.byType(CaptureScreen), findsOneWidget);
    },
  );

  testWidgets(
    'microphone recording offers simulated recovery when denied permanently',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats)
        ..setPermission('Microphone', MockPermission.permanentlyDenied);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final draft = publishing.createDraft(PublicationType.status)
        ..media = PublicationMedia.audio;
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
      await tester.ensureVisible(find.text('Record audio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record audio'));
      await tester.pumpAndSettle();
      expect(find.text('Microphone access'), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Microphone'], MockPermission.allowed);
      expect(find.byType(AudioRecorderScreen), findsOneWidget);
      expect(settings.permissions['Camera'], MockPermission.denied);
    },
  );

  testWidgets('simulated import is usable on a short screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)
      ..setPermission('Media', MockPermission.allowed);
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.status);
    addTearDown(() {
      publishing.dispose();
      wallet.dispose();
      settings.dispose();
      chats.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: MediaScreen(
          controller: publishing,
          draft: draft,
          settings: settings,
        ),
      ),
    );
    await tester.ensureVisible(find.text('Import media'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Creative studio').last);
    await tester.pumpAndSettle();
    expect(find.byType(EditorScreen), findsOneWidget);
    expect(draft.sample, 'Creative studio');
    expect(tester.takeException(), isNull);
  });

  testWidgets('declining media access leaves bundled samples available', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.status);
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
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Your device files will not be read.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(settings.permissions['Media'], MockPermission.denied);
    await tester.tap(find.text('City moments'));
    await tester.pumpAndSettle();
    expect(find.byType(EditorScreen), findsOneWidget);
    expect(draft.sample, 'City moments');
  });

  testWidgets(
    'simulated import shares permission and preserves selected media type',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      addTearDown(() {
        publishing.dispose();
        wallet.dispose();
        settings.dispose();
        chats.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: PublishingScreen(controller: publishing, settings: settings),
        ),
      );
      await tester.tap(find.text('Create Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everyday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Video'));
      await tester.pump();
      await tester.tap(find.text('Import media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow in demo'));
      await tester.pumpAndSettle();
      expect(settings.permissions['Media'], MockPermission.allowed);
      expect(find.text('Simulated import'), findsOneWidget);
      expect(
        find.text('Choose a demo sample; no device files are read.'),
        findsOneWidget,
      );
      await tester.tap(find.text('City moments').last);
      await tester.pumpAndSettle();
      final editor = tester.widget<EditorScreen>(find.byType(EditorScreen));
      expect(editor.draft.sample, 'City moments');
      expect(editor.draft.media, PublicationMedia.video);
    },
  );

  testWidgets('permanently denied media access supports cancel and recovery', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)
      ..setPermission('Media', MockPermission.permanentlyDenied);
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.status);
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
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.permissions['Media'], MockPermission.permanentlyDenied);
    await tester.tap(find.text('Import media'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(settings.permissions['Media'], MockPermission.allowed);
    expect(find.text('Simulated import'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(draft.sample, 'Morning light');
  });
}
