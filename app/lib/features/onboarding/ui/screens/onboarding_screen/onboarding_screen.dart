import 'package:flutter/material.dart';

import '../../../controllers/onboarding_controller.dart';
import '../welcome_screen/welcome_screen.dart';

/// An isolated flow that can be embedded in the app or opened as a route.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.controller,
  });

  final VoidCallback onComplete;
  final OnboardingController? controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController controller =
      widget.controller ?? OnboardingController();

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) =>
          WelcomeScreen(controller: controller, onComplete: widget.onComplete),
    ),
  );
}
