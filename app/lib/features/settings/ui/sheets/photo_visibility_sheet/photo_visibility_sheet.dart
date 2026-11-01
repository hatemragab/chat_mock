import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../models/settings_models.dart';

class PhotoVisibilitySheet extends StatefulWidget {
  const PhotoVisibilitySheet({super.key, required this.initial});
  final PhotoVisibility initial;
  @override
  State<PhotoVisibilitySheet> createState() => _PhotoVisibilitySheetState();
}

class _PhotoVisibilitySheetState extends State<PhotoVisibilitySheet> {
  late PhotoVisibility selection = widget.initial;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SettingsCopy.profilePhotoVisibility,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            RadioGroup<PhotoVisibility>(
              groupValue: selection,
              onChanged: (value) {
                if (value != null) setState(() => selection = value);
              },
              child: Column(
                children: [
                  for (final option in PhotoVisibility.values)
                    RadioListTile<PhotoVisibility>(
                      value: option,
                      title: Text(switch (option) {
                        PhotoVisibility.everyone => SettingsCopy.everyone,
                        PhotoVisibility.contacts => SettingsCopy.myContacts,
                        PhotoVisibility.nobody => SettingsCopy.nobody,
                      }),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(CommonCopy.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, selection),
                    child: const Text(CommonCopy.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
