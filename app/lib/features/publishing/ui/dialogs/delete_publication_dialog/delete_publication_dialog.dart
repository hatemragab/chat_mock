import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

import '../../../models/publication.dart';

class DeletePublicationDialog extends StatelessWidget {
  const DeletePublicationDialog({super.key, required this.publication});
  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final title = publication.caption.isEmpty
        ? publication.sample
        : publication.caption;
    return AlertDialog(
      title: const Text(PublishingCopy.deletePublicationTitle),
      content: Text(PublishingCopy.deletionConsequences(title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(CommonCopy.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(CommonCopy.delete),
        ),
      ],
    );
  }
}
