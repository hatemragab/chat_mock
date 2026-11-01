import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../stories/models/story.dart';
import '../../../../wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import '../../../controllers/business_controller.dart';
import '../../../copy/business_copy.dart';

typedef BusinessCallCallback = void Function(Story story, bool video);

class BusinessCallPreflightSheet extends StatelessWidget {
  const BusinessCallPreflightSheet({
    super.key,
    required this.controller,
    required this.story,
    required this.video,
    required this.onCall,
  });
  final BusinessController controller;
  final Story story;
  final bool video;
  final BusinessCallCallback onCall;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([controller, controller.wallet]),
    builder: (context, _) {
      final rate = video
          ? controller.config.videoBlockCredits
          : controller.config.audioBlockCredits;
      final blocks = controller.wallet.credits ~/ rate;
      final blocked = controller.isBlocked(story);
      final eligible = controller.sourceEligible(story);
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                BusinessCopy.callWith(video, story.author),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(BusinessCopy.callRate(rate)),
              const SizedBox(height: 8),
              Text(BusinessCopy.callBalance(controller.wallet.credits, blocks)),
              const SizedBox(height: 20),
              if (blocked || !eligible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    blocked
                        ? BusinessCopy.unblockBeforeCalling
                        : BusinessCopy.originatingStoryUnavailable,
                  ),
                ),
              if (blocks == 0 && eligible && !blocked)
                OutlinedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => InsufficientCreditsSheet(
                      controller: controller.wallet,
                      requiredCredits: rate,
                    ),
                  ),
                  child: const Text(BusinessCopy.buyCredits),
                ),
              FilledButton(
                onPressed: blocks == 0 || blocked || !eligible
                    ? null
                    : () {
                        if (controller.isBlocked(story) ||
                            !controller.sourceEligible(story)) {
                          Navigator.pop(context);
                          return;
                        }
                        Navigator.pop(context);
                        onCall(story, video);
                      },
                child: const Text(BusinessCopy.startCall),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(CommonCopy.cancel),
              ),
            ],
          ),
        ),
      );
    },
  );
}
