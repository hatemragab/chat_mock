import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/publishing_copy.dart';

class TargetArea {
  const TargetArea({
    required this.country,
    required this.city,
    required this.neighbourhood,
  });
  final String country;
  final String city;
  final String neighbourhood;
}

/// Offline sample areas; the caller can still enter another area manually.
class TargetAreaSheet extends StatelessWidget {
  const TargetAreaSheet({super.key});
  static const areas = [
    TargetArea(country: 'Cameroon', city: 'Douala', neighbourhood: 'Akwa'),
    TargetArea(country: 'Cameroon', city: 'Yaoundé', neighbourhood: 'Bastos'),
    TargetArea(country: 'Egypt', city: 'Cairo', neighbourhood: 'Zamalek'),
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            PublishingCopy.chooseAnArea,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(PublishingCopy.chooseASampleAreaOrEnterAnother),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final area in areas)
                  ListTile(
                    title: Text(area.neighbourhood),
                    subtitle: Text(
                      PublishingCopy.locationPair(area.city, area.country),
                    ),
                    onTap: () => Navigator.pop(context, area),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(CommonCopy.cancel),
          ),
        ],
      ),
    ),
  );
}
