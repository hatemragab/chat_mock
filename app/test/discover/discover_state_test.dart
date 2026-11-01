import 'package:app/app/app.dart';
import 'package:app/features/discover/controllers/discover_controller.dart';
import 'package:app/features/discover/ui/screens/discover_screen/discover_screen.dart';
import 'package:app/features/discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup shows a content skeleton before opening Discover', (
    tester,
  ) async {
    await tester.pumpWidget(const WhizpeeApp());
    expect(find.text('Loading stories…'), findsOneWidget);
    expect(find.text('A little inspiration, every day'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('A little inspiration, every day'), findsOneWidget);
  });

  testWidgets('failed search retries while retaining the query and category', (
    tester,
  ) async {
    final stories = StoriesController();
    final discover = DiscoverController();
    addTearDown(stories.dispose);
    addTearDown(discover.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoverSearchScreen(
          controller: stories,
          discover: discover,
          initialCategory: 'Design',
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Maison');
    await tester.pump();
    expect(find.text('Maison Studio'), findsOneWidget);
    discover.showError();
    await tester.pump();
    expect(find.text('Could not load Stories'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text ??
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
      'Maison',
    );
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Design'))
          .selected,
      isTrue,
    );
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading stories…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Maison Studio'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Design'))
          .selected,
      isTrue,
    );
  });

  testWidgets(
    'offline and reconnecting states preserve the available content',
    (tester) async {
      final stories = StoriesController();
      final discover = DiscoverController();
      addTearDown(stories.dispose);
      addTearDown(discover.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoverScreen(controller: stories, discover: discover),
        ),
      );
      discover.setOnline(false);
      await tester.pump();
      expect(find.text('Offline · Showing available Stories'), findsOneWidget);
      expect(find.text('Maison Studio'), findsWidgets);
      discover.setOnline(true);
      await tester.pump();
      expect(find.text('Reconnecting…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Reconnecting…'), findsNothing);
      expect(find.text('Maison Studio'), findsWidgets);
    },
  );
}
