import 'package:app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'main navigation remains usable at larger text on a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const WhizpeeApp());
      await tester.pumpAndSettle();
      for (final tab in ['Chats', 'Calls', 'Status', 'Profile', 'Discover']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$tab should remain usable',
        );
      }
    },
  );
}
