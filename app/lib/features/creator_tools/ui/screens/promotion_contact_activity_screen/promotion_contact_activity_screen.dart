import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/creator_tools_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../business/models/business_room.dart';
import '../../../../business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import '../../../../calls/models/call_session.dart';
import '../../../../calls/ui/screens/call_details_screen/call_details_screen.dart';
import '../../../../calls/ui/screens/call_screen/call_screen.dart';
import '../../../../publishing/models/publication.dart';
import '../../../controllers/creator_activity_controller.dart';

class PromotionContactActivityScreen extends StatelessWidget {
  const PromotionContactActivityScreen({
    super.key,
    required this.controller,
    required this.publication,
  });

  final CreatorActivityController controller;
  final Publication publication;

  Future<void> _openRoom(BuildContext context, BusinessRoom room) async {
    final previous = controller.business.perspective;
    controller.business.setPerspective(BusinessPerspective.recipient);
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => BusinessConversationScreen(
            controller: controller.business,
            story: room.story,
          ),
        ),
      );
    } finally {
      if (context.mounted) controller.business.setPerspective(previous);
    }
  }

  void _openCall(BuildContext context, CallSession call) {
    if (identical(controller.calls.active, call)) {
      controller.calls.setMinimized(false);
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => identical(controller.calls.active, call)
            ? CallScreen(controller: controller.calls, call: call)
            : CallDetailsScreen(call: call),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(CreatorToolsCopy.contactActivity)),
    body: ListenableBuilder(
      listenable: controller.changes,
      builder: (context, _) {
        final room = controller.roomFor(publication);
        final calls = controller.callsFor(publication);
        final title = publication.caption.isEmpty
            ? publication.sample
            : publication.caption;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              CreatorToolsCopy.publicationState(
                publication.category,
                publication.status.name,
              ),
            ),
            const SizedBox(height: 16),
            const Text(CreatorToolsCopy.contactActivityDescription),
            const SizedBox(height: 18),
            if (room == null && calls.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    CreatorToolsCopy.noContactActivityForThisStoryYet,
                  ),
                ),
              ),
            if (room != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text(CreatorToolsCopy.businessMessageRoom),
                subtitle: Text(
                  CreatorToolsCopy.roomActivity(
                    controller.business.isActive(room),
                    room.messages.length,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openRoom(context, room),
              ),
            for (final call in calls)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  call.kind == CallKind.audio
                      ? Icons.call_outlined
                      : Icons.videocam_outlined,
                ),
                title: Text(CreatorToolsCopy.businessCall(call.kind.name)),
                subtitle: Text(
                  CreatorToolsCopy.callActivity(call.incoming, call.phase.name),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openCall(context, call),
              ),
          ],
        );
      },
    ),
  );
}
