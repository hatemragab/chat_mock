import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../chats/controllers/chats_controller.dart';
import '../../chats/models/chat_models.dart';
import '../copy/groups_copy.dart';
import '../models/group_member.dart';
import '../models/group_photo.dart';
import 'group_controller.dart';

enum GroupCreationStatus { idle, submitting, failed }

/// Owns controllers for groups created during the current demonstration.
class GroupDirectory extends ChangeNotifier {
  GroupDirectory({required this.chats, required this.initialGroup}) {
    _groups[initialGroup.chatId] = initialGroup;
  }
  final ChatsController chats;
  final GroupController initialGroup;
  final Map<String, GroupController> _groups = {};
  GroupCreationStatus creationStatus = GroupCreationStatus.idle;
  Timer? _creationTimer;
  Completer<GroupController?>? _creationCompleter;
  bool _disposed = false;
  int _creationGeneration = 0;

  GroupController? forChat(String chatId) => _groups[chatId];
  Iterable<GroupController> get groups => List.unmodifiable(_groups.values);

  GroupController create({
    required String name,
    required String description,
    required Iterable<ChatConversation> members,
    GroupPhoto photo = GroupPhoto.none,
  }) {
    final group = _create(
      name: name,
      description: description,
      members: members,
      photo: photo,
    );
    notifyListeners();
    return group;
  }

  GroupController _create({
    required String name,
    required String description,
    required Iterable<ChatConversation> members,
    required GroupPhoto photo,
  }) {
    final title = name.trim();
    if (title.isEmpty) throw ArgumentError(GroupCopy.enterAGroupName);
    final selected = <String, ChatConversation>{};
    for (final member in members) {
      if (chats.canCommunicateWithContact(member)) {
        selected[member.id] = member;
      }
    }
    if (selected.isEmpty) {
      throw ArgumentError(GroupCopy.selectAtLeastOneContact);
    }
    final chat = chats.addGroup(title);
    final group = GroupController(
      chats: chats,
      chatId: chat.id,
      initialDescription: description.trim(),
      initialPhoto: photo,
      initialMembers: [
        GroupMember(id: 'alex', name: 'Alex Morgan', role: GroupRole.owner),
        ...selected.values.map(
          (member) => GroupMember(id: member.id, name: member.name),
        ),
      ],
    );
    _groups[chat.id] = group;
    return group;
  }

  Future<GroupController?> submitCreate({
    required String name,
    required String description,
    required Iterable<ChatConversation> members,
    GroupPhoto photo = GroupPhoto.none,
    Duration delay = const Duration(milliseconds: 400),
    bool simulateFailure = false,
  }) {
    if (creationStatus == GroupCreationStatus.submitting) {
      return Future.value(null);
    }
    final selected = members.toList();
    final generation = ++_creationGeneration;
    final completer = Completer<GroupController?>();
    _creationCompleter = completer;
    creationStatus = GroupCreationStatus.submitting;
    _creationTimer = Timer(delay, () {
      GroupController? group;
      if (!simulateFailure) {
        try {
          group = _create(
            name: name,
            description: description,
            members: selected,
            photo: photo,
          );
        } on ArgumentError {
          // Eligibility may change while the local submission is pending.
        }
      }
      if (generation != _creationGeneration ||
          completer.isCompleted ||
          _disposed) {
        if (group != null && identical(_groups[group.chatId], group)) {
          _groups.remove(group.chatId);
          group.dispose();
          if (_disposed) {
            group.conversation.hidden = true;
          } else {
            chats.deleteConversation(group.conversation);
          }
        }
        return;
      }
      creationStatus = group == null
          ? GroupCreationStatus.failed
          : GroupCreationStatus.idle;
      _creationTimer = null;
      _creationCompleter = null;
      notifyListeners();
      // A listener may reset or dispose the directory after creation commits.
      // Never return a controller that was disposed during that notification.
      completer.complete(
        !_disposed && group != null && identical(_groups[group.chatId], group)
            ? group
            : null,
      );
    });
    notifyListeners();
    return completer.future;
  }

  void cancelCreation() {
    _creationGeneration++;
    _creationTimer?.cancel();
    _creationTimer = null;
    final completer = _creationCompleter;
    _creationCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(null);
    if (creationStatus != GroupCreationStatus.idle) {
      creationStatus = GroupCreationStatus.idle;
      notifyListeners();
    }
  }

  /// The seed group remains owned by the app; created groups are disposed here.
  void reset() {
    cancelCreation();
    for (final group in _groups.values.where(
      (group) => group != initialGroup,
    )) {
      group.dispose();
    }
    _groups
      ..clear()
      ..[initialGroup.chatId] = initialGroup;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _creationGeneration++;
    _creationTimer?.cancel();
    final completer = _creationCompleter;
    if (completer != null && !completer.isCompleted) completer.complete(null);
    for (final group in _groups.values.where(
      (group) => group != initialGroup,
    )) {
      group.dispose();
    }
    super.dispose();
  }
}
