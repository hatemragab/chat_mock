import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'app_scaffold.dart';

/// Shared chat chrome and bounded thread used by every conversation context.
/// Feature screens retain identity, permissions, drafts and message actions.
class ConversationLayout extends StatelessWidget {
  const ConversationLayout({
    super.key,
    required this.header,
    required this.messageCount,
    required this.messageBuilder,
    required this.composer,
    this.contextBanner,
    this.composerNotice,
    this.emptyState,
    this.scrollController,
    this.buildAllMessages = false,
  });

  final PreferredSizeWidget header;
  final int messageCount;
  final IndexedWidgetBuilder messageBuilder;
  final Widget composer;
  final Widget? contextBanner;
  final Widget? composerNotice;
  final Widget? emptyState;
  final ScrollController? scrollController;

  /// Jump-to-message routes build targets before their post-frame scroll.
  final bool buildAllMessages;

  Widget _messages(BuildContext context) {
    if (messageCount == 0 && emptyState != null) return emptyState!;
    const padding = EdgeInsets.symmetric(vertical: AppSpacing.medium);
    if (buildAllMessages) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: padding,
        child: Column(
          children: [
            for (var index = 0; index < messageCount; index++)
              messageBuilder(context, index),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: messageCount,
      itemBuilder: messageBuilder,
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkConversation
        : AppColors.lightConversation,
    appBar: header,
    body: Column(
      children: [
        ?contextBanner,
        Expanded(child: _messages(context)),
        ?composerNotice,
        composer,
      ],
    ),
  );
}
