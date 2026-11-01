import '../../../../../shared/widgets/app_scaffold.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

class HelpArticleScreen extends StatelessWidget {
  const HelpArticleScreen({
    super.key,
    required this.title,
    required this.content,
  });
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Text(content),
      ],
    ),
  );
}
