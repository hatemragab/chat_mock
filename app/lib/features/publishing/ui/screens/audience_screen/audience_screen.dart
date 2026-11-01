import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../price_review_screen/price_review_screen.dart';
import '../target_area_screen/target_area_screen.dart';

class AudienceScreen extends StatefulWidget {
  const AudienceScreen({
    super.key,
    required this.controller,
    required this.draft,
    this.initiallyShowLocation = false,
    this.locationDenied = false,
  });
  final PublishingController controller;
  final PublicationDraft draft;
  final bool initiallyShowLocation;
  final bool locationDenied;
  @override
  State<AudienceScreen> createState() => _AudienceScreenState();
}

class _AudienceScreenState extends State<AudienceScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initiallyShowLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openTargetArea();
      });
    }
  }

  Future<void> _openTargetArea() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TargetAreaScreen(
          draft: widget.draft,
          locationDenied: widget.locationDenied,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.chooseYourAudience)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(PublishingCopy.audienceDescription),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.location_on_outlined),
          title: const Text(PublishingCopy.targetArea),
          subtitle: Text(
            PublishingCopy.audienceLocation(
              widget.draft.location,
              widget.draft.radiusKm.round(),
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openTargetArea,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: widget.draft.gender,
          decoration: const InputDecoration(labelText: PublishingCopy.gender),
          items: ['Everyone', 'Women', 'Men']
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(PublishingCopy.genderLabel(v)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => widget.draft.gender = v);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: widget.draft.interest,
          decoration: const InputDecoration(labelText: PublishingCopy.interest),
          items: ['Lifestyle', 'Design', 'Food', 'Shopping']
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(PublishingCopy.categoryLabel(v)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => widget.draft.interest = v);
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PriceReviewScreen(
                controller: widget.controller,
                draft: widget.draft,
              ),
            ),
          ),
          child: const Text(PublishingCopy.reviewPrice),
        ),
      ],
    ),
  );
}
