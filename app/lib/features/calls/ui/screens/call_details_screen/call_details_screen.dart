import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';
import '../../dialogs/delete_call_dialog/delete_call_dialog.dart';
import '../../widgets/business_call_story_cover.dart';
import '../call_screen/call_screen.dart';

class CallDetailsScreen extends StatelessWidget {
  const CallDetailsScreen({
    super.key,
    required this.call,
    this.controller,
    this.onMessage,
  });
  final CallSession call;
  final CallsController? controller;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final controls = controller;
    final story = call.business ? call.story : null;
    final identityName = story?.author ?? call.name;
    return AppScaffold(
      appBar: AppHeader(
        title: const Text(CallsCopy.callDetails),
        actions: [
          if (controls != null)
            IconButton(
              tooltip: CallsCopy.deleteCall,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => DeleteCallDialog(call: call),
                );
                if (confirmed == true && context.mounted) {
                  controls.deleteHistory(call);
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: story != null
                ? BusinessCallStoryCover(story: story, size: 100)
                : AppAvatar(name: call.name, radius: 36),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              identityName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(
              call.kind == CallKind.audio
                  ? Icons.call_outlined
                  : Icons.videocam_outlined,
            ),
            title: Text(
              CallsCopy.directionKind(call.incoming, call.kind.label),
            ),
            subtitle: Text(call.phase.label),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text(CallsCopy.duration),
            trailing: Text(CallsCopy.durationValue(call.seconds)),
          ),
          if (call.business) ...[
            ListTile(
              leading: const Icon(Icons.toll_outlined),
              title: const Text(CallsCopy.cost),
              trailing: Text(CallsCopy.creditCost(call.totalCost)),
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text(CallsCopy.originatingStory),
              subtitle: Text(story?.title ?? identityName),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(CallsCopy.returnToStoryToPlace),
            ),
          ],
          if (call.endReason != null) ListTile(title: Text(call.endReason!)),
          if (!call.business && controls != null)
            ListenableBuilder(
              listenable: controls.changes,
              builder: (context, _) => FilledButton.icon(
                onPressed: controls.canRecall(call)
                    ? () {
                        // Eligibility may have changed since the last build.
                        if (!controls.canRecall(call)) return;
                        final next = controls.start(
                          name: controls.nameForRedial(call),
                          kind: call.kind,
                          contactId: call.contactId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CallScreen(controller: controls, call: next),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.call),
                label: const Text(CallsCopy.callAgain),
              ),
            ),
          if (onMessage != null && !call.business)
            TextButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_outlined),
              label: const Text(CallsCopy.message),
            ),
        ],
      ),
    );
  }
}
