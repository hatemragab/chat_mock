import 'package:app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'a promoted Story opens its own Business profile and paid-room confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WhizpeeApp());
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Spaces that feel like home').first);
      await tester.pumpAndSettle();
      expect(find.text('View Business'), findsOneWidget);
      await tester.tap(find.text('View Business'));
      await tester.pumpAndSettle();
      expect(find.text('Business profile'), findsOneWidget);
      await tester.tap(find.text('Contact about this Story'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Message room'));
      await tester.pumpAndSettle();
      expect(find.text('Reopen Maison Studio message room?'), findsOneWidget);
      expect(find.textContaining('10 Credits opens a room'), findsOneWidget);
    },
  );
}
