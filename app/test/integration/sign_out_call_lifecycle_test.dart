import 'package:app/app/app.dart';
import 'package:app/app/ui/screens/home_shell/home_shell.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/profile/ui/screens/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign out ends an active Business call before further billing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pumpAndSettle();
    final shell = tester.widget<HomeShell>(find.byType(HomeShell));
    final call = shell.calls.start(
      name: 'Maison Studio',
      kind: CallKind.audio,
      business: true,
      storyId: 'maison',
    );
    expect(shell.calls.answer(), isTrue);
    shell.calls.setMinimized(true);
    expect(shell.wallet.credits, 2985);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Sign out'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(shell.calls.active, isNull);
    expect(call.phase, CallPhase.ended);
    expect(call.endReason, 'Call ended when you signed out.');
    expect(
      shell.calls.history.where((item) => item.id == call.id),
      hasLength(1),
    );
    await tester.pump(const Duration(minutes: 2));
    expect(shell.wallet.credits, 2985);
    expect(call.totalCost, 15);
    expect(call.seconds, lessThan(60));
  });

  for (final incoming in [false, true]) {
    testWidgets(
      'starting onboarding ${incoming ? 'declines incoming' : 'cancels outgoing'} ringing call',
      (tester) async {
        await tester.pumpWidget(const WhizpeeApp());
        await tester.pumpAndSettle();
        final shell = tester.widget<HomeShell>(find.byType(HomeShell));
        final call = shell.calls.start(
          name: 'Sarah Wilson',
          kind: CallKind.audio,
          incoming: incoming,
        );
        shell.onSignOut();
        await tester.pumpAndSettle();
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(shell.calls.active, isNull);
        expect(call.phase, incoming ? CallPhase.declined : CallPhase.cancelled);
        expect(
          shell.calls.history.where((item) => item.id == call.id),
          hasLength(1),
        );
        expect(shell.wallet.credits, 3000);
      },
    );
  }
}
