import 'package:app/features/business/ui/screens/own_business_profile_screen/own_business_profile_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'saved mock Business artwork appears and removal updates the profile',
    (tester) async {
      final chats = ChatsController();
      final settings = SettingsController(chats: chats);
      final stories = StoriesController();
      settings.saveBusinessProfile(
        const BusinessProfile(
          name: 'Creative Studio',
          category: 'Design',
          description: 'A local design studio.',
          coverSelected: true,
          logoSelected: true,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: OwnBusinessProfileScreen(settings: settings, stories: stories),
        ),
      );
      await tester.pumpAndSettle();
      final cover = find.byWidgetPredicate(
        (widget) =>
            widget is Image && widget.semanticLabel == 'Public Business cover',
      );
      final logo = find.byWidgetPredicate(
        (widget) =>
            widget is Image && widget.semanticLabel == 'Public Business logo',
      );
      expect(
        tester.widget<Image>(cover).image,
        const AssetImage(BusinessProfile.demoCoverAssetPath),
      );
      expect(
        tester.widget<Image>(logo).image,
        const AssetImage(BusinessProfile.demoLogoAssetPath),
      );
      settings.saveBusinessProfile(
        const BusinessProfile(
          name: 'Creative Studio',
          category: 'Design',
          description: 'A local design studio.',
        ),
      );
      await tester.pump();
      expect(cover, findsNothing);
      expect(logo, findsNothing);
      expect(find.text('Creative Studio'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
      settings.dispose();
      chats.dispose();
    },
  );
}
