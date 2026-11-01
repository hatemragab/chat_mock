import 'package:flutter/material.dart';

import '../../controllers/calls_controller.dart';
import '../../copy/calls_copy.dart';
import '../../models/call_session.dart';
import 'business_call_story_cover.dart';

class MinimizedCallBar extends StatelessWidget {
  const MinimizedCallBar({
    super.key,
    required this.controller,
    required this.onReturn,
  });
  final CallsController controller;
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final call = controller.active;
      if (call == null || !call.minimized) return const SizedBox.shrink();
      final story = call.business ? call.story : null;
      final time = CallsCopy.elapsed(call.seconds);
      final status = switch (call.phase) {
        CallPhase.ringing => CallsCopy.ringing,
        CallPhase.incoming => CallsCopy.incomingKind(call.kind.label),
        CallPhase.reconnecting => CallsCopy.reconnecting(time),
        _ => time,
      };
      return Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  dense: true,
                  leading: story == null
                      ? const Icon(Icons.call)
                      : BusinessCallStoryCover(story: story, size: 44),
                  title: Text(
                    story?.author ?? call.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    CallsCopy.minimizedSubtitle(
                      status,
                      lowBalance: controller.lowBalance,
                      storyTitle: story?.title,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: onReturn,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (call.phase == CallPhase.ringing ||
                      call.phase == CallPhase.incoming) {
                    controller.finishRinging(
                      call.incoming ? CallPhase.declined : CallPhase.cancelled,
                    );
                  } else {
                    controller.end();
                  }
                },
                icon: const Icon(Icons.call_end),
                tooltip: CallsCopy.endCall,
              ),
            ],
          ),
        ),
      );
    },
  );
}
