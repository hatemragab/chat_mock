import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/business/ui/screens/own_business_profile_screen/own_business_profile_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/settings/ui/screens/blocked_accounts_screen/blocked_accounts_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('blocking a public Business updates its rooms and does not debit or create a detached room', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final stories = StoriesController();
    final wallet = WalletController();
    final business = BusinessController(
      wallet: wallet,
      chats: chats,
      stories: stories,
      settings: settings,
    );
    final source = StoriesController.stories.first;
    final sameBusiness = Story(
      id: 'another-maison-story',
      author: source.author,
      title: 'Another Story',
      category: source.category,
      kind: StoryKind.business,
      media: StoryMedia.photo,
      colors: source.colors,
    );
    final before = chats.conversations.length;
    business.setBlocked(source, true);
    expect(settings.blockedBusinessNames, contains(source.author));
    expect(
      business.openRoom(sameBusiness, confirmed: true),
      OpenRoomResult.blocked,
    );
    expect(chats.conversations.length, before);
    expect(wallet.credits, 3000);
    expect(business.send(source.id, 'Blocked'), isFalse);
    settings.setBusinessBlocked(source.author, false);
    expect(business.isBlocked(source), isFalse);
    expect(business.openRoom(source, confirmed: true), OpenRoomResult.opened);
    business.dispose();
    stories.dispose();
    settings.dispose();
    chats.dispose();
    wallet.dispose();
  });

  test(
    'Business voice upload shares the room and wallet debit is not repeated',
    () {
      final chats = ChatsController();
      final stories = StoriesController();
      final wallet = WalletController();
      final business = BusinessController(
        wallet: wallet,
        chats: chats,
        stories: stories,
      );
      final source = StoriesController.stories.first;
      expect(business.openRoom(source, confirmed: true), OpenRoomResult.opened);
      expect(
        business.send(
          source.id,
          'Voice note · 0:03',
          kind: MessageKind.audio,
          upload: true,
        ),
        isTrue,
      );
      final message = business.roomFor(source.id)!.messages.last;
      expect(
        identical(
          chats.businessConversation(source.id)!.messages.last,
          message,
        ),
        isTrue,
      );
      expect(message.uploadState, UploadState.uploading);
      for (var i = 0; i < 4; i++) {
        chats.advanceUpload(message);
      }
      expect(message.uploadState, UploadState.complete);
      expect(wallet.credits, 2990);
      expect(wallet.activity.where((item) => item.amount == -10).length, 1);
      business.dispose();
      stories.dispose();
      chats.dispose();
      wallet.dispose();
    },
  );

  testWidgets(
    'report and block retain the originating Story and unblock from Privacy',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final stories = StoriesController();
      final wallet = WalletController();
      final business = BusinessController(
        wallet: wallet,
        chats: chats,
        stories: stories,
        settings: settings,
      );
      addTearDown(() {
        business.dispose();
        stories.dispose();
        settings.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final source = StoriesController.stories.first;
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessProfileScreen(controller: business, story: source),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Report ${source.author}'),
        150,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report ${source.author}'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ReportScreen>(find.byType(ReportScreen)).targetId,
        source.id,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Block ${source.author}'), 150);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block ${source.author}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block').last);
      await tester.pumpAndSettle();
      expect(find.text('This Business is blocked.'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(home: BlockedAccountsScreen(controller: settings)),
      );
      await tester.pumpAndSettle();
      expect(find.text(source.author), findsOneWidget);
      await tester.tap(find.text('Unblock'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unblock').last);
      await tester.pumpAndSettle();
      expect(settings.isBusinessBlocked(source.author), isFalse);
    },
  );

  testWidgets(
    'own public preview uses edited Business identity only after explicit Story linking',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
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
      settings.saveBusinessProfile(
        const BusinessProfile(
          name: 'Luma Studio',
          category: 'Design',
          description: 'Public creative studio',
        ),
      );
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..caption = 'Studio collection';
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: OwnBusinessProfileScreen(settings: settings, stories: stories),
        ),
      );
      expect(
        find.text(
          'There are no linked active Stories on this Business profile.',
        ),
        findsOneWidget,
      );
      expect(find.text('Contact about this Story'), findsNothing);
      await tester.tap(find.text('Link a Story'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Studio collection').last);
      await tester.pumpAndSettle();
      expect(find.text('Studio collection'), findsOneWidget);
      expect(find.text('Alex Morgan'), findsNothing);
      await tester.tap(find.text('Studio collection'));
      await tester.pumpAndSettle();
      expect(find.text('Luma Studio'), findsWidgets);
      expect(find.text('Alex Morgan'), findsNothing);
    },
  );
  testWidgets(
    'Business conversation sends sample document and simulated voice without another room charge',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final chats = ChatsController();
      final stories = StoriesController();
      final wallet = WalletController();
      final business = BusinessController(
        wallet: wallet,
        chats: chats,
        stories: stories,
      );
      addTearDown(() {
        business.dispose();
        stories.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final story = StoriesController.stories.first;
      expect(business.openRoom(story, confirmed: true), OpenRoomResult.opened);
      await tester.pumpWidget(
        MaterialApp(
          home: BusinessConversationScreen(controller: business, story: story),
        ),
      );
      await tester.tap(find.byTooltip('Attach'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send attachment'));
      await tester.pumpAndSettle();
      expect(
        business.roomFor(story.id)!.messages.last.kind,
        MessageKind.document,
      );
      await tester.tap(find.byTooltip('Record voice note'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byTooltip('Send voice note'));
      await tester.pump();
      final voice = business.roomFor(story.id)!.messages.last;
      expect(voice.kind, MessageKind.audio);
      for (var i = 0; i < 4; i++) {
        chats.advanceUpload(voice);
      }
      expect(voice.uploadState, UploadState.complete);
      expect(wallet.credits, 2990);
    },
  );
}
