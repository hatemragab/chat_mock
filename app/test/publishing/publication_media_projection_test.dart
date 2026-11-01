import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/publishing/ui/screens/editor_screen/editor_screen.dart';
import 'package:app/features/publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import 'package:app/features/publishing/ui/screens/publication_viewer_screen/publication_viewer_screen.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/stories/ui/widgets/story_media_background.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('photo sample and edits carry from draft to details and Story', (
    tester,
  ) async {
    var name = 'Sam Taylor';
    final wallet = WalletController();
    final publishing = PublishingController(
      wallet: wallet,
      authorName: () => name,
    );
    final stories = StoriesController(publishing: publishing);
    final draft = publishing.createDraft(PublicationType.status)
      ..sample = 'City moments'
      ..caption = 'A city afternoon'
      ..rotation = 1
      ..cropScale = 1.6;

    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(controller: publishing, draft: draft),
      ),
    );
    var preview = tester.widget<StoryMediaBackground>(
      find.byType(StoryMediaBackground).first,
    );
    expect(preview.story.assetPath, 'assets/story/daily_brew.png');
    expect(preview.story.rotation, 1);
    expect(preview.story.cropScale, 1.6);

    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.single;
    final projected = stories.allStories.firstWhere(
      (story) => story.id == publication.id,
    );
    expect(projected.author, 'Sam Taylor');
    expect(projected.assetPath, preview.story.assetPath);
    expect(projected.rotation, preview.story.rotation);
    expect(projected.cropScale, preview.story.cropScale);

    await tester.pumpWidget(
      MaterialApp(
        home: PublicationDetailsScreen(
          controller: publishing,
          publication: publication,
        ),
      ),
    );
    preview = tester.widget<StoryMediaBackground>(
      find.byType(StoryMediaBackground).first,
    );
    expect(preview.story.assetPath, projected.assetPath);
    expect(find.textContaining('Crop 160%'), findsOneWidget);
    expect(find.textContaining('Rotation 90°'), findsOneWidget);

    name = 'Jordan Lee';
    await tester.pumpWidget(
      MaterialApp(
        home: PublicationViewerScreen(
          controller: publishing,
          publication: publication,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Jordan Lee'), findsOneWidget);
    preview = tester.widget<StoryMediaBackground>(
      find.byType(StoryMediaBackground).first,
    );
    expect(preview.story.assetPath, projected.assetPath);
    expect(preview.story.rotation, 1);
    expect(preview.story.cropScale, 1.6);
    await tester.pumpWidget(const SizedBox.shrink());
    stories.dispose();
    publishing.dispose();
    wallet.dispose();
  });

  testWidgets('video Story retains selected cover and bounded trim', (
    tester,
  ) async {
    final wallet = WalletController();
    final publishing = PublishingController(wallet: wallet);
    final draft = publishing.createDraft(PublicationType.status)
      ..media = PublicationMedia.video
      ..sample = 'City moments'
      ..cover = 'Artwork'
      ..trimStart = .2
      ..trimEnd = .7;
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    final publication = publishing.publications.single;
    await tester.pumpWidget(
      MaterialApp(
        home: PublicationViewerScreen(
          controller: publishing,
          publication: publication,
        ),
      ),
    );
    await tester.pump();
    final preview = tester.widget<StoryMediaBackground>(
      find.byType(StoryMediaBackground).first,
    );
    expect(preview.story.assetPath, 'assets/story/maison_studio.png');
    expect(preview.story.trimStart, .2);
    expect(preview.story.trimEnd, .7);
    expect(find.text('Cover: Artwork · Trim 20–70%'), findsOneWidget);
    final before = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last,
        )
        .value!;
    await tester.pump(const Duration(milliseconds: 400));
    final after = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last,
        )
        .value!;
    expect(after, greaterThan(before));
    expect(after, lessThanOrEqualTo(1));
    await tester.pumpWidget(const SizedBox.shrink());
    publishing.dispose();
    wallet.dispose();
  });
}
