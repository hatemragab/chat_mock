import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import 'package:app/features/business/ui/screens/business_info_screen/business_info_screen.dart';
import 'package:app/features/business/ui/sheets/business_call_preflight_sheet/business_call_preflight_sheet.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/calls/ui/screens/call_screen/call_screen.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_details_screen/group_details_screen.dart';
import 'package:app/features/groups/ui/screens/group_info_screen/group_info_screen.dart';
import 'package:app/features/groups/ui/screens/group_members_screen/group_members_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:app/features/wallet/ui/screens/buy_credits_screen/buy_credits_screen.dart';
import 'package:app/features/wallet/ui/screens/withdrawal_form_screen/withdrawal_form_screen.dart';
import 'package:app/features/wallet/ui/sheets/payment_method_sheet/payment_method_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Fixture {
  _Fixture() {
    group = GroupController(chats: chats);
    business = BusinessController(
      wallet: wallet,
      chats: chats,
      stories: stories,
    );
    calls = CallsController(
      spendCredits: (id, amount, description) =>
          wallet.spendCredits(id: id, amount: amount, description: description),
      availableCredits: () => wallet.credits,
    );
  }

  final chats = ChatsController();
  final wallet = WalletController();
  final stories = StoriesController();
  late final GroupController group;
  late final BusinessController business;
  late final CallsController calls;
  Story get story =>
      StoriesController.stories.firstWhere((story) => story.id == 'maison');

  void dispose() {
    calls.dispose();
    business.dispose();
    group.dispose();
    stories.dispose();
    wallet.dispose();
    chats.dispose();
  }
}

typedef _ScreenCase = ({
  String label,
  Widget Function(_Fixture) build,
  bool keyboard,
  String visibleText,
});

void main() {
  final cases = <_ScreenCase>[
    (
      label: 'buy Credits',
      build: (f) => BuyCreditsScreen(controller: f.wallet),
      keyboard: true,
      visibleText: 'Choose an amount',
    ),
    (
      label: 'withdraw Cash',
      build: (f) => WithdrawalFormScreen(controller: f.wallet),
      keyboard: true,
      visibleText: 'Withdraw Cash',
    ),
    (
      label: 'group details',
      build: (f) => GroupDetailsScreen(controller: f.group),
      keyboard: true,
      visibleText: 'Edit group',
    ),
    (
      label: 'group members',
      build: (f) => GroupMembersScreen(controller: f.group),
      keyboard: true,
      visibleText: 'Group members',
    ),
    (
      label: 'group info',
      build: (f) => GroupInfoScreen(controller: f.group),
      keyboard: false,
      visibleText: 'Group info',
    ),
    (
      label: 'direct conversation',
      build: (f) =>
          ConversationScreen(controller: f.chats, chat: f.chats.byId('sarah')),
      keyboard: true,
      visibleText: 'Sarah Wilson',
    ),
    (
      label: 'Business info',
      build: (f) => BusinessInfoScreen(controller: f.business, story: f.story),
      keyboard: false,
      visibleText: 'Business conversation info',
    ),
    (
      label: 'Business conversation',
      build: (f) {
        f.business.openRoom(f.story, confirmed: true);
        return BusinessConversationScreen(
          controller: f.business,
          story: f.story,
        );
      },
      keyboard: true,
      visibleText: 'Maison Studio',
    ),
    (
      label: 'active audio call',
      build: (f) {
        final call = f.calls.start(name: 'Sarah Wilson', kind: CallKind.audio);
        f.calls.answer();
        return CallScreen(controller: f.calls, call: call);
      },
      keyboard: false,
      visibleText: 'End call',
    ),
    (
      label: 'active Business video call',
      build: (f) {
        final call = f.calls.start(
          name: f.story.author,
          kind: CallKind.video,
          business: true,
          story: f.story,
        );
        f.calls.answer();
        return CallScreen(controller: f.calls, call: call);
      },
      keyboard: false,
      visibleText: 'End call',
    ),
  ];

  for (final size in [
    const Size(320, 640),
    const Size(386, 802),
    const Size(430, 900),
  ]) {
    for (final brightness in Brightness.values) {
      for (final scenario in cases) {
        testWidgets(
          '${scenario.label}: $size, ${brightness.name}, enlarged text',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final fixture = _Fixture();
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.create(brightness),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.3),
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
                    viewInsets: EdgeInsets.only(
                      bottom: scenario.keyboard ? 200 : 0,
                    ),
                  ),
                  child: child!,
                ),
                home: scenario.build(fixture),
              ),
            );
            await tester.pump();
            expect(
              tester.takeException(),
              isNull,
              reason: '${scenario.label} must fit the viewport',
            );
            expect(find.text(scenario.visibleText), findsWidgets);
            final formAction = switch (scenario.label) {
              'buy Credits' => 'Review payment',
              'withdraw Cash' => 'Review withdrawal',
              'group details' => 'Save changes',
              _ => null,
            };
            if (formAction != null) {
              await tester.scrollUntilVisible(
                find.text(formAction),
                150,
                scrollable: find
                    .descendant(
                      of: find.byType(ListView).first,
                      matching: find.byType(Scrollable),
                    )
                    .first,
              );
              await tester.pump();
              expect(tester.takeException(), isNull);
              expect(
                tester.getBottomRight(find.text(formAction)).dy,
                lessThanOrEqualTo(size.height - 200),
              );
            }
            if (scenario.label == 'direct conversation' ||
                scenario.label == 'Business conversation') {
              await tester.enterText(find.byType(TextField).last, 'Hello');
              await tester.pump();
              final send = find.byTooltip('Send');
              expect(send, findsOneWidget);
              expect(
                tester.getBottomRight(send).dy,
                lessThanOrEqualTo(size.height - 200),
              );
              expect(tester.takeException(), isNull);
            }
            if (scenario.label.contains('call')) {
              expect(
                tester.getBottomRight(find.text('End call')).dy,
                lessThanOrEqualTo(size.height - 16),
              );
            }
            await tester.pumpWidget(const SizedBox.shrink());
            fixture.dispose();
          },
        );
      }

      for (final sheet in ['payment method', 'Business call preflight']) {
        testWidgets(
          '$sheet sheet fits $size, ${brightness.name}, keyboard inset',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final fixture = _Fixture();
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.create(brightness),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.3),
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
                    viewInsets: const EdgeInsets.only(bottom: 200),
                  ),
                  child: child!,
                ),
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: sheet != 'payment method',
                        builder: (_) => sheet == 'payment method'
                            ? const PaymentMethodSheet(
                                selected: PaymentMethod.mtn,
                              )
                            : BusinessCallPreflightSheet(
                                controller: fixture.business,
                                story: fixture.story,
                                video: true,
                                onCall: (_, _) {},
                              ),
                      ),
                      child: const Text('Open sheet'),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Open sheet'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final action = sheet == 'payment method'
                ? find.text('Orange Mobile Money')
                : find.text('Cancel');
            await tester.ensureVisible(action);
            await tester.pumpAndSettle();
            expect(
              tester.getBottomRight(action).dy,
              lessThanOrEqualTo(size.height - 200),
            );
            await tester.pumpWidget(const SizedBox.shrink());
            fixture.dispose();
          },
        );
      }
    }
  }
  testWidgets(
    'payment method can be changed while the phone keyboard is open',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = _Fixture();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.create(Brightness.light),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
              viewInsets: const EdgeInsets.only(bottom: 200),
            ),
            child: child!,
          ),
          home: BuyCreditsScreen(controller: fixture.wallet),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Mobile Money phone number'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.enterText(find.byType(TextField).last, '670000000');
      await tester.ensureVisible(find.text('Payment method'));
      await tester.tap(find.text('Payment method'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Orange Mobile Money'));
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.text('Orange Mobile Money')).dy,
        lessThanOrEqualTo(440),
      );
      await tester.tap(find.text('Orange Mobile Money'));
      await tester.pumpAndSettle();
      expect(find.text('Orange Mobile Money'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      fixture.dispose();
    },
  );
}
