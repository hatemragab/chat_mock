import 'package:app/app/app.dart';
import 'package:app/features/profile/ui/screens/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> scrollProfileTo(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    250,
    scrollable: find
        .descendant(
          of: find.byType(ProfileScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

void main() {
  testWidgets('sign out and finish onboarding without granting contacts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await scrollProfileTo(tester, 'Sign out');
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    await tester.tap(find.text('Continue with Google'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile_name')),
      'Alex Morgan',
    );
    await tester.enterText(
      find.byKey(const ValueKey('phone_local')),
      '+20 1234567890',
    );
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    for (final interest in ['Art', 'Music', 'Travel']) {
      await tester.ensureVisible(find.text(interest));
      await tester.tap(find.text(interest));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Explore stories'), findsOneWidget);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await scrollProfileTo(tester, 'Settings');
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permissions and contact sync'));
    await tester.pumpAndSettle();
    final contacts = find.widgetWithText(ListTile, 'Contacts');
    expect(contacts, findsOneWidget);
    expect(
      find.descendant(of: contacts, matching: find.text('Denied')),
      findsOneWidget,
    );
  });
}
