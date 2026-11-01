# Prototype scenario checklist

All 130 named scenarios have contextual behavior evidence recorded in [the evidence ledger](scenarios_acceptance_evidence.md). Partial means the linked tests cover named actions or transitions; it is not full visual or device acceptance. The [acceptance audit](acceptance_audit.md) records the latest executed full-suite results.

| ID | Scenario | Status |
| --- | --- | --- |
| V001 | Initial application loading. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V002 | Offline/reconnecting. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V003 | Recoverable page error. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V004 | Sign-in in progress. | Partial — [behavior evidence](../app/test/prototype_tools/review_integrity_test.dart) |
| V005 | Sign-in cancelled. | Partial — [behavior evidence](../app/test/prototype_tools/review_integrity_test.dart) |
| V006 | Sign-in failed. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V007 | Invalid required phone/profile. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V008 | Terms not accepted. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V009 | Fewer than three interests. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V010 | Single-interest advertisement mode. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V011 | Contacts permission declined. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V012 | Contact matching in progress. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V013 | No matching app contacts. | Partial — [behavior evidence](../app/test/prototype_tools/review_onboarding_missing_test.dart) |
| V014 | Sending message. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V015 | Message sent. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V016 | Message delivered. | Partial — [behavior evidence](../app/test/chats/direct_receipts_test.dart) |
| V017 | Message read. | Partial — [behavior evidence](../app/test/chats/direct_receipts_test.dart) |
| V018 | Offline queued message. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V019 | Message failed. | Partial — [behavior evidence](../app/test/chats/direct_receipts_test.dart) |
| V020 | Reply composer. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V021 | Edit composer. | Partial — [behavior evidence](../app/test/chats/chat_composer_test.dart) |
| V022 | Voice recording. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V023 | Voice recording locked. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V024 | Blocked direct chat. | Partial — [behavior evidence](../app/test/integration/session_state_test.dart) |
| V025 | Attachment upload progress/failure. | Partial — [behavior evidence](../app/test/chats/chat_attachment_test.dart) |
| V026 | No search matches. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V027 | Empty archived list. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V028 | Unsupported file preview. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V029 | Owner view. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V030 | Admin view. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V031 | Member view. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V032 | Only admins may send. | Partial — [behavior evidence](../app/test/groups/group_screen_test.dart) |
| V033 | Mention suggestions. | Partial — [behavior evidence](../app/test/prototype_tools/contextual_review_test.dart) |
| V034 | Removed member. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V035 | Left group. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V036 | Member search has no results. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V037 | Owner transfer selection. | Partial — [behavior evidence](../app/test/groups/group_controller_test.dart) |
| V038 | No permission for member action. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V039 | Group creation/update in progress. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V040 | Group creation/update failed. | Partial — [behavior evidence](../app/test/prototype_tools/review_chat_missing_test.dart) |
| V041 | Partial group delivery/reads. | Partial — [behavior evidence](../app/test/prototype_tools/contextual_review_test.dart) |
| V042 | All group recipients read. | Partial — [behavior evidence](../app/test/prototype_tools/contextual_review_test.dart) |
| V043 | Add members/already present. | Partial — [behavior evidence](../app/test/acceptance/chat_groups/chat_group_scenarios_test.dart) |
| V044 | Empty multiselect. | Partial — [behavior evidence](../app/test/groups/group_directory_test.dart) |
| V045 | Personal call ringing. | Partial — [behavior evidence](../app/test/integration/personal_call_flow_test.dart) |
| V046 | Business call ringing. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V047 | Busy. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V048 | Declined. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V049 | Unanswered/missed. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V050 | Incoming personal call. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V051 | Incoming Business call. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V052 | Business call answered. | Partial — [behavior evidence](../app/test/calls/calls_controller_test.dart) |
| V053 | Reconnecting call. | Partial — [behavior evidence](../app/test/acceptance/calls/call_states_test.dart) |
| V054 | Balance-boundary stop. | Partial — [behavior evidence](../app/test/calls/calls_controller_test.dart) |
| V055 | Permission-blocked call. | Partial — [behavior evidence](../app/test/calls/calls_controller_test.dart) |
| V056 | Contact Story. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V057 | Business Story. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V058 | Own Story. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V059 | Image playback. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V060 | Video playback. | Partial — [behavior evidence](../app/test/stories/story_viewer_test.dart) |
| V061 | Audio playback. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V062 | Seen Story. | Partial — [behavior evidence](../app/test/stories/story_viewer_test.dart) |
| V063 | Paused Story. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V064 | Muted playback. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V065 | Expired Story. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V066 | Removed Story. | Partial — [behavior evidence](../app/test/stories/story_viewer_test.dart) |
| V067 | Story media failed to load. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V068 | No contact Stories. | Partial — [behavior evidence](../app/test/acceptance/stories/story_scenarios_test.dart) |
| V069 | No eligible promoted content. | Partial — [behavior evidence](../app/test/stories/discover_test.dart) |
| V070 | No eligible search results. | Partial — [behavior evidence](../app/test/stories/discover_test.dart) |
| V071 | No eligible active Stories on a Business profile. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V072 | Free category. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V073 | Paid category. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V074 | Image slot available. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V075 | Paid-category image uses a slot. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V076 | Mandatory video/audio Boost. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V077 | Video/audio advertisement total. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V078 | Insufficient Credits. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V079 | Price/configuration changed. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V080 | Publishing in progress. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V081 | Publication failed. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V082 | Publication succeeded. | Partial — [behavior evidence](../app/test/publishing/publishing_controller_test.dart) |
| V083 | Location denied/manual targeting. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V084 | Customer active room. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V085 | Recipient active room. | Partial — [behavior evidence](../app/test/business/business_controller_test.dart) |
| V086 | Active room/originating Story expired. | Partial — [behavior evidence](../app/test/integration/session_state_test.dart) |
| V087 | Expired room/source still eligible. | Partial — [behavior evidence](../app/test/business/business_controller_test.dart) |
| V088 | Expired room/source unavailable. | Partial — [behavior evidence](../app/test/integration/session_state_test.dart) |
| V089 | Interaction reopening cap reached. | Partial — [behavior evidence](../app/test/business/business_controller_test.dart) |
| V090 | Active room reopened from Story without another charge. | Partial — [behavior evidence](../app/test/business/business_controller_test.dart) |
| V091 | No contact viewers yet. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V092 | Contact viewers available. | Partial — [behavior evidence](../app/test/prototype_tools/publication_review_controls_test.dart) |
| V093 | Below Popular threshold. | Partial — [behavior evidence](../app/test/prototype_tools/review_catalog_test.dart) |
| V094 | Popular threshold reached. | Partial — [behavior evidence](../app/test/prototype_tools/publication_review_controls_test.dart) |
| V095 | Suspicious views held. | Partial — [behavior evidence](../app/test/prototype_tools/publication_review_controls_test.dart) |
| V096 | No publications/no filter matches. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V097 | Payment processing. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V098 | Payment pending. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V099 | Payment failed. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V100 | Payment cancelled. | Partial — [behavior evidence](../app/test/wallet/wallet_flow_test.dart) |
| V101 | Payment confirmed. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V102 | MTN Mobile Money selected. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V103 | Orange Mobile Money selected. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V104 | SmobilPay provider confirmation. | Partial — [behavior evidence](../app/test/wallet/wallet_flow_test.dart) |
| V105 | No activity for selected balance. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V106 | Pending Diamonds. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V107 | Frozen Diamonds. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V108 | Conversion submitted/failed. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V109 | Conversion confirmed. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V110 | Below withdrawal minimum. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V111 | Fee/net payout review. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V112 | Invalid destination. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V113 | Frequency limit reached. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V114 | Pending withdrawal. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V115 | Withdrawal in progress. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V116 | Withdrawal approved. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V117 | Withdrawal rejected. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V118 | Withdrawal paid. | Partial — [behavior evidence](../app/test/acceptance/wallet/wallet_scenarios_test.dart) |
| V119 | Technical payout failure/recredit. | Partial — [behavior evidence](../app/test/wallet/wallet_controller_test.dart) |
| V120 | Light theme. | Partial — [behavior evidence](../app/test/wallet/wallet_flow_test.dart) |
| V121 | Dark theme. | Partial — [behavior evidence](../app/test/prototype_tools/additional_review_actions_test.dart) |
| V122 | System theme. | Partial — [behavior evidence](../app/test/acceptance/settings_states_test.dart) |
| V123 | No blocked accounts. | Partial — [behavior evidence](../app/test/acceptance/settings_states_test.dart) |
| V124 | Business profile incomplete. | Partial — [behavior evidence](../app/test/acceptance/remaining_scenarios/remaining_scenarios_test.dart) |
| V125 | Permission permanently denied. | Partial — [behavior evidence](../app/test/settings/appearance_and_matching_test.dart) |
| V126 | Report submitted. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V127 | Report failed. | Partial — [behavior evidence](../app/test/prototype_tools/review_commerce_missing_test.dart) |
| V128 | Warning. | Partial — [behavior evidence](../app/test/acceptance/scenarios/restriction_scenarios_test.dart) |
| V129 | Suspension. | Partial — [behavior evidence](../app/test/acceptance/scenarios/restriction_scenarios_test.dart) |
| V130 | Permanent ban. | Partial — [behavior evidence](../app/test/acceptance/scenarios/restriction_scenarios_test.dart) |
