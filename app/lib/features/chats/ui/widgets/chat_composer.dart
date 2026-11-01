import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/copy/common_copy.dart';
import '../../copy/chats_copy.dart';
import '../../models/chat_mention_candidate.dart';
import 'mention_suggestions.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.onAttachment,
    this.editText,
    this.replyLabel,
    this.onCancelContext,
    this.enabled = true,
    this.onSendVoice,
    this.mentionCandidates = const [],
    this.initialDraft,
    this.onDraftChanged,
    this.focusInitialDraft = true,
    this.initialRecording = false,
    this.initialRecordingLocked = false,
  });
  final bool Function(String) onSend;
  final VoidCallback onAttachment;
  final String? editText;
  final String? replyLabel;
  final VoidCallback? onCancelContext;
  final bool enabled;
  final ValueChanged<Duration>? onSendVoice;
  final List<ChatMentionCandidate> mentionCandidates;
  final String? initialDraft;
  final ValueChanged<String>? onDraftChanged;
  final bool focusInitialDraft;
  final bool initialRecording;
  final bool initialRecordingLocked;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  bool _emojis = false;
  bool _recording = false;
  bool _locked = false;
  bool _recordStopped = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  TextEditingValue? _draftBeforeEdit;

  void _startRecording() {
    _recordTimer?.cancel();
    setState(() {
      _recording = true;
      _recordStopped = false;
      _locked = false;
      _recordSeconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordSeconds++);
    });
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() {
      _recording = false;
      _recordStopped = false;
      _locked = false;
      _recordSeconds = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.enabled && widget.initialRecording) {
      _recording = true;
      _locked = widget.initialRecordingLocked;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordSeconds++);
      });
    }
    final draft = widget.initialDraft;
    if (draft != null) {
      _text.value = TextEditingValue(
        text: draft,
        selection: TextSelection.collapsed(offset: draft.length),
      );
      if (widget.focusInitialDraft && draft.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.enabled) _focus.requestFocus();
        });
      }
    }
    _text.addListener(_changed);
  }

  void _changed() {
    if (widget.editText == null) widget.onDraftChanged?.call(_text.text);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _recording) {
      _recordTimer?.cancel();
      _recording = false;
      _recordStopped = false;
      _locked = false;
      _recordSeconds = 0;
    }
    if (widget.editText != null && widget.editText != oldWidget.editText) {
      if (oldWidget.editText == null) _draftBeforeEdit = _text.value;
      _text.value = TextEditingValue(
        text: widget.editText!,
        selection: TextSelection.collapsed(offset: widget.editText!.length),
      );
      _focus.requestFocus();
    }
    if (widget.editText == null &&
        oldWidget.editText != null &&
        _draftBeforeEdit != null) {
      _text.value = _draftBeforeEdit!;
      _draftBeforeEdit = null;
    }
    if (widget.replyLabel != null &&
        widget.replyLabel != oldWidget.replyLabel) {
      _focus.requestFocus();
    }
  }

  void _send() {
    if (_text.text.trim().isEmpty) return;
    if (!widget.onSend(_text.text)) return;
    _text.clear();
    _focus.requestFocus();
  }

  void _insert(String value) {
    final selection = _text.selection;
    final start = selection.isValid ? selection.start : _text.text.length;
    final end = selection.isValid ? selection.end : start;
    final next = _text.text.replaceRange(start, end, value);
    _text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  List<ChatMentionCandidate> get _matchingMentions {
    final selection = _text.selection;
    if (!selection.isValid || !selection.isCollapsed) return const [];
    final beforeCaret = _text.text.substring(0, selection.start);
    final match = RegExp(r'(?:^|\s)@([^@\n]*)$').firstMatch(beforeCaret);
    if (match == null) return const [];
    final query = match.group(1)!.toLowerCase();
    return widget.mentionCandidates
        .where((candidate) => candidate.name.toLowerCase().startsWith(query))
        .toList(growable: false);
  }

  void _insertMention(ChatMentionCandidate candidate) {
    final caret = _text.selection.start;
    if (caret < 0) return;
    final start = _text.text.lastIndexOf('@', caret - 1);
    if (start < 0) return;
    final inserted = '@${candidate.name} ';
    _text.value = TextEditingValue(
      text: _text.text.replaceRange(start, caret, inserted),
      selection: TextSelection.collapsed(offset: start + inserted.length),
    );
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _text.removeListener(_changed);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!widget.enabled) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(ChatCopy.messagingUnavailable, textAlign: TextAlign.center),
      );
    }
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_matchingMentions.isNotEmpty)
            MentionSuggestions(
              candidates: _matchingMentions,
              onSelected: _insertMention,
            ),
          if (widget.replyLabel != null || widget.editText != null)
            Material(
              color: scheme.surfaceContainerHighest,
              child: ListTile(
                dense: true,
                title: Text(
                  widget.editText != null
                      ? ChatCopy.editingMessage
                      : ChatCopy.replyingTo,
                  style: TextStyle(color: scheme.primary),
                ),
                subtitle: Text(
                  widget.editText ?? widget.replyLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: ChatCopy.cancelReplyOrEdit,
                  onPressed: () {
                    widget.onCancelContext?.call();
                    _focus.requestFocus();
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          if (_recording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: scheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ChatCopy.recordingStatus(
                            stopped: _recordStopped,
                            locked: _locked,
                            seconds: _recordSeconds,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _cancelRecording,
                        child: const Text(CommonCopy.cancel),
                      ),
                      if (!_locked && !_recordStopped)
                        IconButton(
                          tooltip: ChatCopy.lockRecording,
                          onPressed: () => setState(() => _locked = true),
                          icon: const Icon(Icons.lock_outline),
                        ),
                      if (!_recordStopped)
                        IconButton(
                          tooltip: ChatCopy.stopRecording,
                          onPressed: () {
                            _recordTimer?.cancel();
                            setState(() => _recordStopped = true);
                          },
                          icon: const Icon(Icons.stop),
                        ),
                      IconButton(
                        tooltip: ChatCopy.sendVoiceNote,
                        onPressed: () {
                          final duration = Duration(seconds: _recordSeconds);
                          if (widget.onSendVoice != null) {
                            widget.onSendVoice!(duration);
                          } else {
                            widget.onSend(ChatCopy.voiceNote(_recordSeconds));
                          }
                          _cancelRecording();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: ChatCopy.emoji,
                            onPressed: () => setState(() => _emojis = !_emojis),
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),
                          Expanded(
                            child: Focus(
                              onKeyEvent: (node, event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.enter &&
                                    !HardwareKeyboard.instance.isShiftPressed) {
                                  _send();
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: _text,
                                focusNode: _focus,
                                minLines: 1,
                                maxLines: 5,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  hintText: ChatCopy.message,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: ChatCopy.attach,
                            onPressed: widget.editText == null
                                ? widget.onAttachment
                                : null,
                            icon: const Icon(Icons.attach_file),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary,
                    child: IconButton(
                      tooltip: _text.text.trim().isEmpty
                          ? ChatCopy.recordVoiceNote
                          : CommonCopy.send,
                      color: scheme.onPrimary,
                      onPressed: _text.text.trim().isEmpty
                          ? _startRecording
                          : _send,
                      icon: Icon(
                        _text.text.trim().isEmpty ? Icons.mic : Icons.send,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_emojis)
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['😀', '😂', '🥰', '👍', '❤️', '🎉', '✨', '🙏']
                    .map(
                      (emoji) => TextButton(
                        onPressed: () => _insert(emoji),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
