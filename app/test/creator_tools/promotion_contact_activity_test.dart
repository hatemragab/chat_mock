import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/business/models/business_room.dart';
import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/creator_tools/controllers/creator_activity_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import 'package:app/features/stories/models/story.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late WalletController wallet;
  late PublishingController publishing;
  late BusinessController business;
  late CallsController calls;
  late CreatorActivityController activity;
  late Publication publication;

  setUp(() {
    wallet = WalletController();
    publishing = PublishingController(wallet: wallet);
    business = BusinessController(wallet: wallet);
    calls = CallsController(spendCredits: (_, _, _) => true);
    activity = CreatorActivityController(business: business, calls: calls);
    publishing.attachContactActivity(activity);
    final draft = publishing.createDraft(PublicationType.advertisement)
      ..caption = 'Spring collection';
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    publication = publishing.publications.single;
  });

  tearDown(() {
    business.dispose();
    calls.dispose();
    publishing.dispose();
    wallet.dispose();
  });

  Story story(String id) => Story(
    id: id,
    author: 'Maison Studio',
    title: 'Spring collection',
    category: 'Design',
    kind: StoryKind.business,
    media: StoryMedia.photo,
    colors: const [Colors.teal, Colors.black],
  );

  test(
    'activity only includes interactions from the exact originating Story',
    () {
      business.seedRecipientRoom(story(publication.id));
      business.seedRecipientRoom(story('different-story'));
      calls.start(
        name: 'Maison Studio',
        kind: CallKind.audio,
        business: true,
        storyId: publication.id,
      );
      calls.finishRinging(CallPhase.missed);
      calls.start(
        name: 'Another business',
        kind: CallKind.video,
        business: true,
        storyId: 'different-story',
      );
      calls.finishRinging(CallPhase.declined);
      calls.start(
        name: 'A contact',
        kind: CallKind.audio,
        storyId: publication.id,
      );
      calls.finishRinging(CallPhase.cancelled);

      expect(activity.roomFor(publication)?.story.id, publication.id);
      expect(activity.callsFor(publication).length, 1);
      expect(activity.callsFor(publication).single.phase, CallPhase.missed);
    },
  );

  testWidgets(
    'promoted publication opens only its contact activity and recipient room',
    (tester) async {
      tester.view.physicalSize = const Size(386, 802);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      business.seedRecipientRoom(story(publication.id));
      publishing.recordView(
        publication,
        viewerId: 'viewer-1',
        viewerName: 'Private Viewer',
      );
      calls.start(
        name: 'Maison Studio',
        kind: CallKind.audio,
        business: true,
        storyId: publication.id,
      );
      calls.finishRinging(CallPhase.missed);
      await tester.pumpWidget(
        MaterialApp(
          home: PublicationDetailsScreen(
            controller: publishing,
            publication: publication,
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Contact activity'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Contact activity'));
      await tester.pumpAndSettle();
      expect(find.text('Business message room'), findsOneWidget);
      expect(find.text('Business audio call'), findsOneWidget);
      expect(find.text('Private Viewer'), findsNothing);
      await tester.tap(find.text('Business message room'));
      await tester.pumpAndSettle();
      expect(business.perspective, BusinessPerspective.recipient);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(business.perspective, BusinessPerspective.customer);
    },
  );

  testWidgets(
    'activity displays an actionable empty state for a Story with no contacts',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PublicationDetailsScreen(
            controller: publishing,
            publication: publication,
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Contact activity'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Contact activity'));
      await tester.pumpAndSettle();
      expect(
        find.text('No contact activity for this Story yet.'),
        findsOneWidget,
      );
    },
  );
}
