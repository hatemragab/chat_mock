import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/stories/ui/screens/status_screen/status_screen.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'status shows newly published own stories and sorts seen contacts',
    (tester) async {
      final wallet = WalletController();
      final publishing = PublishingController(wallet: wallet);
      final stories = StoriesController(publishing: publishing);
      final draft = publishing.createDraft(PublicationType.status)
        ..caption = 'An original update';
      publishing.publish(draft, publishing.review(draft));
      stories.markSeen('sarah');
      await tester.pumpWidget(
        MaterialApp(
          home: StatusScreen(
            controller: stories,
            onDiscover: () {},
            onCreate: () {},
          ),
        ),
      );
      expect(find.text('An original update'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Seen updates'), 250);
      expect(find.text('Seen updates'), findsOneWidget);
      expect(find.text('Sarah Wilson'), findsOneWidget);
      stories.setAvailability('sarah', StoryAvailability.removed);
      await tester.pump();
      expect(find.text('Sarah Wilson'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      stories.dispose();
      publishing.dispose();
      wallet.dispose();
    },
  );
}
