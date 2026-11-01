import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../../calls/controllers/calls_controller.dart';
import '../../../../calls/ui/screens/call_screen/call_screen.dart';
import '../../../../calls/ui/screens/calls_screen/calls_screen.dart';
import '../../../../calls/ui/widgets/minimized_call_bar.dart';
import '../../../../chats/controllers/chats_controller.dart';

/// Hosts the same minimized call bar used by the application shell.
class ReviewMinimizedCallScreen extends StatelessWidget {
  const ReviewMinimizedCallScreen({
    super.key,
    required this.calls,
    required this.chats,
  });
  final CallsController calls;
  final ChatsController chats;

  @override
  Widget build(BuildContext context) => AppScaffold(
    safeArea: false,
    body: Column(
      children: [
        MinimizedCallBar(
          controller: calls,
          onReturn: () {
            final call = calls.active;
            if (call == null) return;
            calls.setMinimized(false);
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CallScreen(controller: calls, call: call),
              ),
            );
          },
        ),
        Expanded(
          child: CallsScreen(controller: calls, chats: chats),
        ),
      ],
    ),
  );
}
