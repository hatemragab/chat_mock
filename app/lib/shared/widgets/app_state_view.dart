import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Accessible, scrollable feedback for loading, empty, error and success states.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  }) : assert((actionLabel == null) == (onAction == null));

  final String title;
  final String? description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.xLarge,
      ),
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.large),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.large),
            ],
            Text(title, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.large),
              FilledButton(
                onPressed: loading ? null : onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
