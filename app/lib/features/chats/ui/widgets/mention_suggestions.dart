import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../models/chat_mention_candidate.dart';

class MentionSuggestions extends StatelessWidget {
  const MentionSuggestions({
    super.key,
    required this.candidates,
    required this.onSelected,
  });

  final List<ChatMentionCandidate> candidates;
  final ValueChanged<ChatMentionCandidate> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          final candidate = candidates[index];
          return ListTile(
            dense: true,
            leading: AppAvatar(name: candidate.name),
            title: Text(
              candidate.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSelected(candidate),
          );
        },
      ),
    ),
  );
}
