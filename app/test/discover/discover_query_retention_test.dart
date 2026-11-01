import 'package:app/features/discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('search input survives scrolling out of the lazy results list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final stories = StoriesController();
    addTearDown(stories.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DiscoverSearchScreen(controller: stories)),
    );
    await tester.enterText(find.byType(TextField), 'a');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Green Corner'),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      -200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'a',
    );
  });
}
