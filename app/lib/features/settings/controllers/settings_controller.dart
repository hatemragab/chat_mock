import '../copy/settings_copy.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../chats/controllers/chats_controller.dart';
import '../../chats/models/chat_models.dart';
import '../../notifications/controllers/notification_center.dart';
import '../../stories/models/story.dart';
import '../models/settings_models.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({required this.chats});
  final ChatsController chats;
  late final NotificationCenter notifications = NotificationCenter(
    hasPermission: () => permissions['Notifications'] == MockPermission.allowed,
    shouldNotify: shouldNotify,
    vibrationEnabled: () => vibration,
  );
  PhotoVisibility photoVisibility = PhotoVisibility.contacts;
  StatusAudience audience = StatusAudience.contacts;
  final Set<String> audienceContactIds = {};
  bool readReceipts = true;
  bool messageNotifications = true;
  bool groupNotifications = true;
  bool callNotifications = true;
  bool previews = true;
  bool vibration = true;
  double textScaleFactor = 1.0;
  ContactMatchingState _contactMatchingState = ContactMatchingState.idle;

  /// Reflects blocked contacts without discarding the matched snapshot.
  ContactMatchingState get contactMatchingState =>
      _contactMatchingState == ContactMatchingState.matched &&
          matchedContacts.isEmpty
      ? ContactMatchingState.empty
      : _contactMatchingState;
  final Set<String> _matchedContactIds = {};
  Timer? _contactMatchingTimer;
  bool _failNextContactMatch = false;
  String about = SettingsCopy.helloThereIAmUsingWhizpee;
  BusinessProfile businessProfile = const BusinessProfile();
  final Set<String> businessStoryIds = {};
  final Set<String> _blockedBusinesses = {};
  RestrictionLevel? restriction;
  final Map<String, MockPermission> permissions = {
    'Contacts': MockPermission.allowed,
    'Camera': MockPermission.denied,
    'Microphone': MockPermission.denied,
    'Media': MockPermission.denied,
    'Location': MockPermission.denied,
    'Notifications': MockPermission.allowed,
  };

  List<ChatConversation> get blockedAccounts =>
      chats.conversations.where((chat) => chat.blocked).toList();

  /// Business blocks are keyed by public identity, not by a private profile or
  /// an individual Story. Existing room rows stay in sync with this setting.
  Set<String> get blockedBusinessNames => {
    ..._blockedBusinesses,
    ...chats.conversations
        .where((chat) => chat.kind == ChatKind.business && chat.blocked)
        .map((chat) => chat.name),
  };

  int get blockedAccountCount =>
      blockedAccounts.where((chat) => chat.kind != ChatKind.business).length +
      blockedBusinessNames.length;

  bool isBusinessBlocked(String name) => blockedBusinessNames.contains(name);

  void setBusinessBlocked(String name, bool blocked) {
    if (blocked) {
      _blockedBusinesses.add(name);
    } else {
      _blockedBusinesses.remove(name);
    }
    for (final chat in chats.conversations.where(
      (chat) => chat.kind == ChatKind.business && chat.name == name,
    )) {
      if (chat.blocked != blocked) chats.toggleBlocked(chat);
    }
    notifyListeners();
  }

  /// Only eligible contacts are considered for the audience of own Statuses.
  bool canShareStatusWith(String contactId) {
    final matches = chats.conversations.where(
      (chat) => chat.id == contactId && chats.canCommunicateWithContact(chat),
    );
    if (matches.isEmpty) return false;
    return switch (audience) {
      StatusAudience.contacts => true,
      StatusAudience.except => !audienceContactIds.contains(contactId),
      StatusAudience.only => audienceContactIds.contains(contactId),
    };
  }

  bool canShowPhotoTo({required bool isContact, bool blocked = false}) {
    if (blocked) return false;
    return switch (photoVisibility) {
      PhotoVisibility.everyone => true,
      PhotoVisibility.contacts => isContact,
      PhotoVisibility.nobody => false,
    };
  }

  PrivateProfilePresentation privateProfileFor({
    required String displayName,
    required bool isContact,
    bool blocked = false,
  }) => PrivateProfilePresentation(
    displayName: blocked ? SettingsCopy.blockedAccount : displayName,
    photoVisible: canShowPhotoTo(isContact: isContact, blocked: blocked),
  );

  bool shouldNotify(NotificationKind kind) {
    if (permissions['Notifications'] != MockPermission.allowed) return false;
    return switch (kind) {
      NotificationKind.message => messageNotifications,
      NotificationKind.group => groupNotifications,
      NotificationKind.call => callNotifications,
    };
  }

  bool get canMessage =>
      restriction == null || restriction == RestrictionLevel.warning;
  bool get canPublish => canMessage;

  void setRestriction(RestrictionLevel? value) {
    restriction = value;
    notifyListeners();
  }

  bool saveBusinessProfile(BusinessProfile value) {
    if (!value.isComplete) return false;
    businessProfile = value;
    notifyListeners();
    return true;
  }

  bool linkBusinessStory(Story story) {
    if (!businessProfile.isComplete ||
        story.kind != StoryKind.own ||
        (!story.boosted && !story.sponsored)) {
      return false;
    }
    if (businessStoryIds.add(story.id)) notifyListeners();
    return true;
  }

  void unlinkBusinessStory(String storyId) {
    if (businessStoryIds.remove(storyId)) notifyListeners();
  }

  void setPhotoVisibility(PhotoVisibility value) {
    photoVisibility = value;
    notifyListeners();
  }

  void setAudience(StatusAudience value, Set<String> ids) {
    audience = value;
    audienceContactIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void setReadReceipts(bool value) {
    readReceipts = value;
    notifyListeners();
  }

  void setMessageNotifications(bool value) {
    messageNotifications = value;
    notifyListeners();
  }

  void setGroupNotifications(bool value) {
    groupNotifications = value;
    notifyListeners();
  }

  void setCallNotifications(bool value) {
    callNotifications = value;
    notifyListeners();
  }

  void setPreviews(bool value) {
    previews = value;
    notifyListeners();
  }

  void setVibration(bool value) {
    vibration = value;
    notifyListeners();
  }

  /// An app-specific multiplier, applied on top of the system text scale.
  void setTextScaleFactor(double value) {
    final next = value.clamp(0.9, 1.3).toDouble();
    if (next == textScaleFactor) return;
    textScaleFactor = next;
    notifyListeners();
  }

  List<ChatConversation> get matchedContacts => List.unmodifiable(
    chats.conversations.where(
      (chat) =>
          _matchedContactIds.contains(chat.id) &&
          chat.kind == ChatKind.contact &&
          chat.mutuallyMatched &&
          !chat.blocked,
    ),
  );

  /// Causes the next mock matching attempt to fail, for review or testing.
  void failNextContactMatch() => _failNextContactMatch = true;

  /// Simulates mutual matching using existing session fixtures only.
  void startContactMatching({
    Duration delay = const Duration(milliseconds: 800),
  }) {
    _contactMatchingTimer?.cancel();
    if (permissions['Contacts'] != MockPermission.allowed) {
      _matchedContactIds.clear();
      _contactMatchingState = ContactMatchingState.denied;
      notifyListeners();
      return;
    }
    _contactMatchingState = ContactMatchingState.matching;
    notifyListeners();
    _contactMatchingTimer = Timer(delay, () {
      _contactMatchingTimer = null;
      if (_failNextContactMatch) {
        _failNextContactMatch = false;
        _contactMatchingState = ContactMatchingState.failed;
      } else {
        _matchedContactIds
          ..clear()
          ..addAll(
            chats.conversations
                .where(
                  (chat) =>
                      chat.kind == ChatKind.contact &&
                      chat.mutuallyMatched &&
                      !chat.blocked,
                )
                .map((chat) => chat.id),
          );
        _contactMatchingState = _matchedContactIds.isEmpty
            ? ContactMatchingState.empty
            : ContactMatchingState.matched;
      }
      notifyListeners();
    });
  }

  void cancelContactMatching() {
    if (contactMatchingState != ContactMatchingState.matching) return;
    _contactMatchingTimer?.cancel();
    _contactMatchingTimer = null;
    _contactMatchingState = ContactMatchingState.idle;
    notifyListeners();
  }

  void setAbout(String value) {
    about = value.trim();
    notifyListeners();
  }

  void setPermission(String key, MockPermission value) {
    if (!permissions.containsKey(key)) return;
    permissions[key] = value;
    if (key == 'Contacts') {
      if (value != MockPermission.allowed) {
        _contactMatchingTimer?.cancel();
        _contactMatchingTimer = null;
        _matchedContactIds.clear();
        _contactMatchingState = ContactMatchingState.denied;
      } else if (contactMatchingState == ContactMatchingState.denied) {
        _contactMatchingState = ContactMatchingState.idle;
      }
    }
    notifyListeners();
  }

  void unblock(ChatConversation chat) {
    if (chat.kind == ChatKind.business) {
      setBusinessBlocked(chat.name, false);
      return;
    }
    if (chat.blocked) chats.toggleBlocked(chat);
    notifyListeners();
  }

  void reset() {
    _contactMatchingTimer?.cancel();
    _contactMatchingTimer = null;
    _matchedContactIds.clear();
    _failNextContactMatch = false;
    _contactMatchingState = ContactMatchingState.idle;
    textScaleFactor = 1.0;
    notifications.reset();
    photoVisibility = PhotoVisibility.contacts;
    audience = StatusAudience.contacts;
    audienceContactIds.clear();
    readReceipts = true;
    messageNotifications = true;
    groupNotifications = true;
    callNotifications = true;
    previews = true;
    vibration = true;
    about = SettingsCopy.helloThereIAmUsingWhizpee;
    businessProfile = const BusinessProfile();
    businessStoryIds.clear();
    _blockedBusinesses.clear();
    restriction = null;
    permissions.addAll({
      'Contacts': MockPermission.allowed,
      'Camera': MockPermission.denied,
      'Microphone': MockPermission.denied,
      'Media': MockPermission.denied,
      'Location': MockPermission.denied,
      'Notifications': MockPermission.allowed,
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _contactMatchingTimer?.cancel();
    notifications.dispose();
    super.dispose();
  }
}
