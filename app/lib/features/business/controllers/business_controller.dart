import 'package:flutter/foundation.dart';

import '../../chats/controllers/chats_controller.dart';
import '../../chats/models/chat_models.dart';
import '../../chats/models/chat_media_edits.dart';
import '../../chats/models/chat_media_samples.dart';
import '../../chats/models/chat_file_metadata.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../stories/controllers/stories_controller.dart';
import '../../stories/models/story.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../copy/business_copy.dart';
import '../data/mock/public_business_profiles.dart';
import '../models/business_room.dart';
import '../models/public_business_profile.dart';

/// Session-only business rooms are keyed by their originating Story.
class BusinessController extends ChangeNotifier {
  BusinessController({
    required this.wallet,
    this.config = const BusinessConfig(),
    this.stories,
    this.chats,
    this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    stories?.addListener(_storyChanged);
    chats?.addListener(_chatChanged);
    settings?.addListener(_settingsChanged);
    _seedHistory();
  }
  final WalletController wallet;
  final BusinessConfig config;
  final StoriesController? stories;
  final ChatsController? chats;
  final SettingsController? settings;
  void _storyChanged() => notifyListeners();
  void _chatChanged() => notifyListeners();
  void _settingsChanged() => notifyListeners();
  final DateTime Function() _clock;
  Duration _offset = Duration.zero;
  final Map<String, BusinessRoom> _rooms = {};
  final Set<String> _openingRooms = {};
  final Map<(String, BusinessPerspective), String> _drafts = {};
  final Set<String> _unavailableStories = {};
  final Set<String> _blockedBusinesses = {};
  int _messageSequence = 0;
  BusinessPerspective perspective = BusinessPerspective.customer;

  DateTime get now => _clock().add(_offset);
  List<BusinessRoom> get rooms => List.unmodifiable(_rooms.values);
  BusinessRoom? roomFor(String storyId) => _rooms[storyId];
  PublicBusinessProfile profileFor(Story story) {
    final own = settings?.businessProfile;
    if (own != null &&
        own.isComplete &&
        own.name == story.author &&
        settings!.businessStoryIds.contains(story.id)) {
      return PublicBusinessProfile(
        name: own.name,
        category: own.category,
        description: own.description,
        location: own.location,
        coverAssetPath: own.coverAssetPath,
        logoAssetPath: own.logoAssetPath,
      );
    }
    return publicBusinessProfiles[story.author] ??
        PublicBusinessProfile(
          name: story.author,
          category: story.category,
          description: story.title,
          coverAssetPath: story.assetPath,
        );
  }

  String draftFor(String storyId) => _drafts[(storyId, perspective)] ?? '';
  void setDraft(String storyId, String text) {
    final key = (storyId, perspective);
    if (text.isEmpty) {
      _drafts.remove(key);
    } else {
      _drafts[key] = text;
    }
  }

  Story? storyForChat(ChatConversation chat) =>
      chat.kind == ChatKind.business && chat.sourceStoryId != null
      ? _rooms[chat.sourceStoryId]?.story
      : null;

  void _seedHistory() {
    if (chats == null || stories == null) return;
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'maison',
    );
    final chat = chats!.ensureBusinessConversation(story.id, story.author);
    chat.messages.add(
      ChatMessage(
        id: 'business-fixture-maison',
        author: story.author,
        authorId: 'business-recipient',
        text: 'Welcome! How can we help you today?',
        time: now.subtract(const Duration(hours: 5)),
        isMine: false,
        status: DeliveryStatus.delivered,
      ),
    );
    final room = BusinessRoom(
      story: story,
      expiresAt: now.subtract(const Duration(hours: 1)),
      openingCount: 1,
      messages: chat.messages,
    );
    _rooms[story.id] = room;
    _bindRoom(room, chat);
  }

  void _bindRoom(BusinessRoom room, ChatConversation chat) {
    chats?.setSendGuard(
      chat.id,
      () => isActive(room) && !isBlocked(room.story),
    );
    chats?.setSendIdentity(
      chat.id,
      () => perspective == BusinessPerspective.customer
          ? ('business-customer', 'Alex Morgan')
          : ('business-recipient', room.story.author),
    );
  }

  BusinessRoom _newRoom(Story story) {
    final chat = chats?.ensureBusinessConversation(story.id, story.author);
    final room = BusinessRoom(
      story: story,
      expiresAt: now.add(config.roomDuration),
      openingCount: 1,
      messages: chat?.messages,
    );
    if (chat != null) _bindRoom(room, chat);
    _rooms[story.id] = room;
    return room;
  }

  void _changed() {
    if (chats == null) {
      notifyListeners();
    } else {
      chats!.refreshConversations();
    }
  }

  bool _sameContent(Story source, Story candidate) =>
      source.id == candidate.id &&
      source.title == candidate.title &&
      source.category == candidate.category &&
      source.media == candidate.media &&
      source.sponsored == candidate.sponsored &&
      source.boosted == candidate.boosted &&
      source.assetPath == candidate.assetPath &&
      source.sampleLabel == candidate.sampleLabel &&
      source.rotation == candidate.rotation &&
      source.cropScale == candidate.cropScale &&
      source.trimStart == candidate.trimStart &&
      source.trimEnd == candidate.trimEnd &&
      source.coverLabel == candidate.coverLabel &&
      listEquals(source.colors, candidate.colors);

  bool _sameStory(Story source, Story candidate) =>
      _sameContent(source, candidate) &&
      source.kind == candidate.kind &&
      source.author == candidate.author;

  bool sourceEligible(Story story) {
    if (_unavailableStories.contains(story.id)) return false;
    final inventory = stories?.allStories ?? StoriesController.stories;
    final source = inventory.where((item) => item.id == story.id).firstOrNull;
    if (source == null || !_sameContent(source, story)) return false;
    if (source.kind == StoryKind.business) return _sameStory(source, story);

    // A promoted personal publication may be linked explicitly to the
    // owner's public Business profile. Only its public identity is valid.
    final profile = settings?.businessProfile;
    return source.kind == StoryKind.own &&
        (story.kind == StoryKind.own || story.kind == StoryKind.business) &&
        (source.boosted || source.sponsored) &&
        profile != null &&
        profile.isComplete &&
        settings!.businessStoryIds.contains(source.id) &&
        story.author == profile.name;
  }

  bool isActive(BusinessRoom room) => room.isActiveAt(now);

  /// Whether the current perspective may perform a room interaction.
  /// Local history actions such as starring or deleting for oneself remain
  /// available when the room is read-only.
  bool canInteract(BusinessRoom room) {
    if (!isActive(room) ||
        isBlocked(room.story) ||
        !(settings?.canMessage ?? true)) {
      return false;
    }
    final chat = chats?.businessConversation(room.story.id);
    return chats == null || (chat != null && chats!.canSendTo(chat));
  }

  bool isBlocked(Story story) =>
      settings?.isBusinessBlocked(story.author) ??
      (_blockedBusinesses.contains(story.author) ||
          (chats?.conversations.any(
                (chat) =>
                    chat.kind == ChatKind.business &&
                    chat.name == story.author &&
                    chat.blocked,
              ) ??
              false));

  void setBlocked(Story story, bool blocked) {
    if (settings != null) {
      settings!.setBusinessBlocked(story.author, blocked);
      return;
    }
    if (blocked) {
      _blockedBusinesses.add(story.author);
    } else {
      _blockedBusinesses.remove(story.author);
    }
    for (final chat
        in chats?.conversations.where(
              (chat) =>
                  chat.kind == ChatKind.business && chat.name == story.author,
            ) ??
            <ChatConversation>[]) {
      if (chat.blocked != blocked) chats!.toggleBlocked(chat);
    }
    notifyListeners();
  }

  void setSourceEligible(String storyId, bool eligible) {
    if (stories != null) {
      stories!.setAvailability(
        storyId,
        eligible ? StoryAvailability.active : StoryAvailability.expired,
      );
      return;
    }
    if (eligible) {
      _unavailableStories.remove(storyId);
    } else {
      _unavailableStories.add(storyId);
    }
    notifyListeners();
  }

  void setPerspective(BusinessPerspective value) {
    if (perspective == value) return;
    perspective = value;
    notifyListeners();
  }

  void advance(Duration duration) {
    if (duration.isNegative) throw ArgumentError.value(duration, 'duration');
    _offset += duration;
    notifyListeners();
  }

  OpenRoomResult openRoom(Story story, {bool confirmed = false}) {
    if (_openingRooms.contains(story.id)) return OpenRoomResult.inProgress;
    if (isBlocked(story)) return OpenRoomResult.blocked;
    final room = roomFor(story.id);
    if (room != null && isActive(room)) {
      return _sameStory(room.story, story)
          ? OpenRoomResult.alreadyActive
          : OpenRoomResult.sourceUnavailable;
    }
    if (perspective == BusinessPerspective.recipient) {
      return OpenRoomResult.recipientCannotOpen;
    }
    if (!sourceEligible(story)) return OpenRoomResult.sourceUnavailable;
    if ((room?.openingCount ?? 0) >= config.maxOpenings) {
      return OpenRoomResult.limitReached;
    }
    if (!confirmed) return OpenRoomResult.confirmationRequired;
    _openingRooms.add(story.id);
    try {
      final opening = (room?.openingCount ?? 0) + 1;
      final spent = wallet.spendCredits(
        id: wallet.newId('business-room-${story.id}'),
        amount: config.roomCredits,
        description: BusinessCopy.roomCharge(story.author),
      );
      if (!spent) return OpenRoomResult.insufficientCredits;
      if (room == null) {
        _newRoom(story);
      } else {
        room.expiresAt = now.add(config.roomDuration);
        room.openingCount = opening;
      }
      _changed();
      return OpenRoomResult.opened;
    } finally {
      _openingRooms.remove(story.id);
    }
  }

  /// Seeds an incoming customer room for the recipient demo, without a local debit.
  BusinessRoom seedRecipientRoom(Story story) {
    if ((stories != null && !sourceEligible(story)) ||
        (stories == null && story.kind != StoryKind.business)) {
      throw ArgumentError(BusinessCopy.storyRequired);
    }
    final room = _rooms[story.id] ?? _newRoom(story);
    if (!isActive(room)) room.expiresAt = now.add(config.roomDuration);
    _changed();
    return room;
  }

  bool send(
    String storyId,
    String text, {
    MessageKind kind = MessageKind.text,
    String? quote,
    ChatMessage? reply,
    bool upload = false,
    String? assetPath,
    ChatMediaEdits? mediaEdits,
    ChatFileMetadata? fileMetadata,
  }) {
    final room = roomFor(storyId);
    final body = text.trim();
    final chat = chats?.businessConversation(storyId);
    if (room == null || !canInteract(room) || body.isEmpty) {
      return false;
    }
    if (chat != null) {
      return chats!.send(
            chat,
            body,
            reply: reply,
            kind: kind,
            upload: upload,
            assetPath: assetPath,
            mediaEdits: mediaEdits,
            fileMetadata: fileMetadata,
          ) !=
          null;
    }
    room.messages.add(
      ChatMessage(
        id: 'business-message-${++_messageSequence}',
        author: perspective == BusinessPerspective.customer
            ? 'Alex Morgan'
            : room.story.author,
        authorId: perspective == BusinessPerspective.customer
            ? 'business-customer'
            : 'business-recipient',
        text: body,
        time: now,
        isMine: true,
        kind: kind,
        assetPath: assetPath ?? ChatMediaSamples.assetFor(kind, body),
        mediaEdits: mediaEdits,
        fileMetadata:
            fileMetadata ??
            (kind == MessageKind.document
                ? ChatFileMetadata.sample(body)
                : null),
        quote: reply == null
            ? quote
            : BusinessCopy.replyQuote(reply.author, reply.text),
        status: DeliveryStatus.sent,
      ),
    );
    _changed();
    return true;
  }

  bool isOwnMessage(BusinessRoom room, ChatMessage message) {
    final authorId = message.authorId;
    if (authorId != null) {
      return authorId ==
          (perspective == BusinessPerspective.customer
              ? 'business-customer'
              : 'business-recipient');
    }
    return message.author ==
        (perspective == BusinessPerspective.customer
            ? 'Alex Morgan'
            : room.story.author);
  }

  bool editMessage(String storyId, ChatMessage message, String text) {
    final room = roomFor(storyId);
    final body = text.trim();
    if (room == null ||
        !canInteract(room) ||
        !room.messages.contains(message) ||
        !isOwnMessage(room, message) ||
        message.deleted ||
        body.isEmpty) {
      return false;
    }
    message.text = body;
    _changed();
    return true;
  }

  void removeMessage(
    String storyId,
    ChatMessage message, {
    bool forEveryone = false,
  }) {
    final room = roomFor(storyId);
    if (room == null || !room.messages.contains(message)) return;
    if (forEveryone) {
      if (!canInteract(room) ||
          !isOwnMessage(room, message) ||
          message.deleted) {
        return;
      }
      message.deleted = true;
      message.text = BusinessCopy.messageDeleted;
      message.reaction = null;
      message.starred = false;
      message.pinned = false;
    } else {
      room.messages.remove(message);
    }
    _changed();
  }

  void react(String storyId, ChatMessage message, String reaction) {
    final room = roomFor(storyId);
    if (room == null ||
        !canInteract(room) ||
        !room.messages.contains(message) ||
        message.deleted) {
      return;
    }
    message.reaction = message.reaction == reaction ? null : reaction;
    _changed();
  }

  void toggleStar(String storyId, ChatMessage message) {
    final room = roomFor(storyId);
    if (room == null || !room.messages.contains(message) || message.deleted) {
      return;
    }
    message.starred = !message.starred;
    _changed();
  }

  void togglePin(String storyId, ChatMessage message) {
    final room = roomFor(storyId);
    if (room == null || !room.messages.contains(message) || message.deleted) {
      return;
    }
    message.pinned = !message.pinned;
    _changed();
  }

  void reset() {
    chats?.removeBusinessConversations();
    _rooms.clear();
    _drafts.clear();
    _unavailableStories.clear();
    _blockedBusinesses.clear();
    _offset = Duration.zero;
    _messageSequence = 0;
    perspective = BusinessPerspective.customer;
    _seedHistory();
    _changed();
  }

  @override
  void dispose() {
    stories?.removeListener(_storyChanged);
    chats?.removeListener(_chatChanged);
    settings?.removeListener(_settingsChanged);
    super.dispose();
  }
}
