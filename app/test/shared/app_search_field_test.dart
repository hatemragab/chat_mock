import 'package:app/features/support/ui/screens/help_screen/help_screen.dart';
import 'package:app/shared/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'clearing a help query restores results and keeps typing available',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
      await tester.enterText(find.byType(TextField), 'wallet');
      await tester.pump();
      expect(find.text('Wallet and Credits'), findsOneWidget);
      expect(find.text('Getting started'), findsNothing);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(find.text('Getting started'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);
      await tester.enterText(find.byType(TextField), 'privacy');
      await tester.pump();
      expect(find.text('Privacy and blocking'), findsOneWidget);
      expect(find.text('Getting started'), findsNothing);
    },
  );

  testWidgets('search controller ownership survives replacement and disposal', (
    tester,
  ) async {
    final first = TextEditingController(text: 'First query');
    final second = TextEditingController(text: 'Second query');
    var current = first;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AppSearchField(
                hintText: 'Search',
                controller: current,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('First query'), findsOneWidget);
    update(() => current = second);
    await tester.pump();
    expect(find.text('Second query'), findsOneWidget);
    first.text = 'Still owned by caller';
    await tester.pumpWidget(const SizedBox.shrink());
    second.text = 'Still available';
    expect(first.text, 'Still owned by caller');
    expect(second.text, 'Still available');
    first.dispose();
    second.dispose();
  });
}
