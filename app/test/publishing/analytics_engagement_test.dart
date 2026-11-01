import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/creator_tools/controllers/creator_activity_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/analytics_screen/analytics_screen.dart';
import 'package:app/features/publishing/ui/screens/analytics_screen/widgets/qualified_views_chart.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('view chart remains usable on a narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(
          body: QualifiedViewsChart(
            now: DateTime(2026, 10, 2),
            viewsByDay: const {'2026-10-02': 5},
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('10/2'));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'analytics charts unique qualified views and live originating activity anonymously',
    (tester) async {
      var now = DateTime(2026, 10, 1, 9);
      final wallet = WalletController();
      final business = BusinessController(wallet: wallet);
      final calls = CallsController(spendCredits: (_, _, _) => true);
      final publishing = PublishingController(wallet: wallet, clock: () => now);
      publishing.attachContactActivity(
        CreatorActivityController(business: business, calls: calls),
      );
      addTearDown(() {
        publishing.dispose();
        business.dispose();
        calls.dispose();
        wallet.dispose();
      });
      final draft = publishing.createDraft(PublicationType.advertisement);
      expect(
        publishing.publish(draft, publishing.review(draft)),
        PublishResult.success,
      );
      final publication = publishing.publications.single;
      publishing.recordView(
        publication,
        viewerId: 'a',
        viewerName: 'Private Viewer',
      );
      publishing.recordView(
        publication,
        viewerId: 'a',
        viewerName: 'Private Viewer',
      );
      publishing.recordView(
        publication,
        viewerId: 'owner',
        viewerName: 'Owner',
        isOwner: true,
      );
      publishing.recordView(
        publication,
        viewerId: 'held',
        viewerName: 'Held Viewer',
        suspicious: true,
      );
      now = DateTime(2026, 10, 2, 8);
      publishing.recordView(
        publication,
        viewerId: 'b',
        viewerName: 'Another Viewer',
      );
      expect(publication.qualifiedViewsByDay, {
        '2026-10-01': 1,
        '2026-10-02': 1,
      });
      expect(publication.totalViews, 3);
      expect(publication.qualifiedViews, 2);
      expect(publication.heldViews, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: AnalyticsScreen(
            controller: publishing,
            publication: publication,
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Qualified views · last 7 days'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      final chart = tester.widget<QualifiedViewsChart>(
        find.byType(QualifiedViewsChart),
      );
      expect(chart.viewsByDay, publication.qualifiedViewsByDay);
      expect(find.text('Private Viewer'), findsNothing);
      expect(find.text('Held Viewer'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Calls'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Conversations'))
            .trailing,
        isA<Text>().having((text) => text.data, 'count', '0'),
      );
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Calls'))
            .trailing,
        isA<Text>().having((text) => text.data, 'count', '0'),
      );
      final story = Story(
        id: publication.id,
        author: 'Public Business',
        title: 'Offer',
        category: 'Design',
        kind: StoryKind.business,
        media: StoryMedia.photo,
        colors: const [Colors.teal, Colors.black],
      );
      business.seedRecipientRoom(story);
      expect(business.send(publication.id, 'A private message'), isTrue);
      calls.start(
        name: 'Private Caller',
        kind: CallKind.audio,
        business: true,
        storyId: publication.id,
      );
      await tester.pump();
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Conversations'))
            .trailing,
        isA<Text>().having((text) => text.data, 'count', '1'),
      );
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Calls'))
            .trailing,
        isA<Text>().having((text) => text.data, 'count', '1'),
      );
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Messages'))
            .trailing,
        isA<Text>().having((text) => text.data, 'count', '1'),
      );
      expect(find.text('Private Caller'), findsNothing);
      expect(find.text('A private message'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
