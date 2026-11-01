import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../stories/models/story.dart';
import '../../../../stories/ui/widgets/story_cover.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';
import '../../sheets/business_call_preflight_sheet/business_call_preflight_sheet.dart';
import '../../sheets/business_contact_sheet/business_contact_sheet.dart';
import '../../widgets/business_safety_actions.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({
    super.key,
    required this.controller,
    required this.story,
    this.onCall,
  });
  final BusinessController controller;
  final Story story;
  final BusinessCallCallback? onCall;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final eligible = controller.sourceEligible(story);
      final profile = controller.profileFor(story);
      return AppScaffold(
        appBar: AppHeader(title: const Text(BusinessCopy.businessProfile)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (profile.coverAssetPath case final path?)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  path,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: BusinessCopy.profileCover(profile.name),
                ),
              )
            else
              StoryCover(story: story, height: 180),
            const SizedBox(height: 18),
            Row(
              children: [
                AppAvatar(
                  name: profile.name,
                  radius: 26,
                  image: profile.logoAssetPath == null
                      ? null
                      : AssetImage(profile.logoAssetPath!),
                  semanticLabel: BusinessCopy.profileLogo(profile.name),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profile.category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(profile.description),
            if (profile.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(profile.location),
            ],
            const SizedBox(height: 24),
            Text(
              BusinessCopy.activeStories,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (eligible && !controller.isBlocked(story)) ...[
              StoryCover(
                story: story,
                height: 130,
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => BusinessContactSheet(
                    controller: controller,
                    story: story,
                    onCall: onCall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => BusinessContactSheet(
                    controller: controller,
                    story: story,
                    onCall: onCall,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text(BusinessCopy.contactAboutStory),
              ),
            ] else
              Text(
                controller.isBlocked(story)
                    ? BusinessCopy.blockedBusiness
                    : BusinessCopy.noActiveStories,
              ),
            const SizedBox(height: 16),
            BusinessSafetyActions(controller: controller, story: story),
          ],
        ),
      );
    },
  );
}
