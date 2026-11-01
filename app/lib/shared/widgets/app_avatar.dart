import 'package:flutter/material.dart';

/// Circular identity artwork or a Unicode-safe initial.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.image,
    this.child,
  });

  final String name;
  final double radius;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final ImageProvider? image;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      backgroundImage: image,
      child: image != null
          ? null
          : child ??
                Text(
                  name.isEmpty ? '?' : name.characters.first,
                  style: textStyle,
                ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: avatar)
        : Semantics(
            label: semanticLabel,
            child: ExcludeSemantics(child: avatar),
          );
  }
}
