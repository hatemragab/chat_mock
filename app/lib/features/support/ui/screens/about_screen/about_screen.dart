import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/support_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../onboarding/ui/screens/legal_screen/legal_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(SupportCopy.aboutWhizpee)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 32),
        Center(
          child: Icon(
            Icons.forum_rounded,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            SupportCopy.whizpee,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const Center(child: Text(SupportCopy.prototypeVersion10)),
        const SizedBox(height: 32),
        ListTile(
          title: const Text(SupportCopy.termsOfService),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const LegalScreen(document: LegalDocument.terms),
            ),
          ),
        ),
        ListTile(
          title: const Text(SupportCopy.privacyPolicy),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  const LegalScreen(document: LegalDocument.privacy),
            ),
          ),
        ),
      ],
    ),
  );
}
