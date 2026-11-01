import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../groups/ui/dialogs/discard_changes_dialog/discard_changes_dialog.dart';
import '../../../controllers/onboarding_controller.dart';
import '../../../models/phone_number.dart';
import '../../widgets/phone_field.dart';
import '../../sheets/photo_source_sheet/photo_source_sheet.dart';
import '../../sheets/profile_photo_library_sheet/profile_photo_library_sheet.dart';
import '../interests_screen/interests_screen.dart';
import '../legal_screen/legal_screen.dart';
import '../profile_photo_capture_screen/profile_photo_capture_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    required this.controller,
    required this.onComplete,
    this.initiallyShowValidation = false,
    this.initiallyShowCountryPicker = false,
    this.initialDraftName,
    this.initiallyPromptDiscard = false,
  });

  final OnboardingController controller;
  final VoidCallback onComplete;
  final bool initiallyShowValidation;
  final bool initiallyShowCountryPicker;
  final String? initialDraftName;
  final bool initiallyPromptDiscard;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.controller.name,
  );
  late bool _submitted = widget.initiallyShowValidation;
  late String _originalName;
  late PhoneNumber _originalPhone;
  late String _originalGender;
  late bool _originalTerms;
  late bool _originalPhotoSelected;
  late String? _originalPhotoLabel;
  bool _allowPop = false;
  bool _confirmingDiscard = false;

  bool get _dirty =>
      _name.text != _originalName ||
      widget.controller.phone.international != _originalPhone.international ||
      widget.controller.phone.unsupportedPrefix !=
          _originalPhone.unsupportedPrefix ||
      widget.controller.gender != _originalGender ||
      widget.controller.termsAccepted != _originalTerms ||
      widget.controller.photoSelected != _originalPhotoSelected ||
      widget.controller.photoLabel != _originalPhotoLabel;

  @override
  void initState() {
    super.initState();
    _originalName = widget.controller.name;
    _originalPhone = widget.controller.phone;
    _originalGender = widget.controller.gender;
    _originalTerms = widget.controller.termsAccepted;
    _originalPhotoSelected = widget.controller.photoSelected;
    _originalPhotoLabel = widget.controller.photoLabel;
    _name.addListener(_draftChanged);
    widget.controller.addListener(_draftChanged);
    if (widget.initialDraftName case final name?) {
      _name.text = name;
      widget.controller.name = name;
    }
    if (widget.initiallyPromptDiscard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _discard();
      });
    }
  }

  void _draftChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _discard() async {
    if (!_dirty || _confirmingDiscard) return;
    _confirmingDiscard = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => const DiscardChangesDialog(
        description: OnboardingCopy.yourProfileChangesHaveNotBeenSaved,
      ),
    );
    _confirmingDiscard = false;
    if (!mounted || discard != true) return;
    widget.controller.restoreProfile(
      name: _originalName,
      phone: _originalPhone,
      gender: _originalGender,
      termsAccepted: _originalTerms,
      photoSelected: _originalPhotoSelected,
      photoLabel: _originalPhotoLabel,
    );
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _choosePhoto() async {
    final action = await showModalBottomSheet<PhotoSourceAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PhotoSourceSheet(
        hasPhoto: widget.controller.photoSelected,
        label: OnboardingCopy.profilePhoto,
      ),
    );
    if (!mounted || action == null) return;
    if (action == PhotoSourceAction.remove) {
      setState(() => widget.controller.setPhoto(null));
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
      setState(() => widget.controller.setPhoto(photo));
    }
  }

  @override
  void dispose() {
    _name.removeListener(_draftChanged);
    widget.controller.removeListener(_draftChanged);
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty ||
        widget.controller.phone.validationError != null ||
        !widget.controller.termsAccepted) {
      return;
    }
    widget.controller.name = _name.text.trim();
    _name.text = widget.controller.name;
    setState(() {
      _originalName = widget.controller.name;
      _originalPhone = widget.controller.phone;
      _originalGender = widget.controller.gender;
      _originalTerms = widget.controller.termsAccepted;
      _originalPhotoSelected = widget.controller.photoSelected;
      _originalPhotoLabel = widget.controller.photoLabel;
    });
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InterestsScreen(
          controller: widget.controller,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_dirty || _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discard();
      },
      child: AppScaffold(
        appBar: AppHeader(title: const Text(OnboardingCopy.completeProfile)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: color.primaryContainer,
                      child: Icon(
                        widget.controller.photoSelected
                            ? Icons.person
                            : Icons.person_outline,
                        size: 52,
                        color: color.onPrimaryContainer,
                      ),
                    ),
                    Material(
                      color: color.primary,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: OnboardingCopy.chooseProfilePhoto,
                        onPressed: _choosePhoto,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: color.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.controller.photoSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.controller.photoLabel ??
                        OnboardingCopy.profilePhotoAdded,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              const Text(OnboardingCopy.yourName),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('profile_name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) => widget.controller.name = value,
                decoration: InputDecoration(
                  hintText: OnboardingCopy.enterYourName,
                  border: const OutlineInputBorder(),
                  errorText: _submitted && _name.text.trim().isEmpty
                      ? OnboardingCopy.requiredNameError
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              PhoneField(
                controller: widget.controller,
                showError: _submitted,
                initiallyOpenCountryPicker: widget.initiallyShowCountryPicker,
              ),
              const SizedBox(height: 16),
              const Text(OnboardingCopy.gender),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: widget.controller.gender,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items:
                    const [
                          OnboardingCopy.preferNotToSay,
                          OnboardingCopy.woman,
                          OnboardingCopy.man,
                          OnboardingCopy.anotherIdentity,
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(
                  () => widget.controller.gender =
                      value ?? widget.controller.gender,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.controller.termsAccepted,
                onChanged: (value) => setState(
                  () => widget.controller.termsAccepted = value ?? false,
                ),
                title: const Text(OnboardingCopy.termsConsent),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_submitted && !widget.controller.termsAccepted)
                Text(
                  OnboardingCopy.pleaseAcceptTheTermsToContinue,
                  style: TextStyle(color: color.error),
                ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const LegalScreen(document: LegalDocument.terms),
                      ),
                    ),
                    child: const Text(OnboardingCopy.termsOfService),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const LegalScreen(document: LegalDocument.privacy),
                      ),
                    ),
                    child: const Text(OnboardingCopy.privacyPolicy),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _continue,
                child: const Text(CommonCopy.continueLabel),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
