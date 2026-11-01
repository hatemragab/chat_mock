import 'package:app/app/theme/app_colors.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    test(
      '$brightness shared controls use readable accent and compact geometry',
      () {
        final theme = AppTheme.create(brightness);
        final scheme = theme.colorScheme;
        expect(
          contrast(scheme.primary, scheme.onPrimary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(scheme.surface, scheme.onSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          scheme.onSurfaceVariant,
          brightness == Brightness.light
              ? AppColors.lightSecondary
              : AppColors.darkSecondary,
        );
        for (final style in [
          theme.filledButtonTheme.style!,
          theme.outlinedButtonTheme.style!,
          theme.textButtonTheme.style!,
        ]) {
          final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
          expect(shape.borderRadius, BorderRadius.circular(10));
          expect(
            style.minimumSize!.resolve({})!.height,
            greaterThanOrEqualTo(44),
          );
        }
      },
    );
  }

  testWidgets('switching appearance preserves form input and button actions', (
    tester,
  ) async {
    var brightness = Brightness.light;
    var actions = 0;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, update) => MaterialApp(
          theme: AppTheme.create(brightness),
          home: Scaffold(
            body: Column(
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Name')),
                FilledButton(
                  onPressed: () => actions++,
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => update(() => brightness = Brightness.dark),
                  child: const Text('Dark'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Draft name');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('Draft name'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Save'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Save'));
    expect(actions, 1);
  });

  testWidgets('primary and tonal buttons retain distinct theme surfaces', (
    tester,
  ) async {
    final theme = AppTheme.create(Brightness.dark);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [
              FilledButton(onPressed: () {}, child: const Text('Primary')),
              FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            ],
          ),
        ),
      ),
    );
    Color? background(String label) => tester
        .widget<Material>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Material))
              .first,
        )
        .color;
    expect(background('Primary'), theme.colorScheme.primary);
    expect(background('Tonal'), theme.colorScheme.secondaryContainer);
    expect(background('Primary'), isNot(background('Tonal')));
  });
}
