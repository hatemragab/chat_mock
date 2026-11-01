import 'package:flutter/material.dart';

import '../../../shared/copy/common_copy.dart';
import '../copy/prototype_tools_copy.dart';

import 'review_chat_missing.dart';
import 'review_commerce_missing.dart';
import 'review_onboarding_missing.dart';

import 'package:flutter/services.dart';

import '../../business/controllers/business_controller.dart';
import '../../business/models/business_room.dart';
import '../../business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import '../../business/ui/screens/business_info_screen/business_info_screen.dart';
import '../../business/ui/screens/business_profile_screen/business_profile_screen.dart';
import '../../business/ui/sheets/business_contact_sheet/business_contact_sheet.dart';
import '../../business/ui/sheets/business_call_preflight_sheet/business_call_preflight_sheet.dart';
import '../../business/ui/dialogs/open_business_room_dialog/open_business_room_dialog.dart';
import '../../business/ui/dialogs/business_room_unavailable_dialog/business_room_unavailable_dialog.dart';
import '../../calls/controllers/calls_controller.dart';
import '../../calls/models/call_session.dart';
import '../../calls/ui/screens/call_details_screen/call_details_screen.dart';
import '../../calls/ui/screens/call_screen/call_screen.dart';
import '../../calls/ui/screens/call_summary_screen/call_summary_screen.dart';
import '../../calls/ui/sheets/audio_output_sheet/audio_output_sheet.dart';
import '../../calls/ui/screens/calls_screen/calls_screen.dart';
import '../../calls/ui/dialogs/delete_call_dialog/delete_call_dialog.dart';
import '../../calls/ui/dialogs/low_call_balance_dialog/low_call_balance_dialog.dart';
import '../../chats/controllers/chats_controller.dart';
import '../../chats/models/chat_models.dart';
import '../../chats/ui/screens/archived_chats_screen/archived_chats_screen.dart';
import '../../chats/ui/screens/attachment_preview_screen/attachment_preview_screen.dart';
import '../../chats/ui/screens/chat_info_screen/chat_info_screen.dart';
import '../../chats/ui/screens/chat_search_screen/chat_search_screen.dart';
import '../../chats/ui/screens/chats_screen/chats_screen.dart';
import '../../chats/ui/screens/conversation_screen/conversation_screen.dart';
import '../../chats/ui/screens/edit_contact_screen/edit_contact_screen.dart';
import '../../chats/ui/screens/media_viewer_screen/media_viewer_screen.dart';
import '../../chats/ui/screens/message_details_screen/message_details_screen.dart';
import '../../chats/ui/screens/recipient_picker_screen/recipient_picker_screen.dart';
import '../../chats/ui/screens/shared_media_screen/shared_media_screen.dart';
import '../../chats/ui/screens/starred_messages_screen/starred_messages_screen.dart';
import '../../chats/ui/sheets/attachment_sheet/attachment_sheet.dart';
import '../../chats/ui/sheets/chat_actions_sheet/chat_actions_sheet.dart';
import '../../chats/ui/sheets/message_actions_sheet/message_actions_sheet.dart';
import '../../chats/ui/sheets/mute_duration_sheet/mute_duration_sheet.dart';
import '../../chats/ui/sheets/reaction_picker_sheet/reaction_picker_sheet.dart';
import '../../chats/ui/dialogs/delete_conversation_dialog/delete_conversation_dialog.dart';
import '../../chats/ui/dialogs/clear_conversation_dialog/clear_conversation_dialog.dart';
import '../../chats/ui/dialogs/delete_contact_dialog/delete_contact_dialog.dart';
import '../../chats/ui/dialogs/delete_message_dialog/delete_message_dialog.dart';
import '../../discover/ui/screens/discover_screen/discover_screen.dart';
import '../../discover/controllers/discover_controller.dart';
import '../../discover/ui/screens/discover_search_screen/discover_search_screen.dart';
import '../../creator_tools/ui/screens/promotion_contact_activity_screen/promotion_contact_activity_screen.dart';
import '../../groups/controllers/group_controller.dart';
import '../../groups/controllers/group_directory.dart';
import '../../groups/models/group_member.dart';
import '../../groups/ui/screens/group_details_screen/group_details_screen.dart';
import '../../groups/ui/screens/add_group_members_screen/add_group_members_screen.dart';
import '../../groups/ui/screens/group_info_screen/group_info_screen.dart';
import '../../groups/ui/screens/group_members_screen/group_members_screen.dart';
import '../../groups/ui/screens/group_permissions_screen/group_permissions_screen.dart';
import '../../groups/ui/screens/group_screen/group_screen.dart';
import '../../groups/ui/sheets/group_member_actions_sheet/group_member_actions_sheet.dart';
import '../../groups/ui/dialogs/leave_group_dialog/leave_group_dialog.dart';
import '../../groups/ui/dialogs/group_member_action_dialog/group_member_action_dialog.dart';
import '../../onboarding/ui/screens/legal_screen/legal_screen.dart';
import '../../onboarding/controllers/onboarding_controller.dart';
import '../../onboarding/ui/screens/welcome_screen/welcome_screen.dart';
import '../../onboarding/ui/screens/complete_profile_screen/complete_profile_screen.dart';
import '../../onboarding/ui/screens/interests_screen/interests_screen.dart';
import '../../onboarding/ui/screens/contacts_access_screen/contacts_access_screen.dart';
import '../../onboarding/ui/screens/profile_photo_capture_screen/profile_photo_capture_screen.dart';
import '../../onboarding/ui/sheets/photo_source_sheet/photo_source_sheet.dart';
import '../../onboarding/ui/sheets/profile_photo_library_sheet/profile_photo_library_sheet.dart';
import '../../profile/ui/screens/edit_profile_screen/edit_profile_screen.dart';
import '../../profile/ui/screens/profile_screen/profile_screen.dart';
import '../../publishing/controllers/publishing_controller.dart';
import '../../publishing/models/publication.dart';
import '../../publishing/ui/screens/category_screen/category_screen.dart';
import '../../publishing/ui/screens/analytics_screen/analytics_screen.dart';
import '../../publishing/ui/screens/publication_details_screen/publication_details_screen.dart';
import '../../publishing/ui/screens/publications_screen/publications_screen.dart';
import '../../publishing/ui/screens/publishing_screen/publishing_screen.dart';
import '../../publishing/ui/screens/media_screen/media_screen.dart';
import '../../publishing/ui/screens/capture_screen/capture_screen.dart';
import '../../publishing/ui/screens/editor_screen/editor_screen.dart';
import '../../publishing/ui/screens/audio_recorder_screen/audio_recorder_screen.dart';
import '../../publishing/ui/screens/audience_screen/audience_screen.dart';
import '../../publishing/ui/screens/price_review_screen/price_review_screen.dart';
import '../../publishing/ui/screens/target_area_screen/target_area_screen.dart';
import '../../publishing/ui/screens/story_viewers_screen/story_viewers_screen.dart';
import '../../publishing/ui/dialogs/delete_publication_dialog/delete_publication_dialog.dart';
import '../../publishing/ui/dialogs/photo_slot_limit_dialog/photo_slot_limit_dialog.dart';
import '../../publishing/ui/sheets/boost_options_sheet/boost_options_sheet.dart';
import '../../publishing/ui/sheets/target_area_sheet/target_area_sheet.dart';
import '../../publishing/ui/actions/publication_actions.dart';
import '../../stories/controllers/stories_controller.dart';
import '../../stories/models/story.dart';
import '../../stories/ui/screens/status_screen/status_screen.dart';
import '../../stories/ui/screens/story_viewer_screen/story_viewer_screen.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/models/settings_models.dart';
import '../../settings/ui/screens/account_screen/account_screen.dart';
import '../../settings/ui/screens/appearance_screen/appearance_screen.dart';
import '../../settings/ui/screens/blocked_accounts_screen/blocked_accounts_screen.dart';
import '../../settings/ui/screens/delete_account_screen/delete_account_screen.dart';
import '../../settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import '../../settings/ui/screens/notifications_screen/notifications_screen.dart';
import '../../settings/ui/screens/permissions_screen/permissions_screen.dart';
import '../../settings/ui/screens/privacy_screen/privacy_screen.dart';
import '../../settings/ui/screens/settings_screen/settings_screen.dart';
import '../../settings/ui/screens/status_audience_screen/status_audience_screen.dart';
import '../../settings/ui/dialogs/sign_out_dialog/sign_out_dialog.dart';
import '../../settings/ui/dialogs/permission_recovery_dialog/permission_recovery_dialog.dart';
import '../../settings/ui/sheets/photo_visibility_sheet/photo_visibility_sheet.dart';
import '../../support/ui/screens/about_screen/about_screen.dart';
import '../../support/ui/screens/help_screen/help_screen.dart';
import '../../support/ui/screens/help_article_screen/help_article_screen.dart';
import '../../safety/ui/screens/report_screen/report_screen.dart';
import '../../safety/ui/screens/restriction_screen/restriction_screen.dart';
import '../../safety/ui/dialogs/account_block_dialog/account_block_dialog.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/ui/screens/balance_activity_screen/balance_activity_screen.dart';
import '../../wallet/ui/screens/buy_credits_screen/buy_credits_screen.dart';
import '../../wallet/ui/screens/convert_diamonds_screen/convert_diamonds_screen.dart';
import '../../wallet/ui/screens/wallet_screen/wallet_screen.dart';
import '../../wallet/ui/screens/withdrawal_form_screen/withdrawal_form_screen.dart';
import '../../wallet/ui/screens/withdrawal_history_screen/withdrawal_history_screen.dart';
import '../../wallet/ui/screens/transaction_details_screen/transaction_details_screen.dart';
import '../../wallet/ui/screens/payment_review_screen/payment_review_screen.dart';
import '../../wallet/ui/screens/payment_status_screen/payment_status_screen.dart';
import '../../wallet/ui/screens/withdrawal_review_screen/withdrawal_review_screen.dart';
import '../../wallet/ui/screens/withdrawal_details_screen/withdrawal_details_screen.dart';
import '../../wallet/ui/sheets/conversion_review_sheet/conversion_review_sheet.dart';
import '../../wallet/ui/sheets/insufficient_credits_sheet/insufficient_credits_sheet.dart';
import '../../wallet/ui/sheets/payment_method_sheet/payment_method_sheet.dart';
import '../../wallet/ui/sheets/payout_method_sheet/payout_method_sheet.dart';
import '../../wallet/ui/dialogs/cancel_payment_dialog/cancel_payment_dialog.dart';
import '../ui/screens/review_minimized_call_screen/review_minimized_call_screen.dart';

/// Opens real feature widgets with the current in-memory session and fixtures.
class ReviewActions {
  const ReviewActions({
    required this.chats,
    this.discover,
    required this.calls,
    required this.group,
    this.groups,
    required this.business,
    required this.publishing,
    required this.stories,
    required this.wallet,
    this.settings,
    this.profile,
    this.onProfileUpdated,
    this.onThemeChanged,
    this.themeMode = ThemeMode.system,
    this.onSignOut,
  });
  final ChatsController chats;
  final DiscoverController? discover;
  final CallsController calls;
  final GroupController group;
  final GroupDirectory? groups;
  final BusinessController business;
  final PublishingController publishing;
  final StoriesController stories;
  final WalletController wallet;
  final SettingsController? settings;
  final OnboardingController? profile;
  final VoidCallback? onProfileUpdated;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ThemeMode themeMode;
  final VoidCallback? onSignOut;

  static const _supported = <String>{
    'P01',
    'P02',
    'P03',
    'P04',
    'P05',
    'P06',
    'P07',
    'P08',
    'P09',
    'P10',
    'P11',
    'P12',
    'P13',
    'P14',
    'P15',
    'P16',
    'P17',
    'P18',
    'P19',
    'P20',
    'P21',
    'P22',
    'P23',
    'P24',
    'P25',
    'P26',
    'P27',
    'P28',
    'P29',
    'P30',
    'P31',
    'P32',
    'P33',
    'P34',
    'P35',
    'P36',
    'P37',
    'P38',
    'P39',
    'P40',
    'P41',
    'P42',
    'P43',
    'P44',
    'P45',
    'P46',
    'P47',
    'P48',
    'P49',
    'P50',
    'P51',
    'P52',
    'P53',
    'P54',
    'P55',
    'P56',
    'P57',
    'P58',
    'P59',
    'P60',
    'P61',
    'P62',
    'P63',
    'P64',
    'P65',
    'P66',
    'P67',
    'P68',
    'P69',
    'P70',
    'P71',
    'P72',
    'P73',
    'P74',
    'P75',
    'P76',
    'P77',
    'P78',
    'P79',
    'P80',
    'S02',
    'S03',
    'S04',
    'S05',
    'S06',
    'S07',
    'S08',
    'S09',
    'S10',
    'S11',
    'S12',
    'S13',
    'S14',
    'S15',
    'S16',
    'S17',
    'S18',
    'S19',
    'S20',
    'S21',
    'D02',
    'D03',
    'D04',
    'D05',
    'D06',
    'D07',
    'D08',
    'D09',
    'D10',
    'D13',
    'D15',
    'D16',
    'D17',
    'D11',
    'D12',
    'D18',
    'D19',
    'D21',
    'D22',
    'D23',
    'V001',
    'V002',
    'V003',
    'V004',
    'V005',
    'V006',
    'V010',
    'V013',
    'V014',
    'V015',
    'V016',
    'V017',
    'V018',
    'V019',
    'V020',
    'V021',
    'V024',
    'V025',
    'V027',
    'V028',
    'V029',
    'V030',
    'V031',
    'V032',
    'V033',
    'V034',
    'V035',
    'V037',
    'V038',
    'V041',
    'V042',
    'V043',
    'V044',
    'V045',
    'V046',
    'V047',
    'V048',
    'V049',
    'V050',
    'V051',
    'V052',
    'V053',
    'V054',
    'V055',
    'V056',
    'V057',
    'V058',
    'V059',
    'V060',
    'V061',
    'V062',
    'V063',
    'V064',
    'V065',
    'V066',
    'V067',
    'V068',
    'V069',
    'V070',
    'V071',
    'V072',
    'V073',
    'V074',
    'V076',
    'V077',
    'V078',
    'V082',
    'V084',
    'V085',
    'V086',
    'V087',
    'V088',
    'V089',
    'V090',
    'V091',
    'V092',
    'V093',
    'V094',
    'V095',
    'V096',
    'V097',
    'V098',
    'V099',
    'V100',
    'V101',
    'V102',
    'V103',
    'V104',
    'V105',
    'V106',
    'V107',
    'V109',
    'V111',
    'V114',
    'V115',
    'V116',
    'V117',
    'V118',
    'V119',
    'V120',
    'V121',
    'V122',
    'V123',
    'V124',
    'V125',
    'V128',
    'V129',
    'V130',
  };

  Publication? _publicationFor(String id) {
    bool promoted(Publication p) =>
        p.boosted || p.type == PublicationType.advertisement;
    final matches = publishing.publications.where(
      (p) => switch (id) {
        'P50' => true,
        'D13' || 'V082' => p.status == PublicationStatus.active,
        'P51' => !promoted(p),
        'P52' => promoted(p),
        'P53' =>
          promoted(p) &&
              publishing.contactActivity != null &&
              (publishing.contactActivity!.roomFor(p) != null ||
                  publishing.contactActivity!.callsFor(p).isNotEmpty),
        'V091' => !promoted(p) && p.contactViewers.isEmpty,
        'V092' => !promoted(p) && p.contactViewers.isNotEmpty,
        'V093' =>
          promoted(p) && p.qualifiedViews < publishing.config.popularThreshold,
        'V094' =>
          promoted(p) && p.qualifiedViews >= publishing.config.popularThreshold,
        'V095' => promoted(p) && p.heldViews > 0,
        _ => false,
      },
    );
    return matches.firstOrNull;
  }

  ChatConversation? _chat(String id) =>
      chats.conversations.where((chat) => chat.id == id).firstOrNull;

  ChatMessage? _reviewMessage() =>
      _chat('sarah')?.messages
          .where((message) => message.isMine && !message.deleted)
          .firstOrNull;

  ChatMessage? _message(MessageKind kind) => chats.conversations
      .expand((chat) => chat.messages)
      .where((message) => message.kind == kind && !message.deleted)
      .firstOrNull;

  (ChatConversation, ChatMessage)? _messageScenario(String id) {
    for (final chat in chats.conversations) {
      if (chat.kind != ChatKind.contact || chat.hidden) continue;
      for (final message in chat.messages) {
        if (message.deleted) continue;
        final matches = switch (id) {
          'V014' => message.isMine && message.status == DeliveryStatus.sending,
          'V015' => message.isMine && message.status == DeliveryStatus.sent,
          'V016' =>
            message.isMine && message.status == DeliveryStatus.delivered,
          'V017' => message.isMine && message.status == DeliveryStatus.read,
          'V019' => message.isMine && message.status == DeliveryStatus.failed,
          'V025' =>
            message.uploadState == UploadState.uploading ||
                message.uploadState == UploadState.failed,
          'V028' =>
            message.kind == MessageKind.document &&
                !RegExp(
                  r'\.(pdf|txt)$',
                  caseSensitive: false,
                ).hasMatch(message.text),
          _ => false,
        };
        if (matches) return (chat, message);
      }
    }
    return null;
  }

  bool _storyVisible(Story story) =>
      (story.kind != StoryKind.business || !business.isBlocked(story)) &&
      (story.kind != StoryKind.contact ||
          !chats.conversations.any(
            (chat) =>
                chat.kind == ChatKind.contact &&
                chat.id == story.id &&
                chat.blocked,
          ));

  Story? _storyForScenario(String id) {
    final active = stories.allStories.where(_storyVisible);
    final playable = active.where((story) => !stories.mediaFailed(story.id));
    return switch (id) {
      'V056' =>
        playable.where((story) => story.kind == StoryKind.contact).firstOrNull,
      'V057' =>
        playable.where((story) => story.kind == StoryKind.business).firstOrNull,
      'V058' =>
        playable.where((story) => story.kind == StoryKind.own).firstOrNull,
      'V059' =>
        playable.where((story) => story.media == StoryMedia.photo).firstOrNull,
      'V060' =>
        playable.where((story) => story.media == StoryMedia.video).firstOrNull,
      'V061' =>
        playable.where((story) => story.media == StoryMedia.audio).firstOrNull,
      'V063' => playable.firstOrNull,
      'V064' =>
        playable.where((story) => story.media != StoryMedia.photo).firstOrNull,
      'V065' =>
        StoriesController.stories
            .where(
              (story) =>
                  stories.availability(story.id) == StoryAvailability.expired,
            )
            .firstOrNull,
      'V066' =>
        StoriesController.stories
            .where(
              (story) =>
                  stories.availability(story.id) == StoryAvailability.removed,
            )
            .firstOrNull,
      'V067' =>
        active.where((story) => stories.mediaFailed(story.id)).firstOrNull,
      _ => null,
    };
  }

  BalanceKind? _emptyBalanceKind() => BalanceKind.values
      .where(
        (kind) => !wallet.activity.any((activity) => activity.kind == kind),
      )
      .firstOrNull;

  String? _emptyDiscoverCategory() {
    final promoted = stories.allStories.where(
      (story) =>
          _storyVisible(story) &&
          (story.boosted || story.sponsored || story.popular),
    );
    return const ['Design', 'Food & drink', 'Shopping', 'Lifestyle']
        .where(
          (category) => !promoted.any((story) => story.category == category),
        )
        .firstOrNull;
  }

  String? _recoverablePermission() => settings?.permissions.entries
      .where((entry) => entry.value == MockPermission.permanentlyDenied)
      .map((entry) => entry.key)
      .firstOrNull;

  GroupMember? _memberForDialog(String id) {
    if ((id == 'D08' || id == 'D09' || id == 'D10') && !group.isOwner) {
      return null;
    }
    if (id == 'D07' && !group.canManage) return null;
    return group.activeMembers.where((member) {
      if (member.id == group.perspectiveId || member.role == GroupRole.owner) {
        return false;
      }
      return switch (id) {
        'D07' => group.isOwner || member.role != GroupRole.admin,
        'D08' => member.role == GroupRole.member,
        'D09' => member.role == GroupRole.admin,
        'D10' => true,
        _ => false,
      };
    }).firstOrNull;
  }

  ChatMessage? _groupReceiptFor(String id) =>
      group.conversation.messages.where((message) {
        if (!group.isOwnMessage(message) || message.recipients.isEmpty) {
          return false;
        }
        final allRead = message.recipients.every(
          (receipt) => receipt.status == RecipientDeliveryStatus.read,
        );
        final someRead = message.recipients.any(
          (receipt) => receipt.status == RecipientDeliveryStatus.read,
        );
        return id == 'V042' ? allRead : someRead && !allRead;
      }).firstOrNull;

  WalletPayment? _paymentFor(String id) {
    final status = switch (id) {
      'V097' => PaymentStatus.processing,
      'V098' => PaymentStatus.pending,
      'V099' => PaymentStatus.failed,
      'V100' => PaymentStatus.cancelled,
      'V101' => PaymentStatus.confirmed,
      'V104' => PaymentStatus.confirmed,
      _ => null,
    };
    return wallet.payments
        .where((payment) => status == null || payment.status == status)
        .lastOrNull;
  }

  WalletPayment? _cancellablePayment() => wallet.payments
      .where(
        (payment) =>
            payment.status != PaymentStatus.confirmed &&
            payment.status != PaymentStatus.cancelled,
      )
      .lastOrNull;

  WalletActivity? _conversionActivity() => wallet.activity
      .where(
        (activity) =>
            activity.kind == BalanceKind.cash &&
            activity.purpose == WalletActivityPurpose.conversionCredit,
      )
      .firstOrNull;

  WalletWithdrawal? _withdrawalFor(String id) {
    final status = switch (id) {
      'V114' => WithdrawalStatus.pending,
      'V115' => WithdrawalStatus.inProgress,
      'V116' => WithdrawalStatus.approved,
      'V117' => WithdrawalStatus.rejected,
      'V118' => WithdrawalStatus.paid,
      'V119' => WithdrawalStatus.failed,
      _ => null,
    };
    return wallet.withdrawals
        .where((withdrawal) => status == null || withdrawal.status == status)
        .firstOrNull;
  }

  CallSession? _callFor(String id) {
    final phase = switch (id) {
      'V047' => CallPhase.busy,
      'V048' => CallPhase.declined,
      'V049' => CallPhase.missed,
      _ => null,
    };
    return calls.history
        .where(
          (call) => id == 'V054'
              ? call.endCause == CallEndCause.insufficientNextBlock
              : phase == null || call.phase == phase,
        )
        .firstOrNull;
  }

  bool canOpen(String id) {
    if (canOpenChatMissing(this, id)) return true;
    if (canOpenOnboardingMissing(this, id)) return true;
    if (canOpenCommerceMissing(this, id)) return true;
    if (!_supported.contains(id)) return false;
    if (id == 'P34' && _storyForScenario('V063') == null) return false;
    if (const {'S02', 'S06', 'D03', 'D04', 'D05'}.contains(id)) {
      final chat = _chat('sarah');
      return chat != null && !chat.hidden;
    }
    if (id == 'S03' || id == 'D02') {
      final chat = _chat('sarah');
      return chat != null && !chat.hidden && _reviewMessage() != null;
    }
    if (id == 'V020' || id == 'V021') {
      final chat = _chat('sarah');
      return chat != null &&
          !chat.hidden &&
          chats.canSendTo(chat) &&
          _reviewMessage() != null;
    }
    if (id == 'S07') {
      final chat = _chat('sarah');
      return chat != null &&
          !chat.hidden &&
          chats.canSendTo(chat) &&
          chat.messages.any((message) => !message.deleted);
    }
    if (id == 'D06') return group.perspective.active;
    if (const {'D07', 'D08', 'D09', 'D10'}.contains(id)) {
      return _memberForDialog(id) != null;
    }
    if (const {
      'V014',
      'V015',
      'V016',
      'V017',
      'V019',
      'V025',
      'V028',
    }.contains(id)) {
      return _messageScenario(id) != null;
    }
    if (const {
      'V056',
      'V057',
      'V058',
      'V059',
      'V060',
      'V061',
      'V063',
      'V064',
      'V065',
      'V066',
      'V067',
    }.contains(id)) {
      return _storyForScenario(id) != null;
    }
    if (id == 'V024') return _chat('sarah')?.blocked ?? false;
    if (id == 'V027') {
      return !chats.conversations.any((chat) => chat.archived && !chat.hidden);
    }
    if (id == 'V032') {
      return group.onlyAdminsCanSend &&
          group.perspective.active &&
          !group.isManager;
    }
    if (id == 'V034') return group.removed;
    if (id == 'V035') return group.left;
    if (id == 'V037') {
      return group.isOwner &&
          group.activeMembers.any((member) => member.id != group.perspectiveId);
    }
    if (id == 'V038') {
      return !group.canManage &&
          group.activeMembers.any((member) => member.id != group.perspectiveId);
    }
    if (id == 'V043') {
      return group.canManage &&
          group.activeMembers.any((member) => member.id != group.perspectiveId);
    }
    if (id == 'V062') {
      return stories.allStories.any(
        (story) =>
            _storyVisible(story) &&
            story.kind == StoryKind.contact &&
            stories.isSeen(story.id),
      );
    }
    if (id == 'V068') {
      return !stories.allStories.any(
        (story) => _storyVisible(story) && story.kind == StoryKind.contact,
      );
    }
    if (id == 'V069') {
      if (discover != null && discover!.state != DiscoverLoadState.ready) {
        return false;
      }
      return !stories.allStories.any(
        (story) =>
            _storyVisible(story) &&
            (story.boosted || story.sponsored || story.popular),
      );
    }
    if (id == 'V070') {
      return (discover == null || discover!.state == DiscoverLoadState.ready) &&
          _emptyDiscoverCategory() != null;
    }
    if (id == 'V074') return publishing.availablePhotoSlots > 0;
    if (id == 'V078') {
      return wallet.credits <
          publishing.config.categoryFee +
              publishing.config.boostFee +
              publishing.config.advertisementFee;
    }
    if (id == 'D13' || id == 'V082') return _publicationFor(id) != null;
    if (id == 'D11') return calls.history.isNotEmpty;
    if (id == 'D12') return calls.active != null && calls.lowBalance;
    if (id == 'D18') return _cancellablePayment() != null;
    if (id == 'D19') return onSignOut != null;
    if (id == 'D21') return _chat('sarah') != null && !_chat('sarah')!.blocked;
    if (id == 'D22') return _chat('sarah')?.blocked ?? false;
    if (id == 'D23') return _recoverablePermission() != null;
    if (id == 'S21') return settings != null;
    if (id == 'S05') return profile != null;
    if (id == 'S14') return publishing.publications.isNotEmpty;
    if (id == 'D15') return publishing.availablePhotoSlots == 0;
    if (id == 'V096') return publishing.publications.isEmpty;
    if (id == 'V105') return _emptyBalanceKind() != null;
    if (id == 'V106') return wallet.pendingDiamonds > 0;
    if (id == 'V107') return wallet.frozenDiamonds > 0;
    if (id == 'V109') return _conversionActivity() != null;
    if (id == 'V111') return wallet.cash >= wallet.config.withdrawalMinimum;
    if (const {'V120', 'V121', 'V122'}.contains(id)) {
      return onThemeChanged != null;
    }
    if (id == 'V123') {
      return settings != null &&
          settings!.blockedAccounts.isEmpty &&
          settings!.blockedBusinessNames.isEmpty;
    }
    if (id == 'V124') {
      return settings != null &&
          profile != null &&
          onSignOut != null &&
          onThemeChanged != null &&
          !settings!.businessProfile.isComplete;
    }
    if (id == 'V125') {
      return settings?.permissions.values.contains(
            MockPermission.permanentlyDenied,
          ) ??
          false;
    }
    if (const {'D16', 'D17', 'V088', 'V089'}.contains(id)) {
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      final result = business.openRoom(story);
      return switch (id) {
        'D16' => result == OpenRoomResult.confirmationRequired,
        'D17' || 'V089' => result == OpenRoomResult.limitReached,
        _ =>
          result == OpenRoomResult.sourceUnavailable &&
              business.roomFor(story.id) != null &&
              !business.isActive(business.roomFor(story.id)!),
      };
    }
    if (const {'V086', 'V087', 'V090'}.contains(id)) {
      final room = business.roomFor('maison');
      final story = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      if (room == null || business.isBlocked(story)) return false;
      if ((id == 'V087' || id == 'V090') &&
          business.perspective != BusinessPerspective.customer) {
        return false;
      }
      final active = business.isActive(room);
      final eligible = business.sourceEligible(story);
      return switch (id) {
        'V086' => active && !eligible,
        'V087' =>
          !active &&
              eligible &&
              room.openingCount < business.config.maxOpenings,
        _ => active && eligible,
      };
    }
    if (id == 'S04' &&
        (_chat('sarah') == null || !chats.canSendTo(_chat('sarah')!))) {
      return false;
    }
    if (id == 'S09' &&
        calls.active?.phase != CallPhase.active &&
        calls.active?.phase != CallPhase.reconnecting) {
      return false;
    }
    if (id == 'S10' &&
        calls.active?.phase != CallPhase.active &&
        calls.active?.phase != CallPhase.reconnecting) {
      return false;
    }
    if (id == 'S11') {
      final source = StoriesController.stories.firstWhere(
        (story) => story.id == 'maison',
      );
      if (calls.active != null ||
          !business.sourceEligible(source) ||
          business.isBlocked(source)) {
        return false;
      }
    }
    if (id == 'S19' && wallet.diamonds < 10) return false;
    if (id == 'S20' && wallet.cash < wallet.config.withdrawalMinimum) {
      return false;
    }
    if (id == 'V033' &&
        (!group.canSend ||
            group.activeMembers
                .where((member) => member.id != group.perspectiveId)
                .isEmpty)) {
      return false;
    }
    if ((id == 'V001' || id == 'V003') && discover == null) return false;
    if (const {
          'P06',
          'P07',
          'P08',
          'P09',
          'V004',
          'V005',
          'V006',
          'V010',
          'V013',
        }.contains(id) &&
        profile == null) {
      return false;
    }
    if (const {
          'P65',
          'P66',
          'P67',
          'P68',
          'P69',
          'P70',
          'P72',
          'P73',
          'P74',
          'P78',
          'V128',
          'V129',
          'V130',
        }.contains(id) &&
        settings == null) {
      return false;
    }
    if (const {'P65', 'P67', 'P74'}.contains(id) && profile == null) {
      return false;
    }
    if (id == 'P05' &&
        (settings == null ||
            profile == null ||
            onSignOut == null ||
            onThemeChanged == null)) {
      return false;
    }
    if (const {'P67', 'P74', 'P78'}.contains(id) && onSignOut == null) {
      return false;
    }
    if (const {'P67', 'P71'}.contains(id) && onThemeChanged == null) {
      return false;
    }
    if (const {'P14', 'P15', 'P16', 'P18', 'V018'}.contains(id) &&
        _chat('sarah') == null) {
      return false;
    }
    if (id == 'V018') {
      final chat = _chat('sarah')!;
      final alreadyQueued = chat.messages.any(
        (message) => message.status == DeliveryStatus.queued,
      );
      if (!alreadyQueued && !chats.canSendTo(chat)) return false;
    }
    if (id == 'P17' && _message(MessageKind.photo) == null) return false;
    if (id == 'P18' &&
        !_chat('sarah')!.messages
            .any((message) => message.isMine && !message.deleted)) {
      return false;
    }
    if (id == 'P22' && _message(MessageKind.document) == null) return false;
    if (id == 'P56' && wallet.activity.isEmpty) return false;
    if (id == 'P62' && wallet.cash < wallet.config.withdrawalMinimum) {
      return false;
    }
    if (const {
          'P59',
          'V097',
          'V098',
          'V099',
          'V100',
          'V101',
          'V104',
        }.contains(id) &&
        _paymentFor(id) == null) {
      return false;
    }
    if (const {
          'P64',
          'V114',
          'V115',
          'V116',
          'V117',
          'V118',
          'V119',
        }.contains(id) &&
        _withdrawalFor(id) == null) {
      return false;
    }
    if (const {'P28', 'P33', 'V047', 'V048', 'V049', 'V054'}.contains(id) &&
        _callFor(id) == null) {
      return false;
    }
    if (const {'V045', 'V046', 'V050', 'V051'}.contains(id) &&
        (calls.active != null || !calls.permissionGranted)) {
      return false;
    }
    if (const {'V045', 'V050', 'V055'}.contains(id)) {
      final contact = _chat('sarah');
      if (contact == null || !chats.canCommunicateWithContact(contact)) {
        return false;
      }
    }
    if (const {'V046', 'V051'}.contains(id)) {
      final source = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      if (business.isBlocked(source) || !business.sourceEligible(source)) {
        return false;
      }
    }
    if (id == 'V055' && (calls.active != null || calls.permissionGranted)) {
      return false;
    }
    if (id == 'P29' && calls.active?.phase != CallPhase.ringing) return false;
    if (id == 'P30' && calls.active?.phase != CallPhase.incoming) return false;
    if (id == 'P31' &&
        (calls.active?.phase != CallPhase.active ||
            calls.active?.kind != CallKind.audio)) {
      return false;
    }
    if (id == 'P32' &&
        (calls.active?.phase != CallPhase.active ||
            calls.active?.kind != CallKind.video)) {
      return false;
    }
    if (id == 'V052' &&
        (calls.active?.phase != CallPhase.active ||
            calls.active?.business != true)) {
      return false;
    }
    if (id == 'V053' &&
        calls.active?.phase != CallPhase.active &&
        calls.active?.phase != CallPhase.reconnecting) {
      return false;
    }
    if (const {
      'P50',
      'P51',
      'P52',
      'P53',
      'V091',
      'V092',
      'V093',
      'V094',
      'V095',
    }.contains(id)) {
      return _publicationFor(id) != null;
    }
    if (id == 'V041' || id == 'V042') return _groupReceiptFor(id) != null;
    if (id == 'S08') {
      return group.activeMembers.any((m) => m.id != group.perspectiveId);
    }
    if (id == 'V084') {
      final room = business.roomFor('maison');
      return room != null &&
          business.isActive(room) &&
          !business.isBlocked(room.story);
    }
    if (id == 'V085') {
      final room = business.roomFor('maison');
      final source = StoriesController.stories.firstWhere(
        (item) => item.id == 'maison',
      );
      if (business.isBlocked(source)) return false;
      return room == null
          ? business.sourceEligible(source)
          : business.isActive(room);
    }
    if (id == 'P47') return business.roomFor('maison') != null;
    if (id == 'V029' || id == 'V030' || id == 'V031') {
      final role = switch (id) {
        'V029' => GroupRole.owner,
        'V030' => GroupRole.admin,
        _ => GroupRole.member,
      };
      return group.activeMembers.any((member) => member.role == role);
    }
    return true;
  }

  Future<void> open(BuildContext context, String id) async {
    if (canOpenChatMissing(this, id)) {
      await openChatMissing(this, context, id);
      return;
    }
    if (canOpenOnboardingMissing(this, id)) {
      await openOnboardingMissing(this, context, id);
      return;
    }
    if (canOpenCommerceMissing(this, id)) {
      await openCommerceMissing(this, context, id);
      return;
    }
    if (!canOpen(id)) return;
    if (const {'V128', 'V129', 'V130'}.contains(id)) {
      settings!.setRestriction(switch (id) {
        'V129' => RestrictionLevel.suspension,
        'V130' => RestrictionLevel.permanentBan,
        _ => RestrictionLevel.warning,
      });
    }
    final sarah = _chat('sarah');
    final story = StoriesController.stories.firstWhere((s) => s.id == 'maison');
    final navigator = Navigator.of(context);
    final anchor = ModalRoute.of(context);
    Widget? contextualConversation(ChatConversation chat, String? messageId) {
      final selectedGroup =
          groups?.forChat(chat.id) ?? (chat.id == group.chatId ? group : null);
      if (selectedGroup != null) {
        return GroupScreen(
          controller: selectedGroup,
          initialMessageId: messageId,
        );
      }
      final source = business.storyForChat(chat);
      if (source != null) {
        return BusinessConversationScreen(
          controller: business,
          story: source,
          initialMessageId: messageId,
        );
      }
      return null;
    }

    void finishReview() {
      if (anchor != null) {
        navigator.popUntil((route) => identical(route, anchor));
      }
      onProfileUpdated?.call();
    }

    void signOut() {
      navigator.popUntil((route) => route.isFirst);
      onSignOut?.call();
    }

    void startBusinessCall(Story source, bool video) {
      if (calls.active != null) return;
      final call = calls.start(
        name: source.author,
        kind: video ? CallKind.video : CallKind.audio,
        business: true,
        storyId: source.id,
        story: source,
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => CallScreen(controller: calls, call: call),
        ),
      );
    }

    Widget businessProfile(Story source) => BusinessProfileScreen(
      controller: business,
      story: source,
      onCall: startBusinessCall,
    );
    void showBusinessProfile(Story source) => navigator.push(
      MaterialPageRoute<void>(builder: (_) => businessProfile(source)),
    );
    void showPublishing() => navigator.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PublishingScreen(controller: publishing, settings: settings),
      ),
    );
    void showAppearance() => navigator.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AppearanceScreen(mode: themeMode, onChanged: onThemeChanged!),
      ),
    );
    void showSettings() => navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          controller: settings!,
          profile: profile!,
          stories: stories,
          onAppearance: showAppearance,
          onSignOut: signOut,
          onProfileUpdated: onProfileUpdated ?? () {},
        ),
      ),
    );
    Future<void> confirmSignOut() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(PrototypeToolsCopy.signOutTitle),
          content: const Text(PrototypeToolsCopy.youCanSignInAgainToContinue),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(CommonCopy.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(PrototypeToolsCopy.signOutAction),
            ),
          ],
        ),
      );
      if (context.mounted && confirmed == true) signOut();
    }

    Future<void> chooseMute(ChatConversation chat) async {
      final choice = await showModalBottomSheet<MuteChoice>(
        context: context,
        showDragHandle: true,
        builder: (_) => MuteDurationSheet(name: chat.name, isMuted: chat.muted),
      );
      if (!context.mounted || choice == null) return;
      switch (choice) {
        case MuteChoice.eightHours:
          chats.muteFor(chat, const Duration(hours: 8));
        case MuteChoice.oneWeek:
          chats.muteFor(chat, const Duration(days: 7));
        case MuteChoice.always:
          chats.muteFor(chat, null);
        case MuteChoice.unmute:
          chats.unmute(chat);
      }
    }

    Future<void> deleteMessage(
      ChatConversation chat,
      ChatMessage message,
    ) async {
      final choice = await showDialog<DeleteMessageChoice>(
        context: context,
        builder: (_) => DeleteMessageDialog(
          canDeleteForEveryone:
              message.isMine && !message.deleted && chats.canSendTo(chat),
        ),
      );
      if (!context.mounted ||
          choice == null ||
          !chat.messages.contains(message)) {
        return;
      }
      chats.delete(
        chat,
        message,
        forEveryone: choice == DeleteMessageChoice.forEveryone,
      );
    }

    Future<void> chooseReaction(
      ChatConversation chat,
      ChatMessage message,
    ) async {
      final value = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => ReactionPickerSheet(currentReaction: message.reaction),
      );
      if (!context.mounted ||
          value == null ||
          !chats.canSendTo(chat) ||
          message.deleted ||
          !chat.messages.contains(message)) {
        return;
      }
      chats.react(
        message,
        value.isEmpty || value == message.reaction ? null : value,
      );
    }

    if (id == 'S02') {
      final chat = sarah!;
      final selected = await showModalBottomSheet<ChatListAction>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => ChatActionsSheet(chat: chat),
      );
      if (!context.mounted || selected == null) return;
      switch (selected) {
        case ChatListAction.pin:
          chats.togglePinned(chat);
        case ChatListAction.archive:
          chats.archive(chat);
        case ChatListAction.unread:
          chats.setUnread(chat, chat.unread == 0);
        case ChatListAction.mute:
          await chooseMute(chat);
        case ChatListAction.starred:
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  StarredMessagesScreen(controller: chats, chat: chat),
            ),
          );
        case ChatListAction.delete:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => DeleteConversationDialog(chat: chat),
          );
          if (confirmed == true && context.mounted) {
            chats.deleteConversation(chat);
          }
      }
      return;
    }
    if (id == 'S03') {
      final chat = sarah!;
      final message = _reviewMessage()!;
      final choice = await showModalBottomSheet<MessageActionSelection>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => MessageActionsSheet(
          message: message,
          canSend: chats.canSendTo(chat),
          isOwn: message.isMine,
        ),
      );
      if (!context.mounted ||
          choice == null ||
          !chat.messages.contains(message)) {
        return;
      }
      switch (choice.$1) {
        case MessageAction.react:
          if (chats.canSendTo(chat) && !message.deleted) {
            chats.react(
              message,
              message.reaction == choice.$2 ? null : choice.$2,
            );
          }
        case MessageAction.moreReactions:
          await chooseReaction(chat, message);
        case MessageAction.reply:
        case MessageAction.edit:
          if (chats.canSendTo(chat) && !message.deleted) {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ConversationScreen(
                  controller: chats,
                  chat: chat,
                  initialMessageId: message.id,
                  initialReply: choice.$1 == MessageAction.reply
                      ? message
                      : null,
                  initialEdit: choice.$1 == MessageAction.edit ? message : null,
                ),
              ),
            );
          }
        case MessageAction.copy:
          if (!message.deleted) {
            await Clipboard.setData(ClipboardData(text: message.text));
          }
        case MessageAction.forward:
          final recipients = await Navigator.push<List<ChatConversation>>(
            context,
            MaterialPageRoute(
              builder: (_) => RecipientPickerScreen(
                controller: chats,
                multiSelect: true,
                includeGroups: true,
              ),
            ),
          );
          if (context.mounted && recipients != null && !message.deleted) {
            chats.forward(message, recipients);
          }
        case MessageAction.star:
          chats.toggleStar(message);
        case MessageAction.pin:
          chats.togglePin(message);
        case MessageAction.retry:
          chats.retry(message);
        case MessageAction.info:
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MessageDetailsScreen(message: message),
            ),
          );
        case MessageAction.delete:
          await deleteMessage(chat, message);
      }
      return;
    }
    if (id == 'S05') {
      final action = await showModalBottomSheet<PhotoSourceAction>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => PhotoSourceSheet(
          hasPhoto: profile!.photoSelected,
          label: PrototypeToolsCopy.profilePhotoLabel,
        ),
      );
      if (!context.mounted || action == null) return;
      if (action == PhotoSourceAction.remove) {
        profile!.setPhoto(null);
        onProfileUpdated?.call();
        return;
      }
      final photo = action == PhotoSourceAction.camera
          ? await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePhotoCaptureScreen(),
              ),
            )
          : await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const ProfilePhotoLibrarySheet(),
            );
      if (context.mounted && photo != null) {
        profile!.setPhoto(photo);
        onProfileUpdated?.call();
      }
      return;
    }
    if (id == 'S06') {
      await chooseMute(sarah!);
      return;
    }
    if (id == 'S07') {
      final chat = sarah!;
      await chooseReaction(
        chat,
        chat.messages.firstWhere((message) => !message.deleted),
      );
      return;
    }
    if (id == 'D02') {
      await deleteMessage(sarah!, _reviewMessage()!);
      return;
    }
    if (id == 'D03' || id == 'D04') {
      final chat = sarah!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => id == 'D03'
            ? DeleteConversationDialog(chat: chat)
            : ClearConversationDialog(name: chat.name),
      );
      if (confirmed == true && context.mounted) {
        if (id == 'D03') {
          chats.deleteConversation(chat);
        } else {
          for (final message in List<ChatMessage>.of(chat.messages)) {
            chats.delete(chat, message);
          }
        }
      }
      return;
    }
    if (id == 'D05') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => DeleteContactDialog(name: sarah!.name),
      );
      if (confirmed == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(PrototypeToolsCopy.deviceContactsSimulation),
          ),
        );
      }
      return;
    }
    if (id == 'D06') {
      final choice = await showDialog<LeaveGroupChoice>(
        context: context,
        builder: (_) =>
            LeaveGroupDialog(groupName: group.name, isOwner: group.isOwner),
      );
      if (!context.mounted || choice == null) return;
      if (choice == LeaveGroupChoice.chooseOwner) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                GroupMembersScreen(controller: group, transferMode: true),
          ),
        );
      } else {
        group.leave();
      }
      return;
    }
    if (const {'D07', 'D08', 'D09', 'D10'}.contains(id)) {
      final member = _memberForDialog(id)!;
      final action = switch (id) {
        'D07' => GroupMemberAction.remove,
        'D08' => GroupMemberAction.promote,
        'D09' => GroupMemberAction.demote,
        _ => GroupMemberAction.transfer,
      };
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => GroupMemberActionDialog(member: member, action: action),
      );
      if (confirmed == true && context.mounted) {
        switch (action) {
          case GroupMemberAction.remove:
            group.remove(member);
          case GroupMemberAction.promote:
            group.promote(member);
          case GroupMemberAction.demote:
            group.demote(member);
          case GroupMemberAction.transfer:
            group.transfer(member);
        }
      }
      return;
    }

    if (id == 'D19') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const SignOutDialog(),
      );
      if (confirmed == true && context.mounted) signOut();
      return;
    }
    if (id == 'D21' || id == 'D22') {
      final account = sarah!;
      final shouldUnblock = id == 'D22';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) =>
            AccountBlockDialog(name: account.name, unblock: shouldUnblock),
      );
      if (confirmed == true &&
          context.mounted &&
          account.blocked == shouldUnblock) {
        chats.toggleBlocked(account);
      }
      return;
    }
    if (id == 'D23') {
      final permission = _recoverablePermission()!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PermissionRecoveryDialog(permission: permission),
      );
      if (confirmed == true &&
          context.mounted &&
          settings!.permissions[permission] ==
              MockPermission.permanentlyDenied) {
        settings!.setPermission(permission, MockPermission.allowed);
      }
      return;
    }
    if (id == 'S21') {
      final selected = await showModalBottomSheet<PhotoVisibility>(
        context: context,
        showDragHandle: true,
        builder: (_) =>
            PhotoVisibilitySheet(initial: settings!.photoVisibility),
      );
      if (selected != null && context.mounted) {
        settings!.setPhotoVisibility(selected);
      }
      return;
    }
    if (id == 'D11') {
      final call = calls.history.first;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => DeleteCallDialog(call: call),
      );
      if (confirmed == true && context.mounted) calls.deleteHistory(call);
      return;
    }
    if (id == 'D12') {
      await showDialog<void>(
        context: context,
        builder: (_) =>
            LowCallBalanceDialog(controller: calls, call: calls.active!),
      );
      return;
    }
    if (id == 'D18') {
      final payment = _cancellablePayment()!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => CancelPaymentDialog(payment: payment),
      );
      if (confirmed == true && context.mounted) {
        wallet.setPaymentStatus(payment.id, PaymentStatus.cancelled);
      }
      return;
    }
    if (id == 'D13') {
      final publication = _publicationFor(id)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => DeletePublicationDialog(publication: publication),
      );
      if (confirmed == true && context.mounted) publishing.remove(publication);
      return;
    }
    if (id == 'D15') {
      await showDialog<void>(
        context: context,
        builder: (_) => PhotoSlotLimitDialog(
          used: publishing.usedPhotoSlots,
          limit: publishing.config.photoSlots,
        ),
      );
      return;
    }
    if (id == 'D16') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) =>
            OpenBusinessRoomDialog(controller: business, story: story),
      );
      if (!context.mounted || confirmed != true) return;
      final result = business.openRoom(story, confirmed: true);
      if (result == OpenRoomResult.insufficientCredits) {
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) =>
                BusinessInfoScreen(controller: business, story: story),
          ),
        );
        await showModalBottomSheet<void>(
          context: context,
          builder: (_) => InsufficientCreditsSheet(
            controller: wallet,
            requiredCredits: business.config.roomCredits,
          ),
        );
      } else if (result == OpenRoomResult.opened ||
          result == OpenRoomResult.alreadyActive) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                BusinessConversationScreen(controller: business, story: story),
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (_) =>
              BusinessRoomUnavailableDialog(story: story, reason: result),
        );
      }
      return;
    }
    if (id == 'D17' || id == 'V088' || id == 'V089') {
      await showDialog<void>(
        context: context,
        builder: (_) => BusinessRoomUnavailableDialog(
          story: story,
          reason: id == 'V088'
              ? OpenRoomResult.sourceUnavailable
              : OpenRoomResult.limitReached,
        ),
      );
      return;
    }
    if (id == 'S10') {
      calls.setMinimized(true);
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReviewMinimizedCallScreen(calls: calls, chats: chats),
        ),
      );
      return;
    }
    if (id == 'S12') {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => StoryViewerScreen(
            controller: stories,
            story: story,
            onBusinessProfile: showBusinessProfile,
            businessController: business,
            chatsController: chats,
            settings: settings,
            initiallyShowOptions: true,
          ),
        ),
      );
      return;
    }
    if (id == 'S14') {
      await showPublicationActions(
        context,
        controller: publishing,
        publication: publishing.publications.first,
        settings: settings,
      );
      return;
    }
    if (id == 'S15') {
      final area = await showModalBottomSheet<TargetArea>(
        context: context,
        showDragHandle: true,
        builder: (_) => const TargetAreaSheet(),
      );
      if (!context.mounted || area == null) return;
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..country = area.country
        ..city = area.city
        ..neighbourhood = area.neighbourhood;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => TargetAreaScreen(draft: draft)),
      );
      return;
    }
    if (id == 'S13') {
      final draft = publishing.createDraft(PublicationType.status);
      final selected = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) =>
            BoostOptionsSheet(draft: draft, fee: publishing.config.boostFee),
      );
      if (!context.mounted || selected == null) return;
      draft.boosted = selected;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              PriceReviewScreen(controller: publishing, draft: draft),
        ),
      );
      return;
    }
    if (id == 'V078') {
      final draft = publishing.createDraft(PublicationType.advertisement)
        ..category = 'Design'
        ..paidCategory = true
        ..media = PublicationMedia.video;
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              PriceReviewScreen(controller: publishing, draft: draft),
        ),
      );
      await showModalBottomSheet<void>(
        context: navigator.context,
        builder: (_) => InsufficientCreditsSheet(
          controller: wallet,
          requiredCredits: publishing.review(draft).total,
        ),
      );
      return;
    }

    if (id == 'S04') {
      final selected = await showModalBottomSheet<(MessageKind, String)>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => AttachmentSheet(
          onSelected: (kind, name) => Navigator.pop(sheetContext, (kind, name)),
        ),
      );
      if (!context.mounted || selected == null) return;
      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AttachmentPreviewScreen(kind: selected.$1, name: selected.$2),
        ),
      );
      if (!context.mounted ||
          confirmed != true ||
          sarah == null ||
          !chats.canSendTo(sarah)) {
        return;
      }
      final sent = chats.send(
        sarah,
        selected.$2,
        kind: selected.$1,
        upload: true,
      );
      if (sent == null) return;
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ConversationScreen(controller: chats, chat: sarah),
        ),
      );
      return;
    }
    if (id == 'S19') {
      final rate = wallet.conversionRate;
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (_) => ConversionReviewSheet(diamonds: 10, rate: rate),
      );
      if (!context.mounted || confirmed != true) return;
      final success = wallet.convertDiamonds(
        id: wallet.newId('review-conversion'),
        amount: 10,
        reviewedRate: rate,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? PrototypeToolsCopy.conversionSuccess
                : PrototypeToolsCopy.conversionFailure,
          ),
        ),
      );
      return;
    }
    if (id == 'S18' || id == 'S20') {
      final method = await showModalBottomSheet<PaymentMethod>(
        context: context,
        showDragHandle: true,
        builder: (_) => id == 'S18'
            ? const PaymentMethodSheet(selected: PaymentMethod.mtn)
            : PayoutMethodSheet(
                selected: PaymentMethod.mtn,
                fee: wallet.config.withdrawalFee,
              ),
      );
      if (!context.mounted || method == null) return;
      final page = id == 'S18'
          ? PaymentReviewScreen(
              controller: wallet,
              credits: 100,
              method: method,
              phone: '+237670000000',
            )
          : WithdrawalReviewScreen(
              controller: wallet,
              amount: wallet.config.withdrawalMinimum,
              method: method,
              destination: '+237670000000',
            );
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => page),
      );
      return;
    }

    if (id.startsWith('S') || id == 'V090' || id == 'V038') {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => switch (id) {
          'S08' || 'V038' => GroupMemberActionsSheet(
            controller: group,
            member: group.activeMembers.firstWhere(
              (m) => m.id != group.perspectiveId,
            ),
          ),
          'S09' => AudioOutputSheet(controller: calls, call: calls.active!),
          'S11' => BusinessCallPreflightSheet(
            controller: business,
            story: story,
            video: false,
            onCall: (source, video) {
              if (calls.active != null) return;
              final call = calls.start(
                name: source.author,
                kind: video ? CallKind.video : CallKind.audio,
                business: true,
                storyId: source.id,
                story: source,
              );
              navigator.push(
                MaterialPageRoute<void>(
                  builder: (_) => CallScreen(controller: calls, call: call),
                ),
              );
            },
          ),
          'S16' || 'V090' => BusinessContactSheet(
            controller: business,
            story: story,
            onCall: startBusinessCall,
          ),
          'S17' => InsufficientCreditsSheet(
            controller: wallet,
            requiredCredits: wallet.credits + 10,
          ),
          _ => throw StateError(PrototypeToolsCopy.unsupportedSheet(id)),
        },
      );
      return;
    }
    if (id == 'V001') discover!.load(delay: const Duration(seconds: 2));
    if (id == 'V003') discover!.showError();
    if (id == 'V002' || id == 'V018') chats.setOnline(false);
    if (id == 'V018' &&
        !sarah!.messages.any(
          (message) => message.status == DeliveryStatus.queued,
        )) {
      chats.send(sarah, 'Let’s catch up soon.');
    }
    if (id == 'V029' || id == 'V030' || id == 'V031') {
      final role = switch (id) {
        'V029' => GroupRole.owner,
        'V030' => GroupRole.admin,
        _ => GroupRole.member,
      };
      final members = group.activeMembers.where(
        (member) => member.role == role,
      );
      if (members.isNotEmpty) group.setPerspective(members.first.id);
    }
    if (id == 'V071') business.setSourceEligible(story.id, false);
    if (id == 'V085') {
      business.setPerspective(BusinessPerspective.recipient);
      if (business.roomFor(story.id) == null) {
        business.seedRecipientRoom(story);
      }
    }
    if (id == 'V084') business.setPerspective(BusinessPerspective.customer);
    if (id == 'V005') profile!.setSignInState(SignInState.cancelled);
    if (id == 'V006') profile!.setSignInState(SignInState.failed);
    if (id == 'P06') profile!.setSignInState(SignInState.idle);
    if (id == 'P09') profile!.setContactsState(ContactsState.idle);
    if (id == 'V013') profile!.setContactsState(ContactsState.empty);
    if (id == 'V053') calls.setReconnecting(true);
    final reviewTheme = switch (id) {
      'V120' => ThemeMode.light,
      'V121' => ThemeMode.dark,
      'V122' => ThemeMode.system,
      _ => null,
    };
    if (reviewTheme != null) onThemeChanged!(reviewTheme);
    CallSession? reviewCall;
    if (const {'V045', 'V046', 'V050', 'V051', 'V055'}.contains(id)) {
      final isBusiness = id == 'V046' || id == 'V051';
      reviewCall = calls.start(
        name: isBusiness ? story.author : sarah!.name,
        kind: CallKind.audio,
        business: isBusiness,
        incoming: id == 'V050' || id == 'V051',
        contactId: isBusiness ? null : sarah!.id,
        storyId: isBusiness ? story.id : null,
        story: isBusiness ? story : null,
      );
    }
    PublicationDraft reviewDraft({
      PublicationType type = PublicationType.status,
      PublicationMedia media = PublicationMedia.photo,
    }) {
      return publishing.createDraft(type)..media = media;
    }

    final Widget page = switch (id) {
      'P01' || 'V002' => ChatsScreen(
        controller: chats,
        specialScreenBuilder: (chat) => contextualConversation(chat, null),
        specialMessageScreenBuilder: contextualConversation,
      ),
      'P02' => CallsScreen(controller: calls, chats: chats),
      'P03' || 'V062' || 'V068' => StatusScreen(
        controller: stories,
        chatsController: chats,
        businessController: business,
        onBusinessProfile: showBusinessProfile,
        settings: settings,
        onCreate: showPublishing,
        onDiscover: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => DiscoverScreen(
              controller: stories,
              discover: discover,
              onBusinessProfile: showBusinessProfile,
              businessController: business,
              settings: settings,
            ),
          ),
        ),
      ),
      'P04' || 'V001' || 'V003' || 'V069' => DiscoverScreen(
        controller: stories,
        discover: discover,
        onBusinessProfile: showBusinessProfile,
        businessController: business,
        settings: settings,
      ),
      'P05' => ProfileScreen(
        name: profile!.name.isEmpty ? 'Alex Morgan' : profile!.name,
        photoLabel: profile!.photoSelected
            ? (profile!.photoLabel ?? PrototypeToolsCopy.profilePhoto)
            : null,
        about: settings!.about,
        onWallet: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => WalletScreen(controller: wallet),
          ),
        ),
        onAppearance: showAppearance,
        onSignOut: confirmSignOut,
        onPrototypeTools: () {
          if (anchor != null) {
            navigator.popUntil((route) => identical(route, anchor));
          }
          navigator.pop();
        },
        onPublishing: showPublishing,
        onSettings: showSettings,
        wallet: wallet,
        onBusinessTools: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => EditBusinessProfileScreen(controller: settings!),
          ),
        ),
        onPublications: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) =>
                PublicationsScreen(controller: publishing, settings: settings),
          ),
        ),
        onEarnings: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => BalanceActivityScreen(
              controller: wallet,
              kind: BalanceKind.diamonds,
            ),
          ),
        ),
        onSupport: () => navigator.push(
          MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
        ),
      ),
      'P10' => const LegalScreen(document: LegalDocument.terms),
      'P11' => const LegalScreen(document: LegalDocument.privacy),
      'P06' || 'V004' || 'V005' || 'V006' => WelcomeScreen(
        controller: profile!,
        onComplete: finishReview,
        initiallyStartSignIn: id == 'V004',
      ),
      'P07' => CompleteProfileScreen(
        controller: profile!,
        onComplete: finishReview,
      ),
      'P08' => InterestsScreen(controller: profile!, onComplete: finishReview),
      'V010' => InterestsScreen(
        controller: profile!,
        mode: InterestSelectionMode.advertisement,
        onComplete: finishReview,
      ),
      'P09' || 'V013' => ContactsAccessScreen(
        controller: profile!,
        onComplete: finishReview,
      ),
      'P12' => RecipientPickerScreen(controller: chats),
      'P13' => ChatSearchScreen(
        controller: chats,
        specialScreenBuilder: (chat) => contextualConversation(chat, null),
        specialMessageScreenBuilder: contextualConversation,
      ),
      'P14' || 'V018' => ConversationScreen(controller: chats, chat: sarah!),
      'V020' || 'V021' => ConversationScreen(
        controller: chats,
        chat: sarah!,
        initialMessageId: _reviewMessage()!.id,
        initialReply: id == 'V020' ? _reviewMessage() : null,
        initialEdit: id == 'V021' ? _reviewMessage() : null,
      ),
      'V014' ||
      'V015' ||
      'V016' ||
      'V017' ||
      'V019' ||
      'V025' => ConversationScreen(
        controller: chats,
        chat: _messageScenario(id)!.$1,
        initialMessageId: _messageScenario(id)!.$2.id,
      ),
      'V024' => ConversationScreen(controller: chats, chat: sarah!),
      'P15' => ChatInfoScreen(controller: chats, chat: sarah!),
      'P16' => SharedMediaScreen(
        chat: sarah!,
        controller: chats,
        specialMessageScreenBuilder: contextualConversation,
      ),
      'P17' => MediaViewerScreen(message: _message(MessageKind.photo)!),
      'P18' => MessageDetailsScreen(
        message: sarah!.messages.firstWhere(
          (message) => message.isMine && !message.deleted,
        ),
      ),
      'P22' => MediaViewerScreen(message: _message(MessageKind.document)!),
      'V028' => MediaViewerScreen(message: _messageScenario(id)!.$2),
      'P19' || 'V027' => ArchivedChatsScreen(
        controller: chats,
        specialScreenBuilder: (chat) => contextualConversation(chat, null),
        specialMessageScreenBuilder: contextualConversation,
      ),
      'P20' => StarredMessagesScreen(
        controller: chats,
        specialScreenBuilder: (chat) => contextualConversation(chat, null),
        specialMessageScreenBuilder: contextualConversation,
      ),
      'P21' => EditContactScreen(controller: chats),
      'P23' ||
      'V029' ||
      'V030' ||
      'V031' ||
      'V032' ||
      'V034' ||
      'V035' => GroupScreen(controller: group),
      'V033' => GroupScreen(controller: group, initialDraft: '@'),
      'P24' => GroupDetailsScreen(controller: group),
      'P25' => GroupInfoScreen(controller: group),
      'P26' => GroupMembersScreen(controller: group),
      'V037' => GroupMembersScreen(controller: group, transferMode: true),
      'P27' => GroupPermissionsScreen(controller: group),
      'V043' => AddGroupMembersScreen(controller: group),
      'V044' => RecipientPickerScreen(controller: chats, multiSelect: true),
      'V041' || 'V042' => MessageDetailsScreen(
        message: _groupReceiptFor(id)!,
        group: true,
        canSeeGroupReceipts: true,
        updates: group,
      ),
      'P28' => CallDetailsScreen(call: _callFor(id)!, controller: calls),
      'P29' ||
      'P30' ||
      'P31' ||
      'P32' ||
      'V052' ||
      'V053' => CallScreen(controller: calls, call: calls.active!),
      'P33' ||
      'V047' ||
      'V048' ||
      'V049' ||
      'V054' => CallSummaryScreen(controller: calls, call: _callFor(id)!),
      'V045' ||
      'V046' ||
      'V050' ||
      'V051' ||
      'V055' => CallScreen(controller: calls, call: reviewCall!),
      'P34' => StoryViewerScreen(
        controller: stories,
        story: _storyForScenario('V063')!,
        businessController: business,
        chatsController: chats,
        settings: settings,
        onBusinessProfile: showBusinessProfile,
      ),
      'V056' ||
      'V057' ||
      'V058' ||
      'V059' ||
      'V060' ||
      'V061' ||
      'V063' ||
      'V064' ||
      'V065' ||
      'V066' ||
      'V067' => StoryViewerScreen(
        controller: stories,
        story: _storyForScenario(id)!,
        onBusinessProfile: showBusinessProfile,
        businessController: business,
        chatsController: chats,
        settings: settings,
        initiallyPaused: id == 'V063',
        initiallyMuted: id == 'V064',
      ),
      'P35' => DiscoverSearchScreen(
        controller: stories,
        discover: discover,
        businessController: business,
        onBusinessProfile: showBusinessProfile,
        settings: settings,
      ),
      'V070' => DiscoverSearchScreen(
        controller: stories,
        discover: discover,
        initialCategory: _emptyDiscoverCategory(),
        onBusinessProfile: showBusinessProfile,
        businessController: business,
        settings: settings,
      ),
      'P36' || 'V071' => businessProfile(story),
      'P37' => PublishingScreen(controller: publishing, settings: settings),
      'P38' => CategoryScreen(
        controller: publishing,
        draft: publishing.createDraft(PublicationType.status),
        settings: settings,
      ),
      'P39' => MediaScreen(
        controller: publishing,
        draft: reviewDraft(),
        settings: settings,
      ),
      'P40' => CaptureScreen(
        controller: publishing,
        draft: reviewDraft(),
        settings: settings,
      ),
      'P41' => EditorScreen(
        controller: publishing,
        draft: reviewDraft(),
        settings: settings,
      ),
      'P42' => EditorScreen(
        controller: publishing,
        draft: reviewDraft(media: PublicationMedia.video),
        settings: settings,
      ),
      'P43' => AudioRecorderScreen(
        controller: publishing,
        draft: reviewDraft(media: PublicationMedia.audio),
        settings: settings,
      ),
      'P44' => PriceReviewScreen(
        controller: publishing,
        draft: reviewDraft(
          type: PublicationType.advertisement,
          media: PublicationMedia.video,
        )..paidCategory = true,
      ),
      'V072' || 'V073' || 'V074' || 'V077' => PriceReviewScreen(
        controller: publishing,
        draft:
            reviewDraft(
                type: id == 'V077'
                    ? PublicationType.advertisement
                    : PublicationType.status,
                media: id == 'V077'
                    ? PublicationMedia.video
                    : PublicationMedia.photo,
              )
              ..category = id == 'V073' || id == 'V077' ? 'Design' : 'Everyday'
              ..paidCategory = id == 'V073' || id == 'V077',
      ),
      'V076' => MediaScreen(
        controller: publishing,
        draft: reviewDraft(media: PublicationMedia.video),
        settings: settings,
      ),
      'P45' => AudienceScreen(
        controller: publishing,
        draft: reviewDraft(type: PublicationType.advertisement),
      ),
      'P46' => TargetAreaScreen(
        draft: reviewDraft(type: PublicationType.advertisement),
      ),
      'P47' ||
      'V084' ||
      'V085' ||
      'V087' => BusinessConversationScreen(controller: business, story: story),
      'P48' || 'V086' => BusinessInfoScreen(controller: business, story: story),
      'P49' ||
      'V096' => PublicationsScreen(controller: publishing, settings: settings),
      'P50' || 'V082' => PublicationDetailsScreen(
        controller: publishing,
        publication: _publicationFor(id)!,
      ),
      'P51' || 'V091' || 'V092' => StoryViewersScreen(
        controller: publishing,
        publication: _publicationFor(id)!,
      ),
      'P52' || 'V093' || 'V094' || 'V095' => AnalyticsScreen(
        controller: publishing,
        publication: _publicationFor(id)!,
      ),
      'P53' => PromotionContactActivityScreen(
        controller: publishing.contactActivity!,
        publication: _publicationFor(id)!,
      ),
      'P54' => WalletScreen(controller: wallet),
      'P55' => BalanceActivityScreen(
        controller: wallet,
        kind: BalanceKind.credits,
      ),
      'V105' => BalanceActivityScreen(
        controller: wallet,
        kind: _emptyBalanceKind()!,
      ),
      'P56' => TransactionDetailsScreen(
        controller: wallet,
        activity: wallet.activity.first,
      ),
      'P57' => BuyCreditsScreen(controller: wallet),
      'P58' => PaymentReviewScreen(
        controller: wallet,
        credits: 100,
        method: PaymentMethod.mtn,
        phone: '+237670000000',
      ),
      'V102' || 'V103' => PaymentReviewScreen(
        controller: wallet,
        credits: 100,
        method: id == 'V102' ? PaymentMethod.mtn : PaymentMethod.orange,
        phone: '+237670000000',
      ),
      'P59' || 'V097' || 'V098' || 'V099' || 'V100' || 'V101' || 'V104' =>
        PaymentStatusScreen(controller: wallet, payment: _paymentFor(id)!),
      'V109' => TransactionDetailsScreen(
        controller: wallet,
        activity: _conversionActivity()!,
      ),
      'P60' || 'V106' || 'V107' => ConvertDiamondsScreen(controller: wallet),
      'P61' => WithdrawalFormScreen(controller: wallet),
      'P62' || 'V111' => WithdrawalReviewScreen(
        controller: wallet,
        amount: wallet.config.withdrawalMinimum,
        method: PaymentMethod.mtn,
        destination: '+237670000000',
      ),
      'P63' => WithdrawalHistoryScreen(controller: wallet),
      'P64' ||
      'V114' ||
      'V115' ||
      'V116' ||
      'V117' ||
      'V118' ||
      'V119' => WithdrawalDetailsScreen(
        controller: wallet,
        withdrawal: _withdrawalFor(id)!,
      ),
      'P65' => EditProfileScreen(
        profile: profile!,
        settings: settings!,
        onSaved: onProfileUpdated ?? () {},
      ),
      'P66' => EditBusinessProfileScreen(controller: settings!),
      'P67' || 'V124' => SettingsScreen(
        controller: settings!,
        profile: profile!,
        stories: stories,
        onAppearance: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) =>
                AppearanceScreen(mode: themeMode, onChanged: onThemeChanged!),
          ),
        ),
        onSignOut: signOut,
        onProfileUpdated: onProfileUpdated ?? () {},
      ),
      'P68' => PrivacyScreen(controller: settings!),
      'P69' => StatusAudienceScreen(controller: settings!),
      'P70' => NotificationsScreen(controller: settings!),
      'P71' || 'V120' || 'V121' || 'V122' => AppearanceScreen(
        mode: reviewTheme ?? themeMode,
        onChanged: onThemeChanged!,
        textScaleFactor: settings?.textScaleFactor ?? 1,
        onTextScaleChanged: settings?.setTextScaleFactor,
      ),
      'P72' || 'V125' => PermissionsScreen(controller: settings!),
      'P73' || 'V123' => BlockedAccountsScreen(controller: settings!),
      'P74' => AccountScreen(profile: profile!, onSignOut: signOut),
      'P75' => const HelpScreen(),
      'P76' => const HelpArticleScreen(
        title: PrototypeToolsCopy.gettingStarted,
        content: PrototypeToolsCopy.gettingStartedDescription,
      ),
      'P77' => const AboutScreen(),
      'P78' => DeleteAccountScreen(onDelete: signOut),
      'P79' => ReportScreen(target: story.author, targetId: story.id),
      'P80' || 'V128' => const RestrictionScreen(
        level: RestrictionLevel.warning,
        reason: PrototypeToolsCopy.warningReason,
      ),
      'V129' => const RestrictionScreen(
        level: RestrictionLevel.suspension,
        reason: PrototypeToolsCopy.suspensionReason,
      ),
      'V130' => const RestrictionScreen(
        level: RestrictionLevel.permanentBan,
        reason: PrototypeToolsCopy.permanentRestrictionReason,
      ),
      _ => throw StateError(PrototypeToolsCopy.unsupportedPage(id)),
    };
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }
}
