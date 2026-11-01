import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_section_heading.dart';

import '../../../copy/settings_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import 'widgets/appearance_preview.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({
    super.key,
    required this.mode,
    required this.onChanged,
    this.textScaleFactor = 1.0,
    this.onTextScaleChanged,
  });
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  final double textScaleFactor;
  final ValueChanged<double>? onTextScaleChanged;

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late ThemeMode mode = widget.mode;
  late double textScaleFactor = widget.textScaleFactor
      .clamp(.9, 1.3)
      .toDouble();

  @override
  void didUpdateWidget(covariant AppearanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) mode = widget.mode;
    if (oldWidget.textScaleFactor != widget.textScaleFactor) {
      textScaleFactor = widget.textScaleFactor.clamp(.9, 1.3).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppHeader(title: const Text(SettingsCopy.appearance)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppSectionHeading(
            title: SettingsCopy.chooseYourTheme,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(SettingsCopy.selectHowWhizpeeLooksOnThisDevice),
          const SizedBox(height: 16),
          AppearancePreview(
            textScaleFactor: textScaleFactor,
            inheritsAppTextScale: widget.onTextScaleChanged != null,
          ),
          const SizedBox(height: 12),
          RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) {
                setState(() => mode = value);
                widget.onChanged(value);
              }
            },
            child: Column(
              children: [
                for (final option in [
                  (
                    ThemeMode.light,
                    SettingsCopy.light,
                    Icons.light_mode_outlined,
                  ),
                  (ThemeMode.dark, SettingsCopy.dark, Icons.dark_mode_outlined),
                  (
                    ThemeMode.system,
                    SettingsCopy.system,
                    Icons.settings_suggest_outlined,
                  ),
                ])
                  RadioListTile<ThemeMode>(
                    value: option.$1,
                    title: Text(option.$2),
                    secondary: Icon(option.$3),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppSectionHeading(title: SettingsCopy.textSize),
          const SizedBox(height: 4),
          const Text(SettingsCopy.textScaleDescription),
          Semantics(
            label: SettingsCopy.textSize,
            value: SettingsCopy.textScalePercent(
              (textScaleFactor * 100).round(),
            ),
            child: Slider(
              value: textScaleFactor,
              min: .9,
              max: 1.3,
              divisions: 4,
              label: SettingsCopy.textScaleValue(
                (textScaleFactor * 100).round(),
              ),
              onChanged: (value) {
                setState(() => textScaleFactor = value);
                widget.onTextScaleChanged?.call(value);
              },
            ),
          ),
          Text(
            SettingsCopy.textScaleValue((textScaleFactor * 100).round()),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
