import 'package:flutter/material.dart';

import '../../copy/calls_copy.dart';
import '../../models/call_session.dart';
import 'business_call_story_cover.dart';

/// Simulated self preview before answering, then remote and self previews.
class CallVideoPreview extends StatelessWidget {
  const CallVideoPreview({super.key, required this.call});

  final CallSession call;

  @override
  Widget build(BuildContext context) {
    final incoming = call.phase == CallPhase.incoming;
    final story = call.business ? call.story : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (incoming)
                      Icon(
                        call.cameraEnabled
                            ? Icons.videocam_outlined
                            : Icons.videocam_off,
                        size: 52,
                        color: Colors.white70,
                      )
                    else if (story != null)
                      BusinessCallStoryCover(story: story, size: 72)
                    else
                      const Icon(
                        Icons.person_outline,
                        size: 52,
                        color: Colors.white70,
                      ),
                    Text(
                      incoming
                          ? CallsCopy.cameraPreview
                          : CallsCopy.remotePreview(story?.author ?? call.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (incoming && story != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: BusinessCallStoryCover(story: story, size: 48),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    call.cameraEnabled
                        ? (call.frontCamera
                              ? CallsCopy.youFrontCamera
                              : CallsCopy.youBackCamera)
                        : CallsCopy.cameraOff,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
