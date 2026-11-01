import 'package:app/app/theme/app_theme.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/models/chat_models.dart';
import 'package:app/features/chats/ui/screens/attachment_preview_screen/attachment_preview_screen.dart';
import 'package:app/features/chats/ui/screens/conversation_screen/conversation_screen.dart';
import 'package:app/features/chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import 'package:app/features/chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/groups/ui/screens/group_members_screen/group_members_screen.dart';
import 'package:app/features/groups/ui/screens/group_permissions_screen/group_permissions_screen.dart';
import 'package:app/features/groups/ui/screens/group_screen/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _sizes = [Size(320, 640), Size(386, 802), Size(430, 900)];

Future<void> _mount(
  WidgetTester tester,
  Widget screen,
  Brightness brightness, {
  double keyboard = 0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.create(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.3),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pump();
  expect(
    tester.takeException(),
    isNull,
    reason: '${screen.runtimeType} layout',
  );
}

void main() {
  for (final size in _sizes) {
    for (final brightness in Brightness.values) {
      final label =
          '${size.width.toInt()}×${size.height.toInt()} ${brightness.name}';
      testWidgets(
        'direct and group composer actions stay reachable at $label',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final chats = ChatsController();
          final group = GroupController(chats: chats);
          addTearDown(() {
            group.dispose();
            chats.dispose();
          });
          for (final grouped in [false, true]) {
            final chat = grouped ? group.conversation : chats.byId('sarah');
            await _mount(
              tester,
              grouped
                  ? GroupScreen(controller: group)
                  : ConversationScreen(controller: chats, chat: chat),
              brightness,
              keyboard: 220,
            );
            final field = find.widgetWithText(TextField, 'Message');
            await tester.enterText(field, 'A multiline message\nwith an emoji');
            await tester.pump();
            await tester.tap(find.byTooltip('Emoji'));
            await tester.pump();
            expect(tester.takeException(), isNull);
            await tester.tap(find.text('😀'));
            await tester.pump();
            final send = find.byTooltip('Send');
            expect(
              tester.getBottomLeft(send).dy,
              lessThanOrEqualTo(size.height - 220),
            );
            await tester.tap(send);
            await tester.pump();
            expect(
              chat.messages.last.text,
              'A multiline message\nwith an emoji😀',
            );
            await tester.tap(find.byTooltip('Emoji'));
            await tester.pump();
            await tester.tap(find.byTooltip('Record voice note'));
            await tester.pump(const Duration(seconds: 1));
            expect(tester.takeException(), isNull);
            await tester.tap(find.byTooltip('Lock recording'));
            await tester.pump();
            expect(find.textContaining('Recording locked'), findsOneWidget);
            await tester.tap(find.byTooltip('Stop recording'));
            await tester.pump();
            expect(find.textContaining('Voice note ready'), findsOneWidget);
            final voiceSend = find.byTooltip('Send voice note');
            expect(
              tester.getBottomLeft(voiceSend).dy,
              lessThanOrEqualTo(size.height - 220),
            );
            await tester.tap(voiceSend);
            await tester.pump(const Duration(seconds: 2));
            expect(chat.messages.last.kind, MessageKind.audio);
            expect(chat.messages.last.uploadState, UploadState.complete);
            await tester.tap(find.byTooltip('Record voice note'));
            await tester.pump();
            await tester.tap(find.text('Cancel'));
            await tester.pump();
            expect(find.byTooltip('Record voice note'), findsOneWidget);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        },
      );

      testWidgets('recipient selection and group management fit at $label', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chats = ChatsController();
        final group = GroupController(chats: chats);
        addTearDown(() {
          group.dispose();
          chats.dispose();
        });
        await _mount(
          tester,
          RecipientPickerScreen(controller: chats, multiSelect: true),
          brightness,
          keyboard: 220,
        );
        await tester.enterText(find.byType(TextField), 'Sarah');
        await tester.pump();
        await tester.tap(find.text('Sarah Wilson'));
        await tester.pump();
        final footer = find.text('Continue (1)');
        expect(
          tester.getBottomLeft(footer).dy,
          lessThanOrEqualTo(size.height - 220),
        );
        expect(
          tester
              .widget<FilledButton>(
                find.ancestor(of: footer, matching: find.byType(FilledButton)),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await _mount(tester, GroupMembersScreen(controller: group), brightness);
        await tester.enterText(find.byType(TextField), 'Sarah');
        await tester.pump();
        await tester.tap(find.text('Sarah Wilson'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Remove member'));
        expect(find.text('Remove member'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await _mount(
          tester,
          GroupPermissionsScreen(controller: group),
          brightness,
        );
        final sendAdmins = find.widgetWithText(
          SwitchListTile,
          'Only admins can send messages',
        );
        await tester.tap(sendAdmins);
        await tester.pump();
        expect(group.onlyAdminsCanSend, isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'attachment actions and file controls remain usable at $label',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await _mount(
            tester,
            const AttachmentPreviewScreen(
              kind: MessageKind.document,
              name: 'Customer prototype presentation and interface review document.pdf',
            ),
            brightness,
          );
          expect(find.text('Send attachment'), findsOneWidget);
          expect(
            tester.getBottomLeft(find.text('Send attachment')).dy,
            lessThanOrEqualTo(size.height),
          );
          final message = ChatMessage(
            id: 'file',
            author: 'Sarah',
            text: 'Review document.pdf',
            time: DateTime(2026),
            isMine: false,
            kind: MessageKind.document,
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await _mount(
            tester,
            MediaViewerScreen(message: message, onShowSource: () {}),
            brightness,
          );
          await tester.tap(find.text('Open sample'));
          await tester.pump();
          expect(find.text('Opened in simulation'), findsOneWidget);
          await tester.tap(find.text('Download sample'));
          await tester.pump();
          expect(find.text('Saved in demo'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
