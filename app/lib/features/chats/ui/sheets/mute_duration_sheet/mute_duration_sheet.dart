import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/chats_copy.dart';

enum MuteChoice { eightHours, oneWeek, always, unmute }

/// A null result means the sheet was dismissed without changing the setting.
class MuteDurationSheet extends StatelessWidget {
  const MuteDurationSheet({
    super.key,
    required this.name,
    required this.isMuted,
  });
  final String name;
  final bool isMuted;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              ChatCopy.muteTitle(name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final option in [
            (MuteChoice.eightHours, ChatCopy.eightHours),
            (MuteChoice.oneWeek, ChatCopy.oneWeek),
            (MuteChoice.always, ChatCopy.always),
          ])
            ListTile(
              title: Text(option.$2),
              onTap: () => Navigator.pop(context, option.$1),
            ),
          if (isMuted)
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text(ChatCopy.unmute),
              onTap: () => Navigator.pop(context, MuteChoice.unmute),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.cancel),
          ),
        ],
      ),
    ),
  );
}
