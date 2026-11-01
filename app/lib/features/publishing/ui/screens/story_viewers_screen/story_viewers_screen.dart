import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/publishing_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/publishing_controller.dart';
import '../../../models/publication.dart';
import '../analytics_screen/analytics_screen.dart';

class StoryViewersScreen extends StatelessWidget {
  const StoryViewersScreen({
    super.key,
    required this.controller,
    required this.publication,
  });
  final PublishingController controller;
  final Publication publication;

  @override
  Widget build(BuildContext context) {
    if (publication.boosted ||
        publication.type == PublicationType.advertisement) {
      return AnalyticsScreen(controller: controller, publication: publication);
    }
    return AppScaffold(
      appBar: AppHeader(title: const Text(PublishingCopy.storyViewers)),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final viewers = publication.contactViewers.values.toList()
            ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
          if (viewers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(PublishingCopy.noContactViewsYet),
              ),
            );
          }
          return ListView.builder(
            itemCount: viewers.length,
            itemBuilder: (context, index) {
              final viewer = viewers[index];
              final time = viewer.viewedAt;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    viewer.name.isEmpty ? '?' : viewer.name.substring(0, 1),
                  ),
                ),
                title: Text(viewer.name),
                subtitle: Text(PublishingCopy.viewerTimestamp(time)),
              );
            },
          );
        },
      ),
    );
  }
}
