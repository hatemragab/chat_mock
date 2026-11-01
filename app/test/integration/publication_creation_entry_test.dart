import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/ui/screens/publications_screen/publications_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openImport(WidgetTester tester) async {
  await tester.tap(find.text('Create publication'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Create Status'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Everyday'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Import media'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Import media'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('creation entry preserves filter and shared media permission', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)
      ..setPermission('Media', MockPermission.permanentlyDenied);
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
        home: PublicationsScreen(controller: publishing, settings: settings),
      ),
    );
    await tester.tap(find.text('Advertisements'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Advertisements'))
          .selected,
      isTrue,
    );
    await openImport(tester);
    expect(find.text('Media access'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(find.text('My Publications'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Advertisements'))
          .selected,
      isTrue,
    );
    expect(settings.permissions['Media'], MockPermission.permanentlyDenied);
  });

  testWidgets('own Story options carry media permission into creation', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)
      ..setPermission('Media', MockPermission.permanentlyDenied);
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final stories = StoriesController(publishing: publishing);
    addTearDown(() {
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
      settings.dispose();
      chats.dispose();
    });
    final own = StoriesController.stories.firstWhere(
      (item) => item.kind == StoryKind.own,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: StoryViewerScreen(
          controller: stories,
          story: own,
          settings: settings,
          initiallyPaused: true,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Story options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Publications'));
    await tester.pumpAndSettle();
    await openImport(tester);
    expect(find.text('Open settings'), findsOneWidget);
    expect(settings.permissions['Media'], MockPermission.permanentlyDenied);
  });
}
