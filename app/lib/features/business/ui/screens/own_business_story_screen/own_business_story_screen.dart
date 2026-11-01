import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../stories/models/story.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../copy/business_copy.dart';

/// Preview of a linked Story using only the public Business identity.
class OwnBusinessStoryScreen extends StatelessWidget {
  const OwnBusinessStoryScreen({super.key, required this.story});
  final Story story;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(BusinessCopy.businessStory)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StoryCover(story: story, height: 320),
        const SizedBox(height: 16),
        Text(story.author, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(story.title),
        const SizedBox(height: 12),
        const Text(BusinessCopy.publicIdentityExplanation),
      ],
    ),
  );
}
