import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../copy/profile_copy.dart';

/// A session-only representation of a selected demo portrait.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.photoLabel,
    this.radius = 42,
  });

  final String name;
  final String? photoLabel;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = photoLabel;
    final outdoor = label == ProfileCopy.outdoorPortrait;
    final background = label == null
        ? colors.primaryContainer
        : outdoor
        ? colors.tertiaryContainer
        : colors.secondaryContainer;
    final foreground = label == null
        ? colors.onPrimaryContainer
        : outdoor
        ? colors.onTertiaryContainer
        : colors.onSecondaryContainer;
    return AppAvatar(
      name: name,
      semanticLabel: label == null
          ? ProfileCopy.avatarSemantics(name)
          : ProfileCopy.photoSemantics(name, label),
      radius: radius,
      backgroundColor: background,
      foregroundColor: foreground,
      textStyle: TextStyle(fontSize: radius * .76, fontWeight: FontWeight.w700),
      child: label == null
          ? null
          : Icon(
              outdoor ? Icons.face_retouching_natural : Icons.person,
              size: radius * 1.18,
            ),
    );
  }
}
