import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'public fixture profile has its own identity details and Story entry',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final wallet = WalletController();
      final business = BusinessController(wallet: wallet);
      final story = StoriesController.stories.first;
      final profile = business.profileFor(story);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: BusinessProfileScreen(controller: business, story: story),
        ),
      );
      expect(profile.description, isNot(story.title));
      expect(find.byType(Image), findsOneWidget);
      await tester.scrollUntilVisible(find.text(profile.description), 150);
      expect(find.text(profile.description), findsOneWidget);
      await tester.scrollUntilVisible(find.text(profile.location), 150);
      expect(find.text(profile.location), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Contact about this Story'),
        150,
      );
      await tester.tap(find.text('Contact about this Story'));
      await tester.pumpAndSettle();
      expect(find.text('Contact Maison Studio'), findsOneWidget);
      expect(find.text('From “${story.title}”'), findsOneWidget);
      expect(wallet.credits, 3000);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      business.dispose();
      wallet.dispose();
    },
  );

  test('linked own Story exposes public Business fields without private profile data', () {
    final wallet = WalletController();
    final chats = ChatsController();
    final settings = SettingsController(chats: chats)
      ..setAbout('Private personal information');
    settings.saveBusinessProfile(
      const BusinessProfile(
        name: 'Public Studio',
        category: 'Design',
        description: 'Public studio description',
        location: 'Public studio location',
        logoSelected: true,
        coverSelected: true,
      ),
    );
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.status)
      ..boosted = true;
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final stories = StoriesController(publishing: publishing);
    final source = stories.allStories.firstWhere(
      (story) => story.id == draft.id,
    );
    expect(settings.linkBusinessStory(source), isTrue);
    final business = BusinessController(
      wallet: wallet,
      chats: chats,
      stories: stories,
      settings: settings,
    );
    final profile = business.profileFor(source.withAuthor('Public Studio'));
    expect(profile.name, 'Public Studio');
    expect(profile.description, 'Public studio description');
    expect(profile.location, 'Public studio location');
    expect(profile.logoAssetPath, BusinessProfile.demoLogoAssetPath);
    expect(profile.coverAssetPath, BusinessProfile.demoCoverAssetPath);
    expect(profile.description, isNot(settings.about));
    business.dispose();
    stories.dispose();
    publishing.dispose();
    settings.dispose();
    chats.dispose();
    wallet.dispose();
  });
}
