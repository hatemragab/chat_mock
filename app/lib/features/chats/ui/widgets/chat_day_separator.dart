import 'package:flutter/material.dart';

import '../utils/chat_timeline.dart';

class ChatDaySeparator extends StatelessWidget {
  const ChatDaySeparator({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ChatTimeline.dayLabel(time),
        style: const TextStyle(fontSize: 11),
      ),
    ),
  );
}
