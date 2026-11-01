import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/onboarding_controller.dart';
import '../contacts_access_screen/contacts_access_screen.dart';

enum InterestSelectionMode { onboarding, edit, advertisement }

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({
    super.key,
    required this.controller,
    required this.onComplete,
    this.mode = InterestSelectionMode.onboarding,
    this.onSelected,
    this.initialTarget,
    this.initiallyShowValidation = false,
  });

  final OnboardingController controller;
  final VoidCallback onComplete;
  final InterestSelectionMode mode;
  final ValueChanged<Set<String>>? onSelected;
  final String? initialTarget;
  final bool initiallyShowValidation;

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  static const options = [
    OnboardingCopy.art,
    OnboardingCopy.beauty,
    OnboardingCopy.business,
    OnboardingCopy.design,
    OnboardingCopy.fashion,
    OnboardingCopy.food,
    OnboardingCopy.gaming,
    OnboardingCopy.health,
    OnboardingCopy.music,
    OnboardingCopy.photography,
    OnboardingCopy.sports,
    OnboardingCopy.technology,
    OnboardingCopy.travel,
  ];
  late final Set<String> _selected =
      widget.mode == InterestSelectionMode.advertisement
      ? {if (widget.initialTarget != null) widget.initialTarget!}
      : {...widget.controller.interests};
  late bool _submitted = widget.initiallyShowValidation;

  void _continue() {
    setState(() => _submitted = true);
    final minimum = widget.mode == InterestSelectionMode.advertisement ? 1 : 3;
    if (_selected.length < minimum) return;
    if (widget.mode != InterestSelectionMode.advertisement) {
      widget.controller.interests
        ..clear()
        ..addAll(_selected);
    }
    widget.onSelected?.call(Set.unmodifiable(_selected));
    if (widget.mode == InterestSelectionMode.onboarding) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContactsAccessScreen(
            controller: widget.controller,
            onComplete: widget.onComplete,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final single = widget.mode == InterestSelectionMode.advertisement;
    return AppScaffold(
      appBar: AppHeader(
        title: Text(
          single
              ? OnboardingCopy.chooseAnInterest
              : OnboardingCopy.yourInterests,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    single
                        ? OnboardingCopy.chooseOneInterestForYourAudience
                        : OnboardingCopy.onboardingInterestsDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options
                        .map(
                          (interest) => FilterChip(
                            label: Text(interest),
                            selected: _selected.contains(interest),
                            onSelected: (selected) => setState(() {
                              if (single) _selected.clear();
                              if (selected) {
                                _selected.add(interest);
                              } else {
                                _selected.remove(interest);
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  if (_submitted && _selected.length < (single ? 1 : 3))
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        single
                            ? OnboardingCopy.selectOneInterest
                            : OnboardingCopy.selectAtLeastThreeInterests,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(
                    widget.mode == InterestSelectionMode.onboarding
                        ? CommonCopy.continueLabel
                        : CommonCopy.save,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
