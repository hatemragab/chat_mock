import 'package:flutter/material.dart';

import '../copy/prototype_tools_copy.dart';

import '../../publishing/models/publication.dart';
import '../../publishing/ui/screens/audience_screen/audience_screen.dart';
import '../../publishing/ui/screens/price_review_screen/price_review_screen.dart';
import '../../safety/ui/screens/report_screen/report_screen.dart';
import '../../settings/models/settings_models.dart';
import '../../settings/ui/screens/delete_account_screen/delete_account_screen.dart';
import '../../stories/controllers/stories_controller.dart';
import '../../wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import '../../wallet/ui/screens/withdrawal_form_screen/withdrawal_form_screen.dart';
import 'review_actions.dart';

/// IDs handled by these context-backed, in-memory review flows.
const commerceMissingIds = <String>{
  'D14',
  'D20',
  'V075',
  'V079',
  'V080',
  'V081',
  'V083',
  'V108',
  'V110',
  'V112',
  'V113',
  'V126',
  'V127',
};

int _validWithdrawalAmount(ReviewActions actions) {
  final config = actions.wallet.config;
  return config.withdrawalMinimum > config.withdrawalFee
      ? config.withdrawalMinimum
      : config.withdrawalFee + 1;
}

bool canOpenCommerceMissing(ReviewActions actions, String id) {
  if (!commerceMissingIds.contains(id)) return false;
  switch (id) {
    case 'D20':
      return actions.onSignOut != null;
    case 'V083':
      return actions.settings?.permissions.containsKey('Location') ?? false;
    case 'D14':
    case 'V079':
      return actions.publishing.canPublish?.call() ?? true;
    case 'V075':
      return actions.publishing.availablePhotoSlots > 0 &&
          actions.wallet.credits >= actions.publishing.config.categoryFee &&
          (actions.publishing.canPublish?.call() ?? true);
    case 'V080':
    case 'V081':
      return actions.publishing.availablePhotoSlots > 0 &&
          (actions.publishing.canPublish?.call() ?? true);
    case 'V108':
      return actions.wallet.diamonds > 0;
    case 'V112':
      return actions.wallet.cash >= _validWithdrawalAmount(actions);
    case 'V113':
      return actions.wallet.cash >= _validWithdrawalAmount(actions) &&
          actions.wallet.withdrawalFrequencyLimitReached;
    default:
      return true;
  }
}

/// Opens the real feature surface. Availability can depend on the demo session.
Future<void> openCommerceMissing(
  ReviewActions actions,
  BuildContext context,
  String id,
) async {
  if (!canOpenCommerceMissing(actions, id)) return;
  switch (id) {
    case 'D20':
      // The real explanation and acknowledgement remain mandatory before D20.
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DeleteAccountScreen(onDelete: actions.onSignOut!),
        ),
      );
    case 'V075':
      final draft = actions.publishing.createDraft(PublicationType.status)
        ..paidCategory = true
        ..media = PublicationMedia.photo
        ..category = 'Business';
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              PriceReviewScreen(controller: actions.publishing, draft: draft),
        ),
      );
    case 'D14':
    case 'V079':
      final controller = actions.publishing;
      final draft = controller.createDraft(PublicationType.status)
        ..paidCategory = true
        ..category = 'Business';
      final current = controller.review(draft);
      // The review fixture represents earlier terms without changing the
      // retained configuration or invalidating other open drafts.
      final previous = PriceReview(
        category: current.category + 1,
        boost: current.boost,
        advertisement: current.advertisement,
        revision: current.revision,
      );
      if (!context.mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PriceReviewScreen(
            controller: controller,
            draft: draft,
            initialReview: previous,
            startOnOpen: true,
          ),
        ),
      );
    case 'V080':
    case 'V081':
      final draft = actions.publishing.createDraft(PublicationType.status)
        ..category = 'Everyday';
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PriceReviewScreen(
            controller: actions.publishing,
            draft: draft,
            startOnOpen: true,
            simulateFailureOnFirstSubmission: id == 'V081',
            submissionDelay: id == 'V080'
                ? const Duration(seconds: 3)
                : const Duration(milliseconds: 250),
          ),
        ),
      );
    case 'V083':
      final settings = actions.settings!;
      final previous = settings.permissions['Location']!;
      settings.setPermission('Location', MockPermission.denied);
      final draft = actions.publishing.createDraft(
        PublicationType.advertisement,
      );
      try {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AudienceScreen(
              controller: actions.publishing,
              draft: draft,
              initiallyShowLocation: true,
              locationDenied: true,
            ),
          ),
        );
      } finally {
        settings.setPermission('Location', previous);
      }
    case 'V108':
      final wallet = actions.wallet;
      final previous = wallet.failNextConversion;
      wallet.setConversionFailure(true);
      try {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ConvertDiamondsScreen(
              controller: wallet,
              initialAmount: 1,
              openReviewOnStart: true,
            ),
          ),
        );
      } finally {
        wallet.setConversionFailure(previous);
      }
    case 'V110':
    case 'V112':
    case 'V113':
      final value = id == 'V110'
          ? actions.wallet.config.withdrawalMinimum - 1
          : _validWithdrawalAmount(actions);
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => WithdrawalFormScreen(
            controller: actions.wallet,
            initialAmount: value,
            initialDestination: id == 'V112' ? '123' : '670000000',
            validateInitially: true,
          ),
        ),
      );
    case 'V126':
    case 'V127':
      final story = StoriesController.stories.first;
      var failNext = id == 'V127';
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReportScreen(
            target: PrototypeToolsCopy.storyTarget(story.author, story.title),
            targetId: story.id,
            submit: (_) async {
              await Future<void>.delayed(const Duration(milliseconds: 350));
              if (failNext) {
                failNext = false;
                return ReportOutcome.failure;
              }
              return ReportOutcome.success;
            },
            initialReason: 'Spam',
            submitOnOpen: true,
          ),
        ),
      );
  }
}
