import '../../stories/models/story.dart';
import '../copy/calls_copy.dart';

enum CallKind { audio, video }

enum CallPhase {
  ringing,
  incoming,
  active,
  reconnecting,
  busy,
  declined,
  missed,
  cancelled,
  ended,
  permissionBlocked,
}

enum CallOutput { earpiece, speaker, bluetooth }

/// Billing-related terminal causes, separate from the customer explanation.
enum CallEndCause { insufficientStartCredits, insufficientNextBlock }

class CallSession {
  CallSession({
    required this.id,
    required String name,
    required this.kind,
    required this.business,
    required this.incoming,
    required this.phase,
    this.contactId,
    this.endCause,
    String? storyId,
    this.story,
    DateTime? occurredAt,
  }) : assert(story == null || business),
       assert(story == null || storyId == null || story.id == storyId),
       name = story?.author ?? name,
       storyId = story?.id ?? storyId,
       occurredAt = occurredAt ?? DateTime.now();
  final String id;
  final String name;
  final CallKind kind;
  final bool business;
  final bool incoming;

  /// Stable contact identity for personal calls, independent of display name.
  final String? contactId;
  final String? storyId;
  final Story? story;
  final DateTime occurredAt;
  CallPhase phase;
  int seconds = 0;
  int chargedBlocks = 0;
  int totalCost = 0;
  bool muted = false;
  bool speaker = false;
  CallOutput output = CallOutput.earpiece;
  bool cameraEnabled = true;
  bool frontCamera = true;
  bool minimized = false;
  String? endReason;
  CallEndCause? endCause;
  bool get isOngoing =>
      phase == CallPhase.ringing ||
      phase == CallPhase.incoming ||
      phase == CallPhase.active ||
      phase == CallPhase.reconnecting;
}

/// Display labels remain separate from the state-machine identifiers.
extension CallKindLabel on CallKind {
  String get label => switch (this) {
    CallKind.audio => CallsCopy.audioKind,
    CallKind.video => CallsCopy.videoKind,
  };
}

extension CallPhaseLabel on CallPhase {
  String get label => switch (this) {
    CallPhase.ringing => CallsCopy.phaseRinging,
    CallPhase.incoming => CallsCopy.phaseIncoming,
    CallPhase.active => CallsCopy.phaseActive,
    CallPhase.reconnecting => CallsCopy.phaseReconnecting,
    CallPhase.busy => CallsCopy.phaseBusy,
    CallPhase.declined => CallsCopy.phaseDeclined,
    CallPhase.missed => CallsCopy.phaseMissed,
    CallPhase.cancelled => CallsCopy.phaseCancelled,
    CallPhase.ended => CallsCopy.phaseEnded,
    CallPhase.permissionBlocked => CallsCopy.phasePermissionBlocked,
  };
}
