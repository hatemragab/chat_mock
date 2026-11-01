import 'package:app/app/theme/app_theme.dart';
import 'package:app/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 386.0, 430.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'header truncates and aligns controls at $width in $brightness',
        (tester) async {
          tester.view.physicalSize = Size(width, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var actions = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.create(brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppHeader(
                            title: const Text(
                              'A very long conversation title that must leave room for every action',
                            ),
                            subtitle: 'A long subtitle with the current conversation context',
                            actions: [
                              IconButton(
                                tooltip: 'Details',
                                onPressed: () => actions++,
                                icon: const Icon(Icons.info_outline),
                              ),
                            ],
                          ),
                          body: const Text('Conversation'),
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final header = tester.widget<AppHeader>(find.byType(AppHeader));
          expect(header.preferredSize.height, 72);
          expect(tester.getSize(find.byTooltip('Details')), const Size(44, 44));
          final back = find.byType(BackButton);
          expect(tester.getSize(back).width, 44);
          expect(
            tester.getCenter(back).dy,
            tester.getCenter(find.byTooltip('Details')).dy,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Details'));
          expect(actions, 1);
          await tester.tap(back);
          await tester.pumpAndSettle();
          expect(find.text('Open'), findsOneWidget);
        },
      );
    }
  }

  test('standard header uses the compact height', () {
    expect(const AppHeader(title: Text('Settings')).preferredSize.height, 56);
  });
}
