import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/target_area_screen/target_area_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'manual area validates, saves the radius and retains it in the draft',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final draft = PublicationDraft(
        id: 'test',
        type: PublicationType.advertisement,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => TargetAreaScreen(draft: draft),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Country'), '');
      await tester.ensureVisible(find.text('Save area'));
      await tester.tap(find.text('Save area'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a country.'), findsOneWidget);
      expect(draft.location, 'Cameroon');
      await tester.enterText(
        find.widgetWithText(TextField, 'Country'),
        'Cameroon',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'City (optional)'),
        'Douala',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Neighbourhood (optional)'),
        'Bonapriso',
      );
      await tester.drag(find.byType(Slider), const Offset(50, 0));
      await tester.ensureVisible(find.text('Save area'));
      await tester.tap(find.text('Save area'));
      await tester.pumpAndSettle();
      expect(draft.location, 'Bonapriso, Douala, Cameroon');
      expect(draft.radiusKm, greaterThan(10));
    },
  );
  testWidgets('sample chooser updates area only on selection', (tester) async {
    final draft = PublicationDraft(
      id: 'demo',
      type: PublicationType.advertisement,
    );
    await tester.pumpWidget(MaterialApp(home: TargetAreaScreen(draft: draft)));
    await tester.tap(find.text('Choose sample area'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(draft.city, isEmpty);
    await tester.tap(find.text('Choose sample area'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Zamalek'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Zamalek'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save area'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(TargetAreaScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save area'));
    await tester.pumpAndSettle();
    expect(draft.country, 'Egypt');
    expect(draft.city, 'Cairo');
    expect(draft.neighbourhood, 'Zamalek');
  });
}
