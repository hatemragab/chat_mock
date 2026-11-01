import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../stories/controllers/stories_controller.dart';
import '../../stories/models/story.dart';
import '../copy/calls_copy.dart';
import '../models/call_session.dart';

typedef SpendCredits = bool Function(String id, int amount, String description);

class CallsController extends ChangeNotifier {
  CallsController({
    required this.spendCredits,
    this.availableCredits,
    this.seedHistory = false,
    this.audioBlockCredits = 15,
    this.videoBlockCredits = 25,
    this.onIncomingCall,
    this.canRecallContact,
    this.contactChanges,
    this.contactName,
  }) {
    if (seedHistory) _seedHistory();
  }
  final SpendCredits spendCredits;
  final int Function()? availableCredits;
  final bool seedHistory;
  final int audioBlockCredits;
  final int videoBlockCredits;
  final void Function(CallSession call)? onIncomingCall;

  /// Resolves current contact eligibility rather than trusting an old call row.
  final bool Function(CallSession call)? canRecallContact;
  final Listenable? contactChanges;

  /// Returns the current contact name when creating a new redial session.
  final String? Function(CallSession call)? contactName;
  Listenable get changes => Listenable.merge([this, ?contactChanges]);
  final List<CallSession> history = [];
  CallSession? active;
  Timer? _timer;
  int _sequence = 0;
  bool permissionGranted = true;

  int rateFor(CallKind kind) =>
      kind == CallKind.audio ? audioBlockCredits : videoBlockCredits;
  bool get lowBalance {
    final call = active;
    final balance = availableCredits?.call();
    return call != null &&
        call.business &&
        !call.incoming &&
        (call.phase == CallPhase.active ||
            call.phase == CallPhase.reconnecting) &&
        balance != null &&
        balance < rateFor(call.kind);
  }

  void _seedHistory() {
    final recent = CallSession(
      id: 'fixture-sarah',
      name: 'Sarah Wilson',
      kind: CallKind.audio,
      business: false,
      incoming: false,
      phase: CallPhase.ended,
      contactId: 'sarah',
      occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
    )..seconds = 184;
    final missed = CallSession(
      id: 'fixture-amira',
      name: 'Amira Hassan',
      kind: CallKind.video,
      business: false,
      incoming: true,
      phase: CallPhase.missed,
      contactId: 'amira',
      occurredAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    final business =
        CallSession(
            id: 'fixture-maison',
            name: 'Maison Studio',
            kind: CallKind.audio,
            business: true,
            incoming: false,
            phase: CallPhase.ended,
            storyId: 'maison',
            story: StoriesController.stories.firstWhere(
              (story) => story.id == 'maison',
            ),
            occurredAt: DateTime.now().subtract(const Duration(days: 2)),
          )
          ..seconds = 36
          ..chargedBlocks = 1
          ..totalCost = audioBlockCredits;
    history.addAll([recent, missed, business]);
  }

  CallSession start({
    required String name,
    required CallKind kind,
    bool business = false,
    bool incoming = false,
    String? contactId,
    String? storyId,
    Story? story,
  }) {
    if (active?.isOngoing ?? false) {
      throw StateError(CallsCopy.callAlreadyInProgress);
    }
    final call = CallSession(
      id: 'call-${++_sequence}',
      name: name,
      kind: kind,
      business: business,
      incoming: incoming,
      contactId: contactId,
      storyId: storyId,
      story: story,
      phase: !permissionGranted
          ? CallPhase.permissionBlocked
          : incoming
          ? CallPhase.incoming
          : CallPhase.ringing,
    );
    if (permissionGranted) {
      active = call;
      if (incoming) onIncomingCall?.call(call);
    } else {
      call.endReason = CallsCopy.callPermissionUnavailable;
    }
    notifyListeners();
    return call;
  }

  bool canRecall(CallSession call) =>
      !call.business &&
      active == null &&
      permissionGranted &&
      (canRecallContact?.call(call) ?? true);

  String nameForRedial(CallSession call) {
    final current = contactName?.call(call)?.trim();
    return current == null || current.isEmpty ? call.name : current;
  }

  bool answer() {
    final call = active;
    if (call == null ||
        (call.phase != CallPhase.ringing && call.phase != CallPhase.incoming)) {
      return false;
    }
    if (!_chargeNextBlock(call)) {
      end(
        reason: CallsCopy.insufficientCreditsToStart,
        cause: CallEndCause.insufficientStartCredits,
      );
      return false;
    }
    call.phase = CallPhase.active;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => advance(1));
    notifyListeners();
    return true;
  }

  bool _chargeNextBlock(CallSession call) {
    if (!call.business || call.incoming) return true;
    final amount = rateFor(call.kind);
    if (!spendCredits(
      '${call.id}-block-${call.chargedBlocks + 1}',
      amount,
      CallsCopy.businessCallCharge(call.kind.label),
    )) {
      return false;
    }
    call.chargedBlocks++;
    call.totalCost += amount;
    return true;
  }

  void advance(int seconds) {
    final call = active;
    if (call == null ||
        (call.phase != CallPhase.active &&
            call.phase != CallPhase.reconnecting) ||
        seconds <= 0) {
      return;
    }
    for (var i = 0; i < seconds; i++) {
      if (call.business &&
          !call.incoming &&
          call.seconds > 0 &&
          call.seconds % 60 == 0 &&
          !_chargeNextBlock(call)) {
        end(
          reason: CallsCopy.paidBoundaryEnded,
          cause: CallEndCause.insufficientNextBlock,
        );
        return;
      }
      call.seconds++;
      // The current paid block is complete at this boundary. Check the next
      // block without charging it; a charge is made only if time advances
      // into that block.
      if (call.business &&
          !call.incoming &&
          call.seconds % 60 == 0 &&
          availableCredits != null &&
          availableCredits!() < rateFor(call.kind)) {
        end(
          reason: CallsCopy.paidBoundaryEnded,
          cause: CallEndCause.insufficientNextBlock,
        );
        return;
      }
    }
    notifyListeners();
  }

  void finishRinging(CallPhase outcome) {
    final call = active;
    if (call == null ||
        (call.phase != CallPhase.ringing && call.phase != CallPhase.incoming)) {
      return;
    }
    if (![
      CallPhase.busy,
      CallPhase.declined,
      CallPhase.missed,
      CallPhase.cancelled,
    ].contains(outcome)) {
      return;
    }
    call.phase = outcome;
    history.insert(0, call);
    active = null;
    notifyListeners();
  }

  void end({String? reason, CallEndCause? cause}) {
    final call = active;
    if (call == null) return;
    _timer?.cancel();
    call.phase = CallPhase.ended;
    call.endReason = reason;
    call.endCause = cause;
    history.insert(0, call);
    active = null;
    notifyListeners();
  }

  void setMuted(bool value) {
    if (active case final call?) {
      call.muted = value;
      notifyListeners();
    }
  }

  void setSpeaker(bool value) {
    if (active case final call?) {
      call.speaker = value;
      call.output = value ? CallOutput.speaker : CallOutput.earpiece;
      notifyListeners();
    }
  }

  void setOutput(CallOutput value) {
    if (active case final call?) {
      call.output = value;
      call.speaker = value == CallOutput.speaker;
      notifyListeners();
    }
  }

  void switchCamera() {
    if (active case final call?) {
      if (call.kind != CallKind.video) return;
      call.frontCamera = !call.frontCamera;
      notifyListeners();
    }
  }

  void setReconnecting(bool value) {
    if (active case final call?) {
      if (call.phase != CallPhase.active &&
          call.phase != CallPhase.reconnecting) {
        return;
      }
      call.phase = value ? CallPhase.reconnecting : CallPhase.active;
      notifyListeners();
    }
  }

  void setPermissionGranted(bool value) {
    permissionGranted = value;
    notifyListeners();
  }

  void deleteHistory(CallSession call) {
    if (history.remove(call)) notifyListeners();
  }

  void setCamera(bool value) {
    if (active case final call?) {
      call.cameraEnabled = value;
      notifyListeners();
    }
  }

  void setMinimized(bool value) {
    if (active case final call?) {
      call.minimized = value;
      notifyListeners();
    }
  }

  void reset() {
    _timer?.cancel();
    active = null;
    history.clear();
    _sequence = 0;
    permissionGranted = true;
    if (seedHistory) _seedHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
