import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Shared title geometry for the compact Whizpee navigation header.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight,
    this.titleSpacing,
  });

  final Widget title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? toolbarHeight;
  final double? titleSpacing;

  double get _height =>
      toolbarHeight ??
      (subtitle == null
          ? AppGeometry.headerHeight
          : AppGeometry.subtitleHeaderHeight);

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: _height,
    leadingWidth: AppGeometry.iconTarget,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    titleSpacing: titleSpacing,
    title: DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: subtitle == null
          ? title
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
    ),
    actions: actions
        ?.map(
          (action) => SizedBox(
            width: AppGeometry.iconTarget,
            height: AppGeometry.iconTarget,
            child: action,
          ),
        )
        .toList(growable: false),
  );
}
