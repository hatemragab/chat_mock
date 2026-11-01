import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/price_review_screen/price_review_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets('inner forms and group fit $size in ${brightness.name}', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chats = ChatsController();
        final group = GroupController(chats: chats);
        final profile = OnboardingController();
        final settings = SettingsController(chats: chats);
        final wallet = WalletController();
        final publishing = PublishingController(wallet: wallet);
        final screens = <Widget>[
          EditProfileScreen(
            profile: profile,
            settings: settings,
            onSaved: () {},
          ),
          ConvertDiamondsScreen(controller: wallet),
          PriceReviewScreen(
            controller: publishing,
            draft: publishing.createDraft(PublicationType.status),
          ),
          GroupScreen(controller: group),
        ];
        for (final screen in screens) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  viewInsets: const EdgeInsets.only(bottom: 200),
                ),
                child: child!,
              ),
              home: screen,
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} should fit',
          );
          await tester.pumpWidget(const SizedBox.shrink());
        }
        publishing.dispose();
        wallet.dispose();
        settings.dispose();
        profile.dispose();
        group.dispose();
        chats.dispose();
      });
    }
  }
}
