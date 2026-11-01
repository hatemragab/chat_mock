import 'package:flutter/material.dart';

import '../../../copy/chats_copy.dart';

class ReactionPickerSheet extends StatelessWidget {
  const ReactionPickerSheet({super.key, this.currentReaction});
  final String? currentReaction;
  static const reactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '🎉',
    '👏',
    '🔥',
    '😊',
    '💡',
    '💯',
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ChatCopy.chooseAReaction,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final reaction in reactions)
                IconButton(
                  tooltip: ChatCopy.reactWith(reaction),
                  onPressed: () => Navigator.pop(context, reaction),
                  icon: Text(reaction, style: const TextStyle(fontSize: 24)),
                ),
            ],
          ),
          if (currentReaction != null)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text(ChatCopy.removeReaction),
            ),
        ],
      ),
    ),
  );
}
