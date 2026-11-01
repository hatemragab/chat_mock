import 'package:app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens on Discover and navigation retains chat context', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('A little inspiration, every day'), findsOneWidget);
    await tester.tap(find.text('Chats').last);
    await tester.pumpAndSettle();
    expect(find.text('Sarah Wilson'), findsWidgets);
    await tester.tap(find.text('Status').last);
    await tester.pumpAndSettle();
    expect(find.text('Recent updates'), findsOneWidget);
    await tester.tap(find.text('Discover').last);
    await tester.pumpAndSettle();
    expect(find.text('Explore stories'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    testWidgets(
      'main tabs fit a ${size.width.toInt()} by ${size.height.toInt()} viewport',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const WhizpeeApp());
        for (final tab in ['Chats', 'Calls', 'Status', 'Profile', 'Discover']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$tab should fit at $size',
          );
        }
      },
    );
  }
}
