import 'package:app/app/app.dart';
import 'package:app/features/profile/ui/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'saved demo portrait appears on Profile and removal restores initials',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WhizpeeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).photoLabel,
        isNull,
      );
      await tester.ensureVisible(find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Change profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outdoor portrait'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).photoLabel,
        'Outdoor portrait',
      );
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).photoLabel,
        'Outdoor portrait',
      );
      await tester.ensureVisible(find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Change profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove profile photo'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester.widget<ProfileAvatar>(find.byType(ProfileAvatar)).photoLabel,
        isNull,
      );
    },
  );
}
