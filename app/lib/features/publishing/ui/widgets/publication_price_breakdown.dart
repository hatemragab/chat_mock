import 'package:flutter/material.dart';

import '../../copy/publishing_copy.dart';
import '../../models/publication.dart';

/// Itemized immutable terms, shared by initial review and refreshed-price review.
class PublicationPriceBreakdown extends StatelessWidget {
  const PublicationPriceBreakdown({
    super.key,
    required this.price,
    this.previous,
    this.totalLabel = PublishingCopy.total,
  });

  final PriceReview price;
  final PriceReview? previous;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final before = previous;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in [
          (PublishingCopy.category, price.category, before?.category),
          (PublishingCopy.boost, price.boost, before?.boost),
          (
            PublishingCopy.advertisement,
            price.advertisement,
            before?.advertisement,
          ),
        ])
          if (before == null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(line.$1),
              trailing: Text(PublishingCopy.credits(line.$2)),
            )
          else
            Text(PublishingCopy.changedPriceLine(line.$1, line.$3!, line.$2)),
        if (before == null) const Divider() else const SizedBox(height: 8),
        if (before == null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              totalLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              PublishingCopy.credits(price.total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(
            PublishingCopy.changedTotal(before.total, price.total),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}
