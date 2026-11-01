import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../models/publication.dart';
import '../../sheets/target_area_sheet/target_area_sheet.dart';

class TargetAreaScreen extends StatefulWidget {
  const TargetAreaScreen({
    super.key,
    required this.draft,
    this.locationDenied = false,
  });
  final PublicationDraft draft;
  final bool locationDenied;

  @override
  State<TargetAreaScreen> createState() => _TargetAreaScreenState();
}

class _TargetAreaScreenState extends State<TargetAreaScreen> {
  late final TextEditingController country = TextEditingController(
    text: widget.draft.country,
  );
  late final TextEditingController city = TextEditingController(
    text: widget.draft.city,
  );
  late final TextEditingController neighbourhood = TextEditingController(
    text: widget.draft.neighbourhood,
  );
  late double radius = widget.draft.radiusKm.clamp(1, 100);
  String? error;

  @override
  void dispose() {
    country.dispose();
    city.dispose();
    neighbourhood.dispose();
    super.dispose();
  }

  void save() {
    if (country.text.trim().isEmpty) {
      setState(() => error = PublishingCopy.enterACountry);
      return;
    }
    final draft = widget.draft;
    draft.country = country.text.trim();
    draft.city = city.text.trim();
    draft.neighbourhood = neighbourhood.text.trim();
    draft.radiusKm = radius;
    draft.location = [
      draft.neighbourhood,
      draft.city,
      draft.country,
    ].where((part) => part.isNotEmpty).join(', ');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(PublishingCopy.targetArea)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          PublishingCopy.chooseAnAreaManually,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (widget.locationDenied) ...[
          Text(
            PublishingCopy.locationDeniedDescription,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        const Text(PublishingCopy.schematicMapDescription),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 42,
                ),
                Text(PublishingCopy.approximateRadius(radius.round())),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            final area = await showModalBottomSheet<TargetArea>(
              context: context,
              showDragHandle: true,
              builder: (_) => const TargetAreaSheet(),
            );
            if (!mounted || area == null) return;
            setState(() {
              country.text = area.country;
              city.text = area.city;
              neighbourhood.text = area.neighbourhood;
              error = null;
            });
          },
          icon: const Icon(Icons.place_outlined),
          label: const Text(PublishingCopy.chooseSampleArea),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: country,
          decoration: InputDecoration(
            labelText: PublishingCopy.country,
            errorText: error,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: city,
          decoration: const InputDecoration(
            labelText: PublishingCopy.cityOptional,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: neighbourhood,
          decoration: const InputDecoration(
            labelText: PublishingCopy.neighbourhoodOptional,
          ),
        ),
        const SizedBox(height: 16),
        Text(PublishingCopy.radius(radius.round())),
        Slider(
          value: radius,
          min: 1,
          max: 100,
          divisions: 99,
          label: PublishingCopy.kilometres(radius.round()),
          onChanged: (value) => setState(() => radius = value),
        ),
        FilledButton(
          onPressed: save,
          child: const Text(PublishingCopy.saveArea),
        ),
      ],
    ),
  );
}
