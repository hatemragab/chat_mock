import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../chats/controllers/chats_controller.dart';
import '../../chats/models/chat_models.dart';
import '../models/group_member.dart';
import '../models/group_photo.dart';

enum GroupUpdateStatus { idle, submitting, failed }

class GroupController extends ChangeNotifier {
  GroupController({
    required this.chats,
    this.chatId = 'design',
    String? initialDescription,
    List<GroupMember>? initialMembers,
    this.initialPhoto = GroupPhoto.none,
  }) : _initialName = chats.byId(chatId).name,
       _initialDescription =
           initialDescription ?? 'Ideas, inspiration and design updates.',
       _initialMembers =
           initialMembers ??
           [
             GroupMember(
               id: 'alex',
               name: 'Alex Morgan',
               role: GroupRole.owner,
             ),
             GroupMember(
               id: 'sarah',
               name: 'Sarah Wilson',
               role: GroupRole.admin,
             ),
             GroupMember(id: 'amira', name: 'Amira Hassan'),
             GroupMember(id: 'john', name: 'John Davis'),
           ] {
    reset();
    chats.setSendGuard(chatId, () => canSend);
    chats.setSendIdentity(chatId, () => (perspective.id, perspective.name));
    chats.setGroupRecipientProvider(chatId, _recipientSnapshot);
    chats.addListener(_syncContactNames);
  }
  final ChatsController chats;
  final String chatId;
  final GroupPhoto initialPhoto;
  final String _initialName;
  final String _initialDescription;
  final List<GroupMember> _initialMembers;
  final List<GroupMember> members = [];
  String name = 'Design Team';
  String description = 'Ideas, inspiration and design updates.';
  String perspectiveId = 'alex';
  bool onlyAdminsCanSend = false;
  bool onlyAdminsCanEdit = true;
  bool onlyAdminsCanManage = true;
  GroupUpdateStatus updateStatus = GroupUpdateStatus.idle;
  int _updateGeneration = 0;
  bool _disposed = false;
  Timer? _updateTimer;
  Completer<bool>? _updateCompleter;
  bool get muted => conversation.muted;

  ChatConversation get conversation => chats.byId(chatId);
  GroupPhoto get photo => GroupPhoto.fromAsset(conversation.avatarAsset);
  GroupMember get perspective =>
      members.firstWhere((member) => member.id == perspectiveId);
  bool get left => perspective.departure == GroupDeparture.left;
  bool get removed => perspective.departure == GroupDeparture.removed;
  Iterable<GroupMember> get activeMembers =>
      members.where((member) => member.active);
  bool get isManager =>
      perspective.active &&
      (perspective.role == GroupRole.owner ||
          perspective.role == GroupRole.admin);
  bool get canSend =>
      perspective.active &&
      !left &&
      !removed &&
      (!onlyAdminsCanSend || isManager);
  bool get canEdit =>
      perspective.active &&
      !left &&
      !removed &&
      (!onlyAdminsCanEdit || isManager);
  bool get canManage =>
      perspective.active &&
      !left &&
      !removed &&
      (!onlyAdminsCanManage || isManager);
  bool get isOwner =>
      perspective.active &&
      !left &&
      !removed &&
      perspective.role == GroupRole.owner;

  void reset() {
    _updateGeneration++;
    _clearPendingUpdate();
    updateStatus = GroupUpdateStatus.idle;
    name = _initialName;
    description = _initialDescription;
    perspectiveId = 'alex';
    onlyAdminsCanSend = false;
    onlyAdminsCanEdit = true;
    onlyAdminsCanManage = true;
    members
      ..clear()
      ..addAll(
        _initialMembers.map(
          (member) => GroupMember(
            id: member.id,
            name: member.name,
            role: member.role,
            active: member.active,
          ),
        ),
      );
    chats.renameConversation(chatId, name);
    chats.setConversationAvatar(chatId, initialPhoto.assetPath);
    _syncMembers();
    _seedReceiptExamples();
    notifyListeners();
  }

  List<MessageRecipientReceipt> _recipientSnapshot(String? authorId) =>
      activeMembers
          .where((member) => member.id != authorId)
          .map(
            (member) => MessageRecipientReceipt(
              memberId: member.id,
              memberName: member.name,
            ),
          )
          .toList();

  void _seedReceiptExamples() {
    if (chatId != 'design') return;
    final own = conversation.messages.where((message) => isOwnMessage(message));
    var sample = 0;
    for (final message in own) {
      if (message.recipients.isNotEmpty) continue;
      final recipients = _recipientSnapshot('alex');
      for (var i = 0; i < recipients.length; i++) {
        final receipt = recipients[i];
        receipt.status = sample == 0 || i == 0
            ? RecipientDeliveryStatus.read
            : RecipientDeliveryStatus.delivered;
        receipt.deliveredAt = message.time.add(const Duration(minutes: 1));
        if (receipt.status == RecipientDeliveryStatus.read) {
          receipt.readAt = message.time.add(const Duration(minutes: 2));
        }
      }
      message.recipients.addAll(recipients);
      message.status = sample == 0
          ? DeliveryStatus.read
          : DeliveryStatus.delivered;
      sample++;
    }
  }

  /// Advances one recipient's receipt for a message sent by this perspective.
  bool advanceReceipt(
    ChatMessage message,
    String memberId,
    RecipientDeliveryStatus next,
  ) {
    if (!perspective.active ||
        !isOwnMessage(message) ||
        message.deleted ||
        message.status == DeliveryStatus.queued ||
        message.status == DeliveryStatus.sending ||
        message.status == DeliveryStatus.failed ||
        !conversation.messages.contains(message)) {
      return false;
    }
    final matches = message.recipients.where(
      (item) => item.memberId == memberId,
    );
    if (matches.isEmpty) return false;
    final receipt = matches.first;
    if (next.index <= receipt.status.index) return false;
    final now = DateTime.now();
    receipt.status = next;
    if (next.index >= RecipientDeliveryStatus.delivered.index) {
      receipt.deliveredAt ??= now;
    }
    if (next == RecipientDeliveryStatus.read) receipt.readAt = now;
    if (message.recipients.every(
      (item) => item.status == RecipientDeliveryStatus.read,
    )) {
      message.status = DeliveryStatus.read;
    } else if (message.recipients.every(
      (item) => item.status.index >= RecipientDeliveryStatus.delivered.index,
    )) {
      message.status = DeliveryStatus.delivered;
    }
    chats.refreshConversations();
    return true;
  }

  void _syncMembers() {
    final names = activeMembers.map((member) => member.name).toList();
    chats.updateSubtitle(chatId, names.join(', '));
  }

  void _syncContactNames() {
    var changed = false;
    for (final member in members) {
      for (final contact in chats.conversations) {
        if (contact.kind == ChatKind.contact &&
            contact.id == member.id &&
            contact.name != member.name) {
          member.name = contact.name;
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      _syncMembers();
      notifyListeners();
    }
  }

  void setPerspective(String id) {
    if (!members.any((member) => member.id == id)) return;
    perspectiveId = id;
    notifyListeners();
  }

  bool updateIdentity(
    String nextName,
    String nextDescription, {
    GroupPhoto? photo,
  }) {
    if (!canEdit || nextName.trim().isEmpty) return false;
    name = nextName.trim();
    description = nextDescription.trim();
    chats.renameConversation(chatId, name);
    if (photo != null) chats.setConversationAvatar(chatId, photo.assetPath);
    notifyListeners();
    return true;
  }

  Future<bool> submitIdentity(
    String nextName,
    String nextDescription, {
    Duration delay = const Duration(milliseconds: 400),
    bool simulateFailure = false,
    GroupPhoto? photo,
  }) {
    if (!canEdit ||
        nextName.trim().isEmpty ||
        updateStatus == GroupUpdateStatus.submitting) {
      return Future.value(false);
    }
    final generation = ++_updateGeneration;
    final completer = Completer<bool>();
    _updateCompleter = completer;
    updateStatus = GroupUpdateStatus.submitting;
    notifyListeners();
    _updateTimer = Timer(delay, () {
      if (_disposed || generation != _updateGeneration) return;
      final saved =
          !simulateFailure &&
          canEdit &&
          updateIdentity(nextName, nextDescription, photo: photo);
      updateStatus = saved ? GroupUpdateStatus.idle : GroupUpdateStatus.failed;
      _updateTimer = null;
      _updateCompleter = null;
      notifyListeners();
      completer.complete(saved);
    });
    return completer.future;
  }

  void _clearPendingUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
    final completer = _updateCompleter;
    _updateCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(false);
  }

  void cancelUpdate() {
    if (updateStatus != GroupUpdateStatus.submitting) return;
    _updateGeneration++;
    _clearPendingUpdate();
    updateStatus = GroupUpdateStatus.idle;
    notifyListeners();
  }

  bool addMembers(Iterable<GroupMember> candidates) {
    if (!canManage) return false;
    var changed = false;
    for (final candidate in candidates) {
      if (!chats.conversations.any(
        (chat) =>
            chat.id == candidate.id && chats.canCommunicateWithContact(chat),
      )) {
        continue;
      }
      final matches = members.where((member) => member.id == candidate.id);
      if (matches.isNotEmpty) {
        if (!matches.first.active) {
          matches.first.active = true;
          matches.first.role = GroupRole.member;
          matches.first.departure = null;
          changed = true;
        }
      } else {
        members.add(GroupMember(id: candidate.id, name: candidate.name));
        changed = true;
      }
    }
    if (changed) {
      _syncMembers();
      notifyListeners();
    }
    return changed;
  }

  bool promote(GroupMember member) {
    if (!isOwner ||
        !members.contains(member) ||
        !member.active ||
        member.role != GroupRole.member) {
      return false;
    }
    member.role = GroupRole.admin;
    notifyListeners();
    return true;
  }

  bool demote(GroupMember member) {
    if (!isOwner ||
        !members.contains(member) ||
        !member.active ||
        member.role != GroupRole.admin) {
      return false;
    }
    member.role = GroupRole.member;
    notifyListeners();
    return true;
  }

  bool remove(GroupMember member) {
    if (!canManage ||
        !members.contains(member) ||
        !member.active ||
        member.id == perspectiveId ||
        member.role == GroupRole.owner ||
        (!isOwner && member.role == GroupRole.admin)) {
      return false;
    }
    member.active = false;
    member.departure = GroupDeparture.removed;
    _syncMembers();
    notifyListeners();
    return true;
  }

  bool transfer(GroupMember member) {
    if (!isOwner ||
        !members.contains(member) ||
        !member.active ||
        member.id == perspectiveId) {
      return false;
    }
    perspective.role = GroupRole.admin;
    member.role = GroupRole.owner;
    notifyListeners();
    return true;
  }

  bool leave() {
    if (!perspective.active || isOwner) return false;
    perspective.active = false;
    perspective.departure = GroupDeparture.left;
    _syncMembers();
    notifyListeners();
    return true;
  }

  void setPermissions({bool? send, bool? edit, bool? manage}) {
    if (!isManager || left || removed) return;
    onlyAdminsCanSend = send ?? onlyAdminsCanSend;
    onlyAdminsCanEdit = edit ?? onlyAdminsCanEdit;
    onlyAdminsCanManage = manage ?? onlyAdminsCanManage;
    notifyListeners();
  }

  void toggleMuted() {
    chats.toggleMuted(conversation);
    notifyListeners();
  }

  void muteFor(Duration? duration) {
    chats.muteFor(conversation, duration);
    notifyListeners();
  }

  void unmute() {
    chats.unmute(conversation);
    notifyListeners();
  }

  ChatMessage? send(String text, {ChatMessage? reply}) => canSend
      ? chats.send(
          conversation,
          text,
          reply: reply,
          author: perspective.name,
          authorId: perspective.id,
          mentionedMemberIds: activeMembers
              .where(
                (member) =>
                    member.id != perspectiveId &&
                    RegExp(
                      '(?:^|\\s)@${RegExp.escape(member.name)}(?=\\s|[.,!?;:]|\$)',
                      caseSensitive: false,
                    ).hasMatch(text),
              )
              .map((member) => member.id)
              .toList(),
        )
      : null;

  bool isOwnMessage(ChatMessage message) => message.authorId != null
      ? message.authorId == perspective.id
      : message.author == perspective.name ||
            message.author == perspective.name.split(' ').first;

  @override
  void dispose() {
    _disposed = true;
    _updateGeneration++;
    _clearPendingUpdate();
    chats.removeListener(_syncContactNames);
    chats.setSendGuard(chatId, null);
    chats.setSendIdentity(chatId, null);
    chats.setGroupRecipientProvider(chatId, null);
    super.dispose();
  }
}
