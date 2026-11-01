import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_form_field.dart';

import '../../../copy/safety_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../models/report_submission.dart';

enum ReportOutcome { success, failure }

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.target,
    this.targetId,
    this.outcome = ReportOutcome.success,
    this.submit,
    this.initialReason,
    this.submitOnOpen = false,
  });
  final String target;
  final String? targetId;
  final ReportOutcome outcome;
  final Future<ReportOutcome> Function(ReportSubmission submission)? submit;
  final String? initialReason;
  final bool submitOnOpen;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? reason;
  final details = TextEditingController();
  bool submitting = false;
  bool failed = false;
  bool complete = false;

  @override
  void initState() {
    super.initState();
    if (const {
      SafetyCopy.spam,
      SafetyCopy.harassment,
      SafetyCopy.inappropriateContent,
      SafetyCopy.other,
    }.contains(widget.initialReason)) {
      reason = widget.initialReason;
    }
    if (widget.submitOnOpen && reason != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _submit();
      });
    }
  }

  @override
  void dispose() {
    details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (reason == null || submitting) return;
    setState(() {
      submitting = true;
      failed = false;
    });
    final submission = ReportSubmission(
      target: widget.target,
      targetId: widget.targetId,
      reason: reason!,
      details: details.text.trim(),
    );
    ReportOutcome outcome;
    try {
      if (widget.submit == null) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        outcome = widget.outcome;
      } else {
        outcome = await widget.submit!(submission);
      }
    } catch (_) {
      outcome = ReportOutcome.failure;
    }
    if (!mounted) return;
    setState(() {
      submitting = false;
      failed = outcome == ReportOutcome.failure;
      complete = !failed;
    });
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(SafetyCopy.report)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (complete) ...[
          const Icon(Icons.check_circle_outline, size: 54),
          const SizedBox(height: 12),
          const Text(SafetyCopy.reportSubmitted, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            SafetyCopy.reportThanks(widget.target),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.done),
          ),
        ] else ...[
          Text(
            SafetyCopy.reportTarget(widget.target),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(SafetyCopy.whyAreYouReportingThis),
          RadioGroup<String>(
            groupValue: reason,
            onChanged: (value) => setState(() => reason = value),
            child: Column(
              children: [
                for (final option in [
                  SafetyCopy.spam,
                  SafetyCopy.harassment,
                  SafetyCopy.inappropriateContent,
                  SafetyCopy.other,
                ])
                  RadioListTile<String>(value: option, title: Text(option)),
              ],
            ),
          ),
          AppFormField(
            controller: details,
            maxLines: 3,
            maxLength: 500,
            label: SafetyCopy.additionalDetailsOptional,
          ),
          if (failed)
            Text(
              SafetyCopy.reportFailureDescription,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: reason == null || submitting ? null : _submit,
            child: Text(
              submitting
                  ? SafetyCopy.submitting
                  : failed
                  ? CommonCopy.retry
                  : SafetyCopy.submitReport,
            ),
          ),
        ],
      ],
    ),
  );
}
