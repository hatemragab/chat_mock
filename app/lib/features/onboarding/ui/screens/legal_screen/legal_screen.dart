import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

enum LegalDocument { terms, privacy }

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final isTerms = document == LegalDocument.terms;
    return AppScaffold(
      appBar: AppHeader(
        title: Text(
          isTerms
              ? OnboardingCopy.termsOfService
              : OnboardingCopy.privacyPolicy,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isTerms ? OnboardingCopy.usingWhizpee : OnboardingCopy.yourPrivacy,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            isTerms
                ? OnboardingCopy.termsIntroduction
                : OnboardingCopy.privacyIntroduction,
          ),
          const SizedBox(height: 20),
          Text(
            isTerms
                ? OnboardingCopy.aSafeCommunity
                : OnboardingCopy.yourChoices,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isTerms
                ? OnboardingCopy.communityGuidelines
                : OnboardingCopy.privacyChoices,
          ),
          const SizedBox(height: 24),
          const Text(OnboardingCopy.legalPrototypeNotice),
        ],
      ),
    );
  }
}
