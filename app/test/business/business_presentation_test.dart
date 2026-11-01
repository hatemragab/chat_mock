import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'Business contact and preflight remain actionable at $size in $brightness',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController();
          final business = BusinessController(wallet: wallet);
          final story = StoriesController.stories.first;
          addTearDown(() {
            business.dispose();
            wallet.dispose();
          });
          var called = false;
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.create(brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
                ),
                child: child!,
              ),
              home: BusinessProfileScreen(
                controller: business,
                story: story,
                onCall: (source, video) {
                  expect(source.id, story.id);
                  expect(video, isFalse);
                  called = true;
                },
              ),
            ),
          );
          await tester.scrollUntilVisible(
            find.text('Contact about this Story'),
            240,
          );
          await tester.tap(find.text('Contact about this Story'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text('Audio call'));
          await tester.tap(find.text('Audio call'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text('Start call'));
          await tester.tap(find.text('Start call'));
          await tester.pumpAndSettle();
          expect(called, isTrue);
          expect(wallet.credits, 3000);
        },
      );

      testWidgets(
        'Business composer and room info remain usable with keyboard at $size in $brightness',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final wallet = WalletController();
          final business = BusinessController(wallet: wallet);
          final story = StoriesController.stories.first;
          addTearDown(() {
            business.dispose();
            wallet.dispose();
          });
          var keyboard = false;
          late StateSetter update;
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return MaterialApp(
                  theme: AppTheme.create(brightness),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.3),
                      viewInsets: EdgeInsets.only(bottom: keyboard ? 240 : 0),
                      padding: const EdgeInsets.only(top: 24, bottom: 20),
                      viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
                    ),
                    child: child!,
                  ),
                  home: BusinessProfileScreen(
                    controller: business,
                    story: story,
                  ),
                );
              },
            ),
          );
          await tester.scrollUntilVisible(
            find.text('Contact about this Story'),
            240,
          );
          await tester.tap(find.text('Contact about this Story'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Message room'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Open room'));
          await tester.pumpAndSettle();
          update(() => keyboard = true);
          await tester.pump();
          await tester.enterText(
            find.widgetWithText(TextField, 'Message'),
            'Hello 👋\nI would like to learn more.\nCan you share details?',
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('Send'));
          await tester.pumpAndSettle();
          expect(
            business.roomFor(story.id)!.messages.last.text,
            contains('Can you share details?'),
          );
          expect(wallet.credits, 2990);
          update(() => keyboard = false);
          await tester.pump();
          await tester.tap(find.byTooltip('Business conversation info'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Block Maison Studio'),
            220,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('Block Maison Studio'), findsOneWidget);
        },
      );
    }
  }
}
