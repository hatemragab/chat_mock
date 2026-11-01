import 'package:flutter/material.dart';

import '../../../../copy/publishing_copy.dart';

/// Seven-day aggregate of qualified views; viewer identities are never shown.
class QualifiedViewsChart extends StatelessWidget {
  const QualifiedViewsChart({
    super.key,
    required this.now,
    required this.viewsByDay,
  });

  final DateTime now;
  final Map<String, int> viewsByDay;

  String _key(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (index) {
      // Calendar construction avoids subtracting 24-hour durations over a
      // daylight-saving transition.
      return DateTime(now.year, now.month, now.day - (6 - index));
    });
    final values = [for (final day in days) viewsByDay[_key(day)] ?? 0];
    final highest = values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final color = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < days.length; i++)
            Semantics(
              label: PublishingCopy.chartViewLabel(days[i], values[i]),
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${values[i]}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 80,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 24,
                            height: highest == 0
                                ? 2
                                : (values[i] / highest * 78).clamp(2, 78),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PublishingCopy.chartDay(days[i]),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
