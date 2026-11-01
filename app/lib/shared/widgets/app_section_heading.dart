import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Consistent section hierarchy with an optional action that keeps its space.
class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({
    super.key,
    required this.title,
    this.trailing,
    this.style,
  });

  final String title;
  final Widget? trailing;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style:
                style ??
                Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      if (trailing != null) ...[
        const SizedBox(width: AppSpacing.small),
        trailing!,
      ],
    ],
  );
}
