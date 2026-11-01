import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../../dialogs/photo_slot_limit_dialog/photo_slot_limit_dialog.dart';
import '../../dialogs/price_changed_dialog/price_changed_dialog.dart';
import '../../widgets/publication_price_breakdown.dart';
import '../publication_details_screen/publication_details_screen.dart';

class PriceReviewScreen extends StatefulWidget {
  const PriceReviewScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.initialReview,
    this.startOnOpen = false,
    this.simulateFailureOnFirstSubmission = false,
    this.submissionDelay = const Duration(milliseconds: 250),
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final PriceReview? initialReview;
  final bool startOnOpen;
  final bool simulateFailureOnFirstSubmission;
  final Duration submissionDelay;
  @override
  State<PriceReviewScreen> createState() => _PriceReviewScreenState();
}

class _PriceReviewScreenState extends State<PriceReviewScreen> {
  late PriceReview reviewed =
      widget.initialReview ?? widget.controller.review(widget.draft);
  bool submitting = false;
  String? error;
  bool _failureOverrideActive = false;
  bool _previousFailure = false;
  bool _failureUsed = false;

  @override
  void initState() {
    super.initState();
    if (widget.startOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) publish();
      });
    }
  }

  void _restoreFailureOverride() {
    if (_failureOverrideActive) {
      widget.controller.failNextPublish = _previousFailure;
      _failureOverrideActive = false;
    }
  }

  @override
  void dispose() {
    _restoreFailureOverride();
    super.dispose();
  }

  Future<void> publish() async {
    if (submitting) return;
    if (widget.simulateFailureOnFirstSubmission && !_failureUsed) {
      _failureUsed = true;
      _previousFailure = widget.controller.failNextPublish;
      widget.controller.failNextPublish = true;
      _failureOverrideActive = true;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    await Future<void>.delayed(widget.submissionDelay);
    if (!mounted) return;
    final result = widget.controller.publish(widget.draft, reviewed);
    _restoreFailureOverride();
    setState(() => submitting = false);
    switch (result) {
      case PublishResult.success:
        final publication = widget.controller.publications.firstWhere(
          (p) => p.id == widget.draft.id,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PublicationDetailsScreen(
              controller: widget.controller,
              publication: publication,
            ),
          ),
        );
      case PublishResult.changedPrice:
        final updated = widget.controller.review(widget.draft);
        final accepted = await showDialog<bool>(
          context: context,
          builder: (_) =>
              PriceChangedDialog(previous: reviewed, updated: updated),
        );
        if (mounted && accepted == true) setState(() => reviewed = updated);
      case PublishResult.insufficientCredits:
        await showModalBottomSheet<void>(
          context: context,
          builder: (_) => InsufficientCreditsSheet(
            controller: widget.controller.wallet,
            requiredCredits: reviewed.total,
          ),
        );
      case PublishResult.noSlots:
        await showDialog<void>(
          context: context,
          builder: (_) => PhotoSlotLimitDialog(
            used: widget.controller.usedPhotoSlots,
            limit: widget.controller.config.photoSlots,
          ),
        );
      case PublishResult.failed:
        setState(() => error = PublishingCopy.publishFailure);
      case PublishResult.restricted:
        setState(() => error = PublishingCopy.publishRestricted);
      case PublishResult.missingMedia:
        setState(() => error = PublishingCopy.publishMissingMedia);
      case PublishResult.inProgress:
        setState(() => error = PublishingCopy.publishInProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return AppScaffold(
      appBar: AppHeader(title: const Text(PublishingCopy.reviewAndPublish)),
      body: ListenableBuilder(
        listenable: widget.controller.wallet,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(draft.sample, style: Theme.of(context).textTheme.titleLarge),
            Text(
              PublishingCopy.draftSummary(
                draft.category,
                draft.media.name,
                draft.type.name,
              ),
            ),
            if (draft.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(draft.caption),
              ),
            const SizedBox(height: 18),
            PublicationPriceBreakdown(price: reviewed),
            Text(PublishingCopy.balance(widget.controller.wallet.credits)),
            Text(PublishingCopy.lifetime(draft.effectiveBoost ? 48 : 24)),
            if (draft.consumesSlot)
              Text(
                PublishingCopy.photoSlots(
                  widget.controller.usedPhotoSlots,
                  widget.controller.config.photoSlots,
                ),
              ),
            if (draft.type == PublicationType.advertisement)
              Text(
                PublishingCopy.audienceReview(
                  draft.location,
                  draft.radiusKm.round(),
                  draft.gender,
                  draft.interest,
                ),
              ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: submitting ? null : publish,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(PublishingCopy.publish),
            ),
          ],
        ),
      ),
    );
  }
}
