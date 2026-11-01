import 'package:flutter/material.dart';

import 'app_avatar.dart';

/// Shared compact identity row for contacts, members and message recipients.
class AppPersonRow extends StatelessWidget {
  const AppPersonRow({
    super.key,
    required this.name,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.contentPadding,
    this.subtitleMaxLines = 1,
  });

  final String name;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final int subtitleMaxLines;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    contentPadding: contentPadding,
    leading: AppAvatar(name: name),
    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null
        ? null
        : Text(
            subtitle!,
            maxLines: subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
    trailing: trailing,
    onTap: enabled ? onTap : null,
    onLongPress: enabled ? onLongPress : null,
  );
}
