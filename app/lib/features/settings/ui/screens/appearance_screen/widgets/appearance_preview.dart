import '../../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

/// A compact sample of the current theme and the chosen app text size.
class AppearancePreview extends StatelessWidget {
  const AppearancePreview({
    super.key,
    required this.textScaleFactor,
    this.inheritsAppTextScale = false,
  });
  final double textScaleFactor;
  final bool inheritsAppTextScale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sampleSize = 14.0 * (inheritsAppTextScale ? 1.0 : textScaleFactor);
    return Semantics(
      label: SettingsCopy.appearancePreview,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    size: 19,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sarah Wilson',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sampleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  SettingsCopy.lookingForwardToSeeingYou,
                  style: TextStyle(
                    fontSize: sampleSize,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
