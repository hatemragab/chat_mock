import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/onboarding/models/phone_number.dart';
import 'package:app/features/onboarding/ui/screens/interests_screen/interests_screen.dart';
import 'package:app/features/onboarding/ui/screens/contacts_access_screen/contacts_access_screen.dart';
import 'package:app/features/onboarding/ui/screens/onboarding_screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('international phone entry', () {
    const initial = PhoneNumber(
      country: PhoneCountry('Cameroon', '+237'),
      local: '',
    );

    test('pasted plus and 00 numbers update prefix and local number', () {
      final egypt = initial.withInput('+20 123 456 7890');
      expect(egypt.country.code, '+20');
      expect(egypt.local, '1234567890');
      expect(egypt.international, '+201234567890');
      expect(egypt.validationError, isNull);

      final cameroon = egypt.withInput('00237 612 345 678');
      expect(cameroon.country.code, '+237');
      expect(cameroon.international, '+237612345678');
      expect(cameroon.validationError, isNull);
    });

    test('rejects empty, too short and unsupported international numbers', () {
      expect(initial.validationError, isNotNull);
      expect(initial.withInput('12').validationError, isNotNull);
      expect(
        initial.withInput('+9991234567').validationError,
        contains('country'),
      );
    });
  });

  testWidgets(
    'onboarding validates profile and interests and allows contacts to be declined',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
      await tester.tap(find.text('Continue with Google'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      expect(find.text('Complete profile'), findsOneWidget);

      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pump();
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter your phone number.'), findsOneWidget);
      expect(find.text('Please accept the terms to continue.'), findsOneWidget);

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
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(controller.phone.international, '+201234567890');
      expect(find.text('Your interests'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Select at least three interests.'), findsOneWidget);
      for (final interest in ['Art', 'Music', 'Travel']) {
        await tester.ensureVisible(find.text(interest));
        await tester.tap(find.text(interest));
        await tester.pump();
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Find your contacts'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pump();
      expect(completed, isTrue);
      expect(controller.contactsState, ContactsState.denied);
      expect(controller.interests, containsAll(['Art', 'Music', 'Travel']));
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('sign-in cancellation keeps the welcome screen available', (
    tester,
  ) async {
    final controller = OnboardingController();
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(controller: controller, onComplete: () {}),
      ),
    );
    await tester.tap(find.text('Continue with Apple'));
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sign-in cancelled. You can try again.'), findsOneWidget);
    expect(find.text('Complete profile'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('opening legal information cancels pending sign-in navigation', (
    tester,
  ) async {
    final controller = OnboardingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(controller: controller, onComplete: () {}),
      ),
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.tap(find.text('Terms of Service'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('Complete profile'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sign-in cancelled. You can try again.'), findsOneWidget);
    await tester.tap(find.text('Continue with Google'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();
    expect(find.text('Complete profile'), findsOneWidget);
  });

  testWidgets('allowed contacts displays matching and a usable empty result', (
    tester,
  ) async {
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
  });

  testWidgets(
    'advertisement targeting selects one interest without changing profile interests',
    (tester) async {
      final controller = OnboardingController()
        ..interests.addAll(['Art', 'Music', 'Travel']);
      Set<String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InterestsScreen(
                    controller: controller,
                    onComplete: () {},
                    mode: InterestSelectionMode.advertisement,
                    onSelected: (selection) => result = selection,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Art'));
      await tester.tap(find.text('Food'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, {'Food'});
      expect(controller.interests, {'Art', 'Music', 'Travel'});
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
}
