import 'package:app/app/app.dart';
import 'package:app/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates a group and returns to its own conversation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.tap(find.text('Chats').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add group photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Green garden'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Group name'),
      'Product Team',
    );
    await tester.tap(find.text('Select members'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sarah Wilson').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue (1)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create group'));
    await tester.tap(find.text('Create group'));
    await tester.pumpAndSettle();
    expect(find.text('Product Team'), findsWidgets);
    void expectPhoto() {
      final avatars = tester.widgetList<AppAvatar>(find.byType(AppAvatar));
      expect(
        avatars.where((avatar) => avatar.name == 'Product Team').single.image,
        isA<AssetImage>().having(
          (image) => image.assetName,
          'group photo',
          'assets/story/green_corner.png',
        ),
      );
    }

    expectPhoto();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Product Team'), findsOneWidget);
    expectPhoto();
    await tester.tap(find.text('Product Team'));
    await tester.pumpAndSettle();
    expect(find.text('Product Team'), findsWidgets);
    expectPhoto();
  });
}
