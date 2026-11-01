import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_header.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';
import '../../widgets/business_call_story_cover.dart';
import '../call_screen/call_screen.dart';

class CallSummaryScreen extends StatelessWidget {
  const CallSummaryScreen({
    super.key,
    required this.controller,
    required this.call,
  });
  final CallsController controller;
  final CallSession call;
  @override
  Widget build(BuildContext context) {
    final story = call.business ? call.story : null;
    final identityName = story?.author ?? call.name;
    return AppScaffold(
      appBar: AppHeader(title: const Text(CallsCopy.callSummary)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: story != null
                ? BusinessCallStoryCover(story: story, size: 100)
                : AppAvatar(
                    name: call.name,
                    radius: 40,
                    textStyle: const TextStyle(fontSize: 28),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              identityName,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (story != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                story.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text(CallsCopy.result),
            trailing: Text(call.phase.label),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text(CallsCopy.duration),
            trailing: Text(CallsCopy.durationValue(call.seconds)),
          ),
          if (call.business)
            ListTile(
              leading: const Icon(Icons.toll_outlined),
              title: const Text(CallsCopy.charged),
              trailing: Text(CallsCopy.creditCost(call.totalCost)),
            ),
          if (call.endReason != null)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(call.endReason!),
            ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: controller.changes,
            builder: (context, _) => FilledButton.icon(
              onPressed: controller.canRecall(call)
                  ? () {
                      if (!controller.canRecall(call)) return;
                      final next = controller.start(
                        name: controller.nameForRedial(call),
                        kind: call.kind,
                        contactId: call.contactId,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CallScreen(controller: controller, call: next),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.call),
              label: const Text(CallsCopy.callAgain),
            ),
          ),
          if (call.business)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(CallsCopy.returnToStoryToStart),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.done),
          ),
        ],
      ),
    );
  }
}
