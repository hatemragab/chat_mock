import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/chats/ui/widgets/chat_composer.dart';

void main() {
  testWidgets('a rejected send keeps the draft until retry succeeds', (
    tester,
  ) async {
    var accepted = false;
    final sent = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            onSend: (text) {
              if (!accepted) return false;
              sent.add(text);
              return true;
            },
            onAttachment: () {},
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Keep this draft');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(sent, isEmpty);
    accepted = true;
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    expect(sent, ['Keep this draft']);
    expect(find.text('Keep this draft'), findsNothing);
  });

  testWidgets('composer switches mic to send and preserves typed text', (
    tester,
  ) async {
    final sent = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            onSend: (text) {
              sent.add(text);
              return true;
            },
            onAttachment: () {},
          ),
        ),
      ),
    );
    expect(find.byTooltip('Record voice note'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Hello there');
    await tester.pump();
    expect(find.byTooltip('Send'), findsOneWidget);
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    expect(sent, ['Hello there']);
    expect(find.byTooltip('Record voice note'), findsOneWidget);
  });
  testWidgets('emoji inserts at the caret without losing the draft', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(onSend: (_) => true, onAttachment: () {}),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'AB');
    final field = tester.widget<TextField>(find.byType(TextField));
    field.controller!.selection = const TextSelection.collapsed(offset: 1);
    await tester.tap(find.byTooltip('Emoji'));
    await tester.pump();
    await tester.tap(find.text('😀'));
    await tester.pump();
    expect(field.controller!.text, 'A😀B');
    expect(field.controller!.selection.baseOffset, 3);
  });

  testWidgets('cancelling an edit restores the original draft and caret', (
    tester,
  ) async {
    String? edit;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return ChatComposer(
                onSend: (_) => true,
                onAttachment: () {},
                editText: edit,
                onCancelContext: () => setState(() => edit = null),
              );
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'unfinished draft');
    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    controller.selection = const TextSelection.collapsed(offset: 5);
    update(() => edit = 'old message');
    await tester.pump();
    expect(controller.text, 'old message');
    await tester.tap(find.byTooltip('Cancel reply or edit'));
    await tester.pump();
    expect(controller.text, 'unfinished draft');
    expect(controller.selection.baseOffset, 5);
  });
}
