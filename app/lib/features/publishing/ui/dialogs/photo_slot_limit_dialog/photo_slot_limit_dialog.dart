import 'package:flutter/material.dart';

import '../../../copy/publishing_copy.dart';

class PhotoSlotLimitDialog extends StatelessWidget {
  const PhotoSlotLimitDialog({
    super.key,
    required this.used,
    required this.limit,
  });
  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(PublishingCopy.photoStatusLimitReached),
    content: Text(PublishingCopy.photoSlotLimit(used, limit)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(PublishingCopy.ok),
      ),
    ],
  );
}
