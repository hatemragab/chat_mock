import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';
import '../../dialogs/low_call_balance_dialog/low_call_balance_dialog.dart';
import '../../sheets/audio_output_sheet/audio_output_sheet.dart';
import '../../widgets/business_call_story_cover.dart';
import '../../widgets/call_video_preview.dart';
import '../call_summary_screen/call_summary_screen.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key, required this.controller, required this.call});
  final CallsController controller;
  final CallSession call;

  void _summary(BuildContext context) => Navigator.pushReplacement(
    context,
    MaterialPageRoute<void>(
      builder: (_) => CallSummaryScreen(controller: controller, call: call),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && controller.active == call) controller.setMinimized(true);
      },
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final active = controller.active == call;
          final story = call.business ? call.story : null;
          final identityName = story?.author ?? call.name;
          final connected =
              call.phase == CallPhase.active ||
              call.phase == CallPhase.reconnecting;
          final status = switch (call.phase) {
            CallPhase.ringing => CallsCopy.ringing,
            CallPhase.incoming => CallsCopy.incomingKind(call.kind.label),
            CallPhase.active => CallsCopy.elapsed(call.seconds),
            CallPhase.reconnecting => CallsCopy.reconnecting(
              CallsCopy.elapsed(call.seconds),
            ),
            CallPhase.permissionBlocked => CallsCopy.permissionRequired,
            _ => call.phase.label,
          };
          return AppScaffold(
            safeArea: false,
            backgroundColor: const Color(0xFF122A27),
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (active) controller.setMinimized(true);
                          Navigator.pop(context);
                        },
                        tooltip: active
                            ? CallsCopy.minimizeCall
                            : CommonCopy.close,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (call.business)
                        const Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Text(
                            CallsCopy.businessCallBanner,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (controller.lowBalance)
                    Material(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: ListTile(
                        dense: true,
                        textColor: Theme.of(context)
                            .colorScheme
                            .onTertiaryContainer,
                        iconColor: Theme.of(context)
                            .colorScheme
                            .onTertiaryContainer,
                        leading: const Icon(Icons.warning_amber),
                        title: const Text(CallsCopy.creditsRunningLow),
                        subtitle: const Text(CallsCopy.lowBalanceExplanation),
                        trailing: IconButton(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer,
                          tooltip: CallsCopy.lowBalanceDetails,
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => LowCallBalanceDialog(
                              controller: controller,
                              call: call,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height * .35,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (call.kind == CallKind.video &&
                                  (connected ||
                                      call.phase == CallPhase.incoming))
                                CallVideoPreview(call: call)
                              else if (story != null)
                                BusinessCallStoryCover(story: story)
                              else
                                AppAvatar(
                                  name: call.name,
                                  radius: 45,
                                  backgroundColor: Colors.white24,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                identityName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (story != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    0,
                                  ),
                                  child: Text(
                                    story.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              if (call.business)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    call.incoming
                                        ? CallsCopy.recipientNotCharged
                                        : CallsCopy.creditsCharged(
                                            call.totalCost,
                                          ),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              if (call.endReason != null)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    call.endReason!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (active && connected)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => controller.setMuted(!call.muted),
                          icon: Icon(call.muted ? Icons.mic_off : Icons.mic),
                          tooltip: call.muted
                              ? CallsCopy.unmute
                              : CallsCopy.mute,
                        ),
                        IconButton.filledTonal(
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (_) => AudioOutputSheet(
                              controller: controller,
                              call: call,
                            ),
                          ),
                          icon: Icon(
                            call.output == CallOutput.speaker
                                ? Icons.volume_up
                                : call.output == CallOutput.bluetooth
                                ? Icons.bluetooth
                                : Icons.hearing,
                          ),
                          tooltip: CallsCopy.audioOutput,
                        ),
                        if (call.kind == CallKind.video)
                          IconButton.filledTonal(
                            onPressed: () =>
                                controller.setCamera(!call.cameraEnabled),
                            icon: Icon(
                              call.cameraEnabled
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                            ),
                            tooltip: call.cameraEnabled
                                ? CallsCopy.turnCameraOff
                                : CallsCopy.turnCameraOn,
                          ),
                        if (call.kind == CallKind.video)
                          IconButton.filledTonal(
                            onPressed: controller.switchCamera,
                            icon: const Icon(Icons.cameraswitch_outlined),
                            tooltip: CallsCopy.switchCamera,
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (active &&
                      (call.phase == CallPhase.ringing ||
                          call.phase == CallPhase.incoming))
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: controller.answer,
                          icon: const Icon(Icons.call),
                          label: Text(
                            call.incoming
                                ? CallsCopy.answer
                                : CallsCopy.simulateAnswer,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            controller.finishRinging(
                              call.incoming
                                  ? CallPhase.declined
                                  : CallPhase.cancelled,
                            );
                            _summary(context);
                          },
                          child: Text(
                            call.incoming
                                ? CallsCopy.decline
                                : CommonCopy.cancel,
                          ),
                        ),
                        if (!call.incoming)
                          PopupMenuButton<CallPhase>(
                            tooltip: CallsCopy.simulateOutcome,
                            onSelected: (outcome) {
                              controller.finishRinging(outcome);
                              _summary(context);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: CallPhase.busy,
                                child: Text(CallsCopy.busy),
                              ),
                              PopupMenuItem(
                                value: CallPhase.declined,
                                child: Text(CallsCopy.declined),
                              ),
                              PopupMenuItem(
                                value: CallPhase.missed,
                                child: Text(CallsCopy.unanswered),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    )
                  else if (active)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        controller.end();
                        _summary(context);
                      },
                      icon: const Icon(Icons.call_end),
                      label: const Text(CallsCopy.endCall),
                    )
                  else if (call.phase == CallPhase.permissionBlocked)
                    OutlinedButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text(CallsCopy.permissionNeeded),
                          content: const Text(
                            CallsCopy.permissionHelpExplanation,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text(CommonCopy.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.setPermissionGranted(true);
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                CallsCopy.simulateOpeningSettings,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: const Text(CallsCopy.permissionHelp),
                    )
                  else
                    TextButton(
                      onPressed: () => _summary(context),
                      child: const Text(
                        CallsCopy.viewSummary,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
