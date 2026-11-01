import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile photo selection remains a draft until Save', (
    tester,
  ) async {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final profile = OnboardingController();
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(
          profile: profile,
          settings: settings,
          onSaved: () {},
        ),
      ),
    );
    await tester.tap(find.byTooltip('Change profile photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Studio portrait'));
    await tester.pumpAndSettle();
    expect(profile.photoSelected, isFalse);
    await tester.scrollUntilVisible(
      find.text('Save'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(profile.photoSelected, isTrue);
    expect(profile.photoLabel, 'Studio portrait');
    await tester.pumpWidget(const SizedBox.shrink());
    profile.dispose();
    settings.dispose();
    chats.dispose();
  });
}
