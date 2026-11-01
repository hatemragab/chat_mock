import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_form_field.dart';

import '../../../copy/profile_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../onboarding/controllers/onboarding_controller.dart';
import '../../../../onboarding/models/phone_number.dart';
import '../../../../onboarding/ui/screens/profile_photo_capture_screen/profile_photo_capture_screen.dart';
import '../../../../onboarding/ui/sheets/photo_source_sheet/photo_source_sheet.dart';
import '../../../../onboarding/ui/sheets/profile_photo_library_sheet/profile_photo_library_sheet.dart';
import '../../../../onboarding/ui/widgets/phone_field.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.settings,
    required this.onSaved,
  });
  final OnboardingController profile;
  final SettingsController settings;
  final VoidCallback onSaved;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final OnboardingController draft;
  late final TextEditingController name;
  late final TextEditingController about;
  bool submitted = false;
  bool dirty = false;
  bool allowPop = false;
  static const interests = [
    ProfileCopy.art,
    ProfileCopy.design,
    ProfileCopy.food,
    ProfileCopy.music,
    ProfileCopy.travel,
    ProfileCopy.sports,
    ProfileCopy.technology,
    ProfileCopy.fashion,
  ];

  @override
  void initState() {
    super.initState();
    draft = OnboardingController()
      ..name = widget.profile.name.isEmpty ? 'Alex Morgan' : widget.profile.name
      ..gender = widget.profile.gender
      ..phone = widget.profile.phone.local.isEmpty
          ? const PhoneNumber(
              country: PhoneCountry(ProfileCopy.cameroon, '+237'),
              local: '670000000',
            )
          : widget.profile.phone
      ..photoSelected = widget.profile.photoSelected;
    draft.photoLabel = widget.profile.photoLabel;
    draft.interests.addAll(widget.profile.interests);
    name = TextEditingController(text: draft.name);
    about = TextEditingController(text: widget.settings.about);
    draft.addListener(_markDirty);
  }

  void _markDirty() {
    if (!dirty && mounted) setState(() => dirty = true);
  }

  Future<void> _choosePhoto() async {
    final action = await showModalBottomSheet<PhotoSourceAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PhotoSourceSheet(
        hasPhoto: draft.photoSelected,
        label: ProfileCopy.profilePhoto,
      ),
    );
    if (!mounted || action == null) return;
    if (action == PhotoSourceAction.remove) {
      draft.setPhoto(null);
      setState(() {});
      return;
    }
    final String? photo;
    if (action == PhotoSourceAction.camera) {
      photo = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePhotoCaptureScreen()),
      );
    } else {
      photo = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const ProfilePhotoLibrarySheet(),
      );
    }
    if (mounted && photo != null) {
      draft.setPhoto(photo);
      setState(() {});
    }
  }

  @override
  void dispose() {
    draft.removeListener(_markDirty);
    draft.dispose();
    name.dispose();
    about.dispose();
    super.dispose();
  }

  Future<void> _discard() async {
    if (!dirty) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(ProfileCopy.discardChangesTitle),
        content: const Text(ProfileCopy.unsavedProfileDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(ProfileCopy.keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(ProfileCopy.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => allowPop = true);
      Navigator.pop(context);
    }
  }

  void _save() {
    setState(() => submitted = true);
    if (name.text.trim().isEmpty || draft.phone.validationError != null) return;
    widget.profile.name = name.text.trim();
    widget.profile.phone = draft.phone;
    widget.profile.gender = draft.gender;
    widget.profile.setPhoto(
      draft.photoSelected
          ? (draft.photoLabel ?? ProfileCopy.profilePhotoLabel)
          : null,
    );
    widget.profile.interests
      ..clear()
      ..addAll(draft.interests);
    widget.settings.setAbout(about.text);
    widget.onSaved();
    setState(() => allowPop = true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !dirty || allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discard();
      },
      child: AppScaffold(
        appBar: AppHeader(title: const Text(ProfileCopy.editProfile)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ProfileAvatar(
                    name: name.text,
                    photoLabel: draft.photoSelected
                        ? (draft.photoLabel ?? ProfileCopy.profilePhotoLabel)
                        : null,
                    radius: 48,
                  ),
                  Material(
                    color: color.primary,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: ProfileCopy.changeProfilePhoto,
                      onPressed: _choosePhoto,
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: color.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (draft.photoSelected) ...[
              const SizedBox(height: 8),
              Text(
                draft.photoLabel ?? ProfileCopy.profilePhotoLabel,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            AppFormField(
              controller: name,
              onChanged: (_) => setState(() => dirty = true),
              textCapitalization: TextCapitalization.words,
              label: ProfileCopy.name,
              error: submitted && name.text.trim().isEmpty
                  ? ProfileCopy.enterYourName
                  : null,
            ),
            const SizedBox(height: 16),
            AppFormField(
              controller: about,
              onChanged: (_) => _markDirty(),
              maxLength: 140,
              label: ProfileCopy.about,
            ),
            const SizedBox(height: 8),
            PhoneField(controller: draft, showError: submitted),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: draft.gender,
              decoration: const InputDecoration(labelText: ProfileCopy.gender),
              items:
                  [
                        ProfileCopy.preferNotToSay,
                        ProfileCopy.woman,
                        ProfileCopy.man,
                        ProfileCopy.anotherIdentity,
                      ]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() {
                draft.gender = value ?? draft.gender;
                dirty = true;
              }),
            ),
            const SizedBox(height: 16),
            Text(
              ProfileCopy.interests,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: interests
                  .map(
                    (interest) => FilterChip(
                      label: Text(interest),
                      selected: draft.interests.contains(interest),
                      onSelected: (_) =>
                          setState(() => draft.toggleInterest(interest)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text(CommonCopy.save)),
          ],
        ),
      ),
    );
  }
}
