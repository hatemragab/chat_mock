import 'package:app/shared/widgets/app_avatar.dart';
import 'package:app/shared/widgets/app_person_row.dart';
import 'package:app/shared/widgets/app_selectable_person_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('avatar preserves complete Unicode initials and empty names', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppAvatar(name: '👩🏽‍🎨 Artist'),
              AppAvatar(name: ''),
              AppAvatar(name: 'Alex Morgan', semanticLabel: 'Alex Morgan'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('👩🏽‍🎨'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.bySemanticsLabel('👩🏽‍🎨'), findsNothing);
    expect(find.bySemanticsLabel('Alex Morgan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('an existing selected person cannot be toggled from the row', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const AppSelectablePersonRow(
                name: 'Existing member',
                subtitle: 'Already a member',
                selected: true,
                onChanged: null,
              ),
              AppSelectablePersonRow(
                name: 'New member',
                selected: false,
                onChanged: (_) => changes++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Existing member'));
    expect(changes, 0);
    final existing = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Existing member'),
    );
    expect(existing.value, isTrue);
    expect(existing.onChanged, isNull);
    await tester.tap(find.text('New member'));
    expect(changes, 1);
  });

  testWidgets('long person names keep row actions reachable at narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
          body: AppPersonRow(
            name: 'A very long person name that must stay on one line',
            subtitle: 'A long status that must stay within the available space',
            trailing: const Icon(Icons.more_vert),
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.more_vert));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
