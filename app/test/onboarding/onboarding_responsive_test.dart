import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/ui/screens/contacts_access_screen/contacts_access_screen.dart';
import 'package:app/features/onboarding/ui/screens/onboarding_screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    testWidgets(
      'onboarding remains usable at ${size.width.toInt()} × ${size.height.toInt()} with enlarged text',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.viewPadding = FakeViewPadding(top: 24, bottom: 16);
        tester.view.padding = FakeViewPadding(top: 24, bottom: 16);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewPadding);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = OnboardingController();
        var completed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: OnboardingScreen(
              controller: controller,
              onComplete: () => completed = true,
            ),
          ),
        );
        await tester.ensureVisible(find.text('Continue with Google'));
        await tester.tap(find.text('Continue with Google'));
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        expect(find.text('Complete profile'), findsOneWidget);
        final avatar = tester.getRect(find.byType(CircleAvatar));
        final appBar = tester.getRect(find.byType(AppBar));
        expect(avatar.center.dx, closeTo(size.width / 2, 1));
        expect(avatar.top, greaterThanOrEqualTo(appBar.bottom));

        await tester.enterText(
          find.byKey(const ValueKey('profile_name')),
          'Alex Morgan',
        );
        await tester.enterText(
          find.byKey(const ValueKey('phone_local')),
          '+237 670000000',
        );
        tester.view.viewInsets = FakeViewPadding(bottom: 240);
        await tester.pumpAndSettle();
        final profileScroll = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.byType(CheckboxListTile),
          180,
          scrollable: profileScroll,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckboxListTile));
        await tester.scrollUntilVisible(
          find.text('Continue'),
          180,
          scrollable: profileScroll,
        );
        await tester.pumpAndSettle();
        final continueRect = tester.getRect(find.text('Continue'));
        expect(continueRect.bottom, lessThanOrEqualTo(size.height - 240));
        await tester.tap(find.text('Continue'));
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(find.text('Your interests'), findsOneWidget);
        for (final interest in ['Art', 'Music', 'Travel']) {
          await tester.ensureVisible(find.text(interest));
          await tester.tap(find.text(interest));
          await tester.pump();
        }
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Find your contacts'), findsOneWidget);
        await tester.tap(find.text('Allow contacts'));
        await tester.pump();
        expect(find.text('Finding mutual contacts…'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pump();
        expect(find.text('No matching contacts yet'), findsOneWidget);
        await tester.tap(find.text('Continue to Discover'));
        expect(completed, isTrue);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }

  testWidgets(
    'contacts explanation and matching remain scrollable with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = OnboardingController();
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ContactsAccessScreen(
            controller: controller,
            onComplete: () => completed = true,
          ),
        ),
      );
      await tester.ensureVisible(find.text('Allow contacts'));
      await tester.tap(find.text('Allow contacts'));
      await tester.pump();
      expect(find.text('Finding mutual contacts…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      await tester.ensureVisible(find.text('Continue to Discover'));
      await tester.tap(find.text('Continue to Discover'));
      expect(completed, isTrue);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
