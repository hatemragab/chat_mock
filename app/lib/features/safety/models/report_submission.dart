/// The target and draft are kept together so retries retain their context.
class ReportSubmission {
  const ReportSubmission({
    required this.target,
    required this.reason,
    required this.details,
    this.targetId,
  });
  final String target;
  final String? targetId;
  final String reason;
  final String details;
}
