import 'package:flutter/material.dart';

import '../../copy/prototype_tools_copy.dart';

import '../../../business/controllers/business_controller.dart';
import '../../../business/models/business_room.dart';
import '../../../business/ui/screens/business_profile_screen/business_profile_screen.dart';
import '../../../groups/controllers/group_controller.dart';
import '../../../groups/ui/screens/group_screen/group_screen.dart';
import '../../../stories/controllers/stories_controller.dart';

class GroupBusinessControls extends StatelessWidget {
  const GroupBusinessControls({
    super.key,
    required this.group,
    required this.business,
    required this.onAdvanceClock,
  });
  final GroupController group;
  final BusinessController business;
  final ValueChanged<Duration> onAdvanceClock;

  @override
  Widget build(BuildContext context) {
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'maison',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          PrototypeToolsCopy.groupPerspective,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          key: ValueKey('group-perspective-${group.perspectiveId}'),
          initialValue: group.perspectiveId,
          decoration: const InputDecoration(
            labelText: PrototypeToolsCopy.reviewAsMember,
          ),
          items: group.members
              .map(
                (member) => DropdownMenuItem(
                  value: member.id,
                  child: Text(
                    PrototypeToolsCopy.memberSummary(
                      member.name,
                      member.role.name,
                      member.active,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) group.setPerspective(id);
          },
        ),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => GroupScreen(controller: group),
            ),
          ),
          icon: const Icon(Icons.groups_outlined),
          label: const Text(PrototypeToolsCopy.openGroup),
        ),
        const SizedBox(height: 16),
        Text(
          PrototypeToolsCopy.businessRoom,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<BusinessPerspective>(
          isExpanded: true,
          key: ValueKey('business-perspective-${business.perspective.name}'),
          initialValue: business.perspective,
          decoration: const InputDecoration(
            labelText: PrototypeToolsCopy.reviewAs,
          ),
          items: const [
            DropdownMenuItem(
              value: BusinessPerspective.customer,
              child: Text(
                PrototypeToolsCopy.customerPayer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: BusinessPerspective.recipient,
              child: Text(
                PrototypeToolsCopy.businessRecipient,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) business.setPerspective(value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(PrototypeToolsCopy.storyAvailable(story.author)),
          subtitle: const Text(PrototypeToolsCopy.roomExpiryDescription),
          value: business.sourceEligible(story),
          onChanged: (value) => business.setSourceEligible(story.id, value),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule),
          title: const Text(
            PrototypeToolsCopy.advanceBusinessRoomClockBy24Hours,
          ),
          subtitle: const Text(
            PrototypeToolsCopy.reviewRoomExpiryWithoutWaiting,
          ),
          onTap: () => onAdvanceClock(const Duration(hours: 24)),
        ),
        if (business.perspective == BusinessPerspective.recipient &&
            business.roomFor(story.id) == null)
          TextButton(
            onPressed: () => business.seedRecipientRoom(story),
            child: const Text(PrototypeToolsCopy.addAnIncomingRoomFixture),
          ),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  BusinessProfileScreen(controller: business, story: story),
            ),
          ),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text(PrototypeToolsCopy.openBusinessProfile),
        ),
      ],
    );
  }
}
