import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/safety_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../settings/models/settings_models.dart';
import '../../../../support/ui/screens/help_screen/help_screen.dart';

class RestrictionScreen extends StatelessWidget {
  const RestrictionScreen({
    super.key,
    required this.level,
    required this.reason,
  });
  final RestrictionLevel level;
  final String reason;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(SafetyCopy.accountNotice)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(
          Icons.info_outline,
          size: 52,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          switch (level) {
            RestrictionLevel.warning => SafetyCopy.accountWarning,
            RestrictionLevel.suspension => SafetyCopy.accountSuspended,
            RestrictionLevel.permanentBan =>
              SafetyCopy.accountPermanentlyRestricted,
          },
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(reason, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          level == RestrictionLevel.warning
              ? SafetyCopy.warningDescription
              : SafetyCopy.restrictionDescription,
        ),
        const SizedBox(height: 20),
        if (level == RestrictionLevel.warning && Navigator.canPop(context))
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.continueLabel),
          ),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
          ),
          child: const Text(SafetyCopy.helpSupport),
        ),
      ],
    ),
  );
}
