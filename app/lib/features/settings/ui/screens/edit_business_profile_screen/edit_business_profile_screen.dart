import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_form_field.dart';

import '../../../copy/settings_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/settings_controller.dart';
import '../../../models/settings_models.dart';
import '../../../../groups/ui/dialogs/discard_changes_dialog/discard_changes_dialog.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key, required this.controller});
  final SettingsController controller;

  @override
  State<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController location;
  late String category;
  late bool logoSelected;
  late bool coverSelected;
  bool submitted = false;
  late final BusinessProfile original;
  bool allowPop = false;
  bool confirmingDiscard = false;

  bool get dirty =>
      name.text != original.name ||
      description.text != original.description ||
      location.text != original.location ||
      category != original.category ||
      logoSelected != original.logoSelected ||
      coverSelected != original.coverSelected;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.businessProfile;
    original = profile;
    name = TextEditingController(text: profile.name);
    description = TextEditingController(text: profile.description);
    location = TextEditingController(text: profile.location);
    category = profile.category;
    logoSelected = profile.logoSelected;
    coverSelected = profile.coverSelected;
    name.addListener(_draftChanged);
    description.addListener(_draftChanged);
    location.addListener(_draftChanged);
  }

  void _draftChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _discard() async {
    if (!dirty || confirmingDiscard) return;
    confirmingDiscard = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => const DiscardChangesDialog(
        description: SettingsCopy.unsavedBusinessDescription,
      ),
    );
    confirmingDiscard = false;
    if (!mounted || discard != true) return;
    setState(() => allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    name.removeListener(_draftChanged);
    description.removeListener(_draftChanged);
    location.removeListener(_draftChanged);
    name.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  Future<void> _chooseImage({required bool logo}) async {
    final selection = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(SettingsCopy.chooseDemoImage),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text(SettingsCopy.removeImage),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      if (logo) {
        logoSelected = selection;
      } else {
        coverSelected = selection;
      }
    });
  }

  void _save() {
    setState(() => submitted = true);
    final profile = BusinessProfile(
      name: name.text.trim(),
      category: category,
      description: description.text.trim(),
      location: location.text.trim(),
      logoSelected: logoSelected,
      coverSelected: coverSelected,
    );
    if (widget.controller.saveBusinessProfile(profile)) {
      setState(() => allowPop = true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !dirty || allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discard();
      },
      child: AppScaffold(
        appBar: AppHeader(title: const Text(SettingsCopy.editBusinessProfile)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              SettingsCopy.businessIdentityDescription,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () => _chooseImage(logo: false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                key: const ValueKey('business-cover-preview'),
                height: 110,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  image: coverSelected
                      ? const DecorationImage(
                          image: AssetImage(BusinessProfile.demoCoverAssetPath),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      coverSelected
                          ? SettingsCopy.demoCoverSelectedChange
                          : SettingsCopy.addACoverImage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _chooseImage(logo: true),
                icon: logoSelected
                    ? const CircleAvatar(
                        key: ValueKey('business-logo-preview'),
                        radius: 16,
                        backgroundImage: AssetImage(
                          BusinessProfile.demoLogoAssetPath,
                        ),
                      )
                    : const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  logoSelected
                      ? SettingsCopy.demoLogoSelectedChange
                      : SettingsCopy.addALogo,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: name,
              maxLength: 80,
              label: SettingsCopy.publicBusinessName,
              error: submitted && name.text.trim().isEmpty
                  ? SettingsCopy.enterABusinessName
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category.isEmpty ? null : category,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: SettingsCopy.category,
                errorText: submitted && category.isEmpty
                    ? SettingsCopy.chooseACategory
                    : null,
              ),
              items: const [
                DropdownMenuItem(
                  value: SettingsCopy.design,
                  child: Text(SettingsCopy.design),
                ),
                DropdownMenuItem(
                  value: SettingsCopy.foodDrink,
                  child: Text(SettingsCopy.foodDrink),
                ),
                DropdownMenuItem(
                  value: SettingsCopy.shopping,
                  child: Text(SettingsCopy.shopping),
                ),
                DropdownMenuItem(
                  value: SettingsCopy.lifestyle,
                  child: Text(SettingsCopy.lifestyle),
                ),
                DropdownMenuItem(
                  value: SettingsCopy.other,
                  child: Text(SettingsCopy.other),
                ),
              ],
              onChanged: (value) => setState(() => category = value ?? ''),
            ),
            const SizedBox(height: 16),
            AppFormField(
              controller: description,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              label: SettingsCopy.description,
              error: submitted && description.text.trim().isEmpty
                  ? SettingsCopy.enterADescription
                  : null,
            ),
            const SizedBox(height: 12),
            AppFormField(
              controller: location,
              maxLength: 120,
              label: SettingsCopy.publicLocationOptional,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text(CommonCopy.save)),
          ],
        ),
      ),
    );
  }
}
