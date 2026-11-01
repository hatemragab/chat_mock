import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/sheets/audio_output_sheet/audio_output_sheet.dart';
import 'package:app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:app/features/settings/ui/screens/account_screen/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'S09 dismiss preserves output and selecting Bluetooth updates this call',
    (tester) async {
      final calls = CallsController(spendCredits: (_, _, _) => true);
      addTearDown(calls.dispose);
      final call = calls.start(name: 'Sarah Wilson', kind: CallKind.audio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) =>
                      AudioOutputSheet(controller: calls, call: call),
                ),
                child: const Text('Open output'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open output'));
      await tester.pumpAndSettle();
      expect(find.text('Earpiece'), findsOneWidget);
      expect(find.text('Speaker'), findsOneWidget);
      expect(find.text('Bluetooth device'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(call.output, CallOutput.earpiece);
      await tester.tap(find.text('Open output'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bluetooth device'));
      await tester.pumpAndSettle();
      expect(call.output, CallOutput.bluetooth);
      expect(call.speaker, isFalse);
      expect(find.text('Open output'), findsOneWidget);
      await tester.tap(find.text('Open output'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Speaker'));
      await tester.pumpAndSettle();
      expect(call.output, CallOutput.speaker);
      expect(call.speaker, isTrue);
    },
  );
  testWidgets('D19 cancel keeps session and confirm signs out once', (
    tester,
  ) async {
    final profile = OnboardingController();
    addTearDown(profile.dispose);
    var signOuts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AccountScreen(profile: profile, onSignOut: () => signOuts++),
      ),
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(signOuts, 0);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(signOuts, 1);
  });
}
