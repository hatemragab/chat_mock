import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

import '../../../models/publication.dart';

class BoostOptionsSheet extends StatefulWidget {
  const BoostOptionsSheet({super.key, required this.draft, required this.fee});
  final PublicationDraft draft;
  final int fee;
  @override
  State<BoostOptionsSheet> createState() => _BoostOptionsSheetState();
}

class _BoostOptionsSheetState extends State<BoostOptionsSheet> {
  late bool selected = widget.draft.effectiveBoost;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              PublishingCopy.boostYourPublication,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(PublishingCopy.boostTerms(widget.fee)),
            if (widget.draft.requiresBoost)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(PublishingCopy.boostIsRequiredForVideoAndAudio),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(PublishingCopy.boost),
              value: selected,
              onChanged: widget.draft.requiresBoost
                  ? null
                  : (value) => setState(() => selected = value),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text(CommonCopy.continueLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(CommonCopy.cancel),
            ),
          ],
        ),
      ),
    ),
  );
}
