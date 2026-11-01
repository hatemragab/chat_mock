import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

import '../../../models/publication.dart';
import '../../widgets/publication_price_breakdown.dart';

/// The caller applies [updated] only after the reviewer accepts the new terms.
class PriceChangedDialog extends StatelessWidget {
  const PriceChangedDialog({
    super.key,
    required this.previous,
    required this.updated,
  });
  final PriceReview previous;
  final PriceReview updated;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(PublishingCopy.priceChanged),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(PublishingCopy.priceChangedDescription),
          const SizedBox(height: 12),
          PublicationPriceBreakdown(price: updated, previous: previous),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(CommonCopy.cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text(PublishingCopy.reviewUpdatedPrice),
      ),
    ],
  );
}
