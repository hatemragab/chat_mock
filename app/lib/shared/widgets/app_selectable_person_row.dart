import 'package:flutter/material.dart';

import 'app_avatar.dart';

/// A person selection whose checkbox and row share one enabled state.
class AppSelectablePersonRow extends StatelessWidget {
  const AppSelectablePersonRow({
    super.key,
    required this.name,
    required this.selected,
    required this.onChanged,
    this.subtitle,
    this.contentPadding,
  });

  final String name;
  final bool selected;
  final ValueChanged<bool?>? onChanged;
  final String? subtitle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: selected,
    onChanged: onChanged,
    contentPadding: contentPadding,
    controlAffinity: ListTileControlAffinity.trailing,
    secondary: AppAvatar(name: name),
    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null
        ? null
        : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
}
