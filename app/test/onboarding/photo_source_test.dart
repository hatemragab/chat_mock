import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/ui/screens/complete_profile_screen/complete_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'photo source changes only after selection and removal is explicit',
    (tester) async {
      final controller = OnboardingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: CompleteProfileScreen(
            controller: controller,
            onComplete: () {},
          ),
        ),
      );
      await tester.tap(find.byTooltip('Choose profile photo'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(controller.photoSelected, isFalse);
      await tester.tap(find.byTooltip('Choose profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Studio portrait'));
      await tester.pumpAndSettle();
      expect(controller.photoSelected, isTrue);
      expect(controller.photoLabel, 'Studio portrait');
      await tester.tap(find.byTooltip('Choose profile photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove profile photo'));
      await tester.pumpAndSettle();
      expect(controller.photoSelected, isFalse);
      expect(controller.photoLabel, isNull);
    },
  );

  testWidgets('camera capture and retake use only simulated state', (
    tester,
  ) async {
    final controller = OnboardingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CompleteProfileScreen(controller: controller, onComplete: () {}),
      ),
    );
    await tester.tap(find.byTooltip('Choose profile photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(controller.photoSelected, isFalse);
    await tester.tap(find.text('Capture'));
    await tester.pump();
    await tester.tap(find.text('Retake'));
    await tester.pump();
    expect(controller.photoSelected, isFalse);
    await tester.tap(find.text('Capture'));
    await tester.pump();
    await tester.tap(find.byTooltip('Use photo'));
    await tester.pumpAndSettle();
    expect(controller.photoLabel, 'Front camera photo');
  });
}
