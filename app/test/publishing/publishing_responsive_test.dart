import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/creator_tools/controllers/creator_activity_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/audio_recorder_screen/audio_recorder_screen.dart';
import 'package:app/features/publishing/ui/screens/capture_screen/capture_screen.dart';
import 'package:app/features/publishing/ui/screens/publishing_screen/publishing_screen.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/publishing/ui/screens/publications_screen/publications_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'advertisement creation remains usable at $size in $brightness',
        (tester) async {
          setSize(tester, size);
          final wallet = WalletController();
          final publishing = PublishingController(wallet: wallet);
          final business = BusinessController(wallet: wallet);
          final calls = CallsController(spendCredits: (_, _, _) => true);
          publishing.attachContactActivity(
            CreatorActivityController(business: business, calls: calls),
          );
          final inset = ValueNotifier(0.0);
          addTearDown(() {
            publishing.dispose();
            business.dispose();
            calls.dispose();
            wallet.dispose();
            inset.dispose();
          });
          await pumpApp(
            tester,
            PublishingScreen(controller: publishing),
            brightness,
            inset,
          );
          await tapVisible(tester, find.text('Create Advertisement'));
          await tapVisible(tester, find.text('Design'));
          await tapVisible(tester, find.text('Video'));
          await tapVisible(tester, find.text('City moments'));
          inset.value = 220;
          await tester.pump();
          final caption = find.widgetWithText(TextField, 'Caption');
          await tester.ensureVisible(caption);
          await tester.enterText(caption, 'A complete mock advertisement');
          await tester.pump();
          expect(tester.takeException(), isNull);
          inset.value = 0;
          await tester.pump();
          await tapVisible(tester, find.text('Continue'));
          await tapVisible(tester, find.text('Target area'));
          final city = find.widgetWithText(TextField, 'City (optional)');
          inset.value = 220;
          await tester.pump();
          await scrollTo(tester, city);
          await tester.enterText(city, 'Douala');
          await tester.pump();
          expect(tester.takeException(), isNull);
          inset.value = 0;
          await tester.pump();
          await tapVisible(tester, find.text('Save area'));
          await tapVisible(tester, find.text('Review price'));
          expect(find.text('155 Credits'), findsOneWidget);
          await tapVisible(tester, find.text('Publish'));
          expect(
            publishing.publications.single.caption,
            'A complete mock advertisement',
          );
          expect(publishing.publications.single.city, 'Douala');
          expect(wallet.credits, 2845);
          await tapVisible(tester, find.text('Promotion analytics'));
          expect(
            find.text(
              'Individual viewer identities are not shown for promoted content.',
            ),
            findsOneWidget,
          );
          await scrollTo(tester, find.text('Qualified views · last 7 days'));
          expect(tester.takeException(), isNull);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text('Contact activity'));
          expect(
            find.text('No contact activity for this Story yet.'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        'photo editing and publication actions remain usable at $size in $brightness',
        (tester) async {
          setSize(tester, size);
          final wallet = WalletController();
          final publishing = PublishingController(wallet: wallet);
          final inset = ValueNotifier(0.0);
          addTearDown(() {
            publishing.dispose();
            wallet.dispose();
            inset.dispose();
          });
          final draft = publishing.createDraft(PublicationType.status);
          await pumpApp(
            tester,
            EditorScreen(controller: publishing, draft: draft),
            brightness,
            inset,
          );
          await tapVisible(tester, find.text('Rotate (0°)'));
          expect(draft.rotation, 1);
          await tapVisible(tester, find.text('Change'));
          expect(draft.cover, 'Artwork');
          inset.value = 220;
          await tester.pump();
          await tapVisible(tester, find.text('Boost'));
          await tapVisible(tester, find.text('Cancel'));
          expect(draft.boosted, isFalse);
          inset.value = 0;
          await tester.pump();
          await tapVisible(tester, find.text('Continue'));
          await tapVisible(tester, find.text('Publish'));
          final publication = publishing.publications.single;
          expect(publication.rotation, 1);
          expect(publication.cover, 'Artwork');
          await tapVisible(tester, find.text('Story viewers'));
          expect(find.text('No contact views yet.'), findsOneWidget);
          publishing.recordView(
            publication,
            viewerId: 'sarah',
            viewerName: 'Sarah Wilson',
          );
          await tester.pump();
          expect(find.text('Sarah Wilson'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await pumpApp(
            tester,
            PublicationsScreen(controller: publishing),
            brightness,
            inset,
          );
          await tapVisible(tester, find.text('Advertisements'));
          expect(
            find.text('No publications in this view yet.'),
            findsOneWidget,
          );
          await tapVisible(tester, find.text('Statuses'));
          await tapVisible(tester, find.byTooltip('Publication options'));
          await tapVisible(tester, find.text('Delete publication'));
          await tapVisible(tester, find.text('Cancel'));
          expect(publication.status, PublicationStatus.active);
          await tapVisible(tester, find.byTooltip('Publication options'));
          await tapVisible(tester, find.text('Delete publication'));
          await tapVisible(tester, find.text('Delete'));
          expect(publication.status, PublicationStatus.removed);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );

      testWidgets(
        'capture and audio controls remain usable at $size in $brightness',
        (tester) async {
          setSize(tester, size);
          final wallet = WalletController();
          final publishing = PublishingController(wallet: wallet);
          final inset = ValueNotifier(0.0);
          addTearDown(() {
            publishing.dispose();
            wallet.dispose();
            inset.dispose();
          });
          final video = publishing.createDraft(PublicationType.status)
            ..media = PublicationMedia.video;
          await pumpApp(
            tester,
            CaptureScreen(controller: publishing, draft: video),
            brightness,
            inset,
          );
          await tester.tap(find.text('Record video'));
          await tester.pump(const Duration(seconds: 2));
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Stop recording'));
          await tester.pump();
          expect(find.text('Sample captured'), findsOneWidget);
          await tester.tap(find.text('Retake'));
          await tester.pump();
          expect(find.text('Record video'), findsOneWidget);
          final audio = publishing.createDraft(PublicationType.status)
            ..media = PublicationMedia.audio;
          await pumpApp(
            tester,
            AudioRecorderScreen(controller: publishing, draft: audio),
            brightness,
            inset,
          );
          await tapVisible(tester, find.text('Record'));
          await tester.pump(const Duration(seconds: 2));
          await tapVisible(tester, find.text('Pause'));
          await tapVisible(tester, find.text('Stop'));
          await tapVisible(tester, find.text('Play sample'));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
          await tapVisible(tester, find.text('Pause playback'));
          await tapVisible(tester, find.text('Use recording'));
          expect(audio.sample, 'Audio recording · 2s');
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

void setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> pumpApp(
  WidgetTester tester,
  Widget home,
  Brightness brightness,
  ValueNotifier<double> inset,
) async {
  await tester.pumpWidget(
    ValueListenableBuilder<double>(
      valueListenable: inset,
      builder: (context, value, _) => MaterialApp(
        theme: AppTheme.create(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
            viewInsets: EdgeInsets.only(bottom: value),
          ),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      160,
      scrollable: find.byType(Scrollable).first,
    );
  } else {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}
