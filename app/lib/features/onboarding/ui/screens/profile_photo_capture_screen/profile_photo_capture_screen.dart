import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

class ProfilePhotoCaptureScreen extends StatefulWidget {
  const ProfilePhotoCaptureScreen({super.key});

  @override
  State<ProfilePhotoCaptureScreen> createState() =>
      _ProfilePhotoCaptureScreenState();
}

class _ProfilePhotoCaptureScreenState extends State<ProfilePhotoCaptureScreen> {
  bool front = true;
  bool captured = false;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(OnboardingCopy.capturePhoto)),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    captured
                        ? Icons.check_circle_outline
                        : Icons.camera_alt_outlined,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    captured
                        ? OnboardingCopy.sampleCaptured
                        : OnboardingCopy.cameraPreview(front),
                  ),
                  const Text(OnboardingCopy.cameraSimulation),
                ],
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              IconButton(
                onPressed: () => setState(() => front = !front),
                tooltip: OnboardingCopy.switchCamera,
                icon: const Icon(Icons.cameraswitch_outlined),
              ),
              FilledButton.icon(
                onPressed: () => setState(() => captured = !captured),
                icon: Icon(captured ? Icons.replay : Icons.camera_alt),
                label: Text(
                  captured ? OnboardingCopy.retake : OnboardingCopy.capture,
                ),
              ),
              IconButton(
                onPressed: captured
                    ? () => Navigator.pop(
                        context,
                        front
                            ? OnboardingCopy.frontCameraPhoto
                            : OnboardingCopy.cameraPhoto,
                      )
                    : null,
                tooltip: OnboardingCopy.usePhoto,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
