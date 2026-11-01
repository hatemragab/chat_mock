import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../controllers/onboarding_controller.dart';
import '../complete_profile_screen/complete_profile_screen.dart';
import '../legal_screen/legal_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.controller,
    required this.onComplete,
    this.initiallyStartSignIn = false,
  });

  final OnboardingController controller;
  final VoidCallback onComplete;
  final bool initiallyStartSignIn;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _signInTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initiallyStartSignIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _signIn();
      });
    }
  }

  @override
  void dispose() {
    _signInTimer?.cancel();
    super.dispose();
  }

  void _signIn() {
    _signInTimer?.cancel();
    widget.controller.setSignInState(SignInState.loading);
    _signInTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted || widget.controller.signInState != SignInState.loading) {
        return;
      }
      widget.controller.setSignInState(SignInState.idle);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CompleteProfileScreen(
            controller: widget.controller,
            onComplete: widget.onComplete,
          ),
        ),
      );
    });
  }

  void _openLegal(LegalDocument document) {
    if (widget.controller.signInState == SignInState.loading) {
      _signInTimer?.cancel();
      widget.controller.setSignInState(SignInState.cancelled);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegalScreen(document: document)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final state = widget.controller.signInState;
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 48).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.bubble_chart_rounded,
                        size: 84,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        OnboardingCopy.whizpee,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        OnboardingCopy.welcomeTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 48),
                      if (state == SignInState.loading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        const Text(
                          OnboardingCopy.signingIn,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            _signInTimer?.cancel();
                            widget.controller.setSignInState(
                              SignInState.cancelled,
                            );
                          },
                          child: const Text(CommonCopy.cancel),
                        ),
                      ] else ...[
                        if (state == SignInState.cancelled ||
                            state == SignInState.failed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state == SignInState.cancelled
                                  ? OnboardingCopy.signInCancelledYouCanTryAgain
                                  : OnboardingCopy.signInFailedPleaseTryAgain,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        FilledButton.icon(
                          onPressed: _signIn,
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text(OnboardingCopy.continueWithGoogle),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _signIn,
                          icon: const Icon(Icons.apple),
                          label: const Text(OnboardingCopy.continueWithApple),
                        ),
                      ],
                      const SizedBox(height: 28),
                      const Text(
                        OnboardingCopy.byContinuingYouAgreeToOur,
                        textAlign: TextAlign.center,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _openLegal(LegalDocument.terms),
                            child: const Text(OnboardingCopy.termsOfService),
                          ),
                          TextButton(
                            onPressed: () => _openLegal(LegalDocument.privacy),
                            child: const Text(OnboardingCopy.privacyPolicy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
