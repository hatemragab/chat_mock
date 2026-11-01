import 'package:flutter/material.dart';

/// Keeps readable amounts inline only when they fit alongside receipt context.
bool walletAmountFitsInline(
  BuildContext context,
  String value,
  double availableWidth, {
  FontWeight? weight,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: value,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(fontWeight: weight),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final fits = painter.width <= availableWidth * .4;
  painter.dispose();
  return fits;
}
