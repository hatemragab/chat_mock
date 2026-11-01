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
  testWidgets(
    'offline review control persists across tabs and reset restores online state',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WhizpeeApp());
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, 'Prototype tools');
      await tester.tap(find.text('Prototype tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Online'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chats').last);
      await tester.pumpAndSettle();
      expect(find.text('Offline — messages will be queued'), findsOneWidget);
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, 'Prototype tools');
      await tester.tap(find.text('Prototype tools'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Reset demo'),
        350,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Reset demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();
      expect(find.text('A little inspiration, every day'), findsOneWidget);
      await tester.tap(find.text('Chats').last);
      await tester.pumpAndSettle();
      expect(find.text('Offline — messages will be queued'), findsNothing);
      await tester.tap(find.text('Sarah Wilson').first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Audio call'), findsOneWidget);
    },
  );
  testWidgets(
    'appearance changes immediately and stays selected across routes',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const WhizpeeApp());
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      await scrollProfileTo(tester, 'Appearance');
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp).first).themeMode,
        ThemeMode.dark,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chats').last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp).first).themeMode,
        ThemeMode.dark,
      );
    },
  );
}
