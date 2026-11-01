import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/chats/ui/screens/chat_info_screen/chat_info_screen.dart';
import 'package:app/features/safety/models/report_submission.dart';
import 'package:app/features/safety/ui/screens/report_screen/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'contact info reports the selected identity and retries the same draft',
    (tester) async {
      final chats = ChatsController();
      addTearDown(chats.dispose);
      final contact = chats.byId('sarah');
      final originalMessages = contact.messages.length;
      final submissions = <ReportSubmission>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ChatInfoScreen(
            controller: chats,
            chat: contact,
            submitReport: (submission) async {
              submissions.add(submission);
              if (submissions.length == 1) throw StateError('Mock failure');
              return ReportOutcome.success;
            },
          ),
        ),
      );
      await tester.scrollUntilVisible(find.text('Report Sarah Wilson'), 240);
      await tester.ensureVisible(find.text('Report Sarah Wilson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report Sarah Wilson'));
      await tester.pumpAndSettle();
      final report = tester.widget<ReportScreen>(find.byType(ReportScreen));
      expect(report.target, contact.name);
      expect(report.targetId, contact.id);
      await tester.tap(find.text('Spam'));
      await tester.enterText(find.byType(TextField), 'Repeated unwanted links');
      await tester.ensureVisible(find.text('Submit report'));
      await tester.tap(find.text('Submit report'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Repeated unwanted links'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Report submitted'), findsOneWidget);
      expect(submissions, hasLength(2));
      for (final submission in submissions) {
        expect(submission.target, 'Sarah Wilson');
        expect(submission.targetId, 'sarah');
        expect(submission.reason, 'Spam');
        expect(submission.details, 'Repeated unwanted links');
      }
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatInfoScreen), findsOneWidget);
      expect(contact.messages, hasLength(originalMessages));
      expect(contact.blocked, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
