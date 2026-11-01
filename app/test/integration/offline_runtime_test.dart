import 'dart:io';

import 'package:app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'the local demo opens and navigates without creating an HTTP client',
    (tester) async {
      await HttpOverrides.runZoned(
        () async {
          tester.view.physicalSize = const Size(386, 802);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(const WhizpeeApp());
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pumpAndSettle();
          expect(find.text('Explore stories'), findsOneWidget);
          await tester.tap(find.text('Chats').last);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Sarah Wilson').first);
          await tester.pumpAndSettle();
          expect(find.byType(TextField), findsWidgets);
        },
        createHttpClient: (_) =>
            throw StateError('Unexpected network request in the local demo'),
      );
    },
  );
}
