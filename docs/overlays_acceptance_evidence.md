# Overlay acceptance evidence

Scope: all 21 sheets and 23 dialogs in `prompt.md`. This inventory is not visual or device acceptance. **Partial** means the referenced tests cover the stated behavior but do not establish every variant, layout and interaction. Test paths are relative to `app/test/`. Existing references were inspected but not individually rerun for this audit.

| ID | Status | Evidence and remaining gap |
| --- | --- | --- |
| S01 | Partial | `prototype_tools/review_onboarding_missing_test.dart`: country search, prefix, dismissal; other locales remain unverified. |
| S02 | Partial | `prototype_tools/additional_review_actions_test.dart`: targeted chat and mute; full action matrix unverified. |
| S03 | Partial | `prototype_tools/additional_review_actions_test.dart`: reply; other actions and permissions need coverage. |
| S04 | Partial | `chats/chat_attachment_test.dart`: document preview/send; other tray entries and dismissal need coverage. |
| S05 | Partial | `onboarding/photo_source_test.dart`: camera/library and removal; other contexts need coverage. |
| S06 | Partial | `chats/chat_review_surfaces_test.dart`: duration, unmute and expiry; every duration not independently tested. |
| S07 | Partial | `chats/chat_review_surfaces_test.dart`: expanded choices/removal; cross-message targeting needs coverage. |
| S08 | Partial | `acceptance/overlays/member_actions_test.dart`: role restrictions and owner actions at 800×600 and 320×640 with 1.3× text after scrolling fix; more viewport/role combinations need coverage. |
| S09 | Partial | `acceptance/overlays/audio_and_sign_out_test.dart`: dismiss and choose Bluetooth/speaker on same call; earpiece reselection remains unverified. |
| S10 | Partial | `prototype_tools/additional_review_actions_test.dart`: session and return; timer/end need further coverage. |
| S11 | Partial | `business/business_call_topup_info_test.dart`: top-up return/cancel and unavailable source; price/balance matrix incomplete. |
| S12 | Partial | `stories/story_options_test.dart`: Business, contact and own options; complete option matrix unverified. |
| S13 | Partial | `publishing/publishing_dialogs_test.dart`: cancel and mandatory video Boost; audio and all terms unverified. |
| S14 | Partial | `publishing/publication_actions_test.dart`: selected open/delete and cancel; full eligibility matrix unverified. |
| S15 | Partial | `publishing/target_area_screen_test.dart`: selection and draft retention; geographic choice matrix unverified. |
| S16 | Partial | `business/business_controller_test.dart`: active room reuse and source eligibility at controller level; selector options/prices need contextual tests. |
| S17 | Partial | `business/business_call_topup_info_test.dart`: top-up/cancel return; amount details and other contexts need coverage. |
| S18 | Partial | `business/business_call_topup_info_test.dart`: MTN and Orange flows; exclusive list and phone validation matrix unverified. |
| S19 | Partial | `prototype_tools/contextual_review_test.dart`: cancel/confirm conversion; rate/balance edge cases need coverage. |
| S20 | Partial | `wallet/wallet_flow_test.dart`: withdrawal confirmation and reservation; method choices and fee explanation need coverage. |
| S21 | Partial | `prototype_tools/additional_review_actions_test.dart`: selection applies after Save; full dismissal/options matrix unverified. |
| D01 | Partial | `groups/group_draft_test.dart`: keep/discard edited group; other forms unverified. |
| D02 | Partial | `chats/chat_review_surfaces_test.dart`: own-message eligibility; target mutation/cancel paths need coverage. |
| D03 | Partial | `chats/chat_review_surfaces_test.dart`: cancel/confirm conversation deletion; other types unverified. |
| D04 | Partial | `prototype_tools/additional_review_actions_test.dart`: cancellation preserves chat; confirmed clear needs coverage. |
| D05 | Partial | `chats/chat_review_surfaces_test.dart`: simulated handoff preserves chat; more contact states unverified. |
| D06 | Partial | `groups/group_controller_test.dart`: owner transfer and leave at controller level; dialog path needs coverage. |
| D07 | Partial | `acceptance/overlays/member_actions_test.dart`: target, cancel and confirmed removal; other roles need coverage. |
| D08 | Partial | `acceptance/overlays/member_actions_test.dart`: target, cancel and confirmed promotion; other roles need coverage. |
| D09 | Partial | `acceptance/overlays/member_actions_test.dart`: target, cancel and confirmed demotion; other roles need coverage. |
| D10 | Partial | `acceptance/overlays/member_actions_test.dart`: target, cancel and transfer; leave flow needs coverage. |
| D11 | Partial | `calls/call_dialogs_test.dart`: target/cancel; confirmed deletion and multiple records need coverage. |
| D12 | Partial | `calls/calls_controller_test.dart`: balance boundary/warnings at controller level; dialog dismissal needs coverage. |
| D13 | Partial | `publishing/publication_actions_test.dart`: cancel and target-only deletion; other publication states unverified. |
| D14 | Partial | `publishing/publishing_dialogs_test.dart`: refreshed terms/cancel; other configurations unverified. |
| D15 | Partial | `publishing/publishing_dialogs_test.dart`: limit and retained draft; other contexts unverified. |
| D16 | Partial | `business/business_room_dialogs_test.dart` and `prototype_tools/additional_review_actions_test.dart`: target, cancel and charge; reopen matrix incomplete. |
| D17 | Partial | `business/business_room_dialogs_test.dart`: Story target and no charge; other limits unverified. |
| D18 | Partial | `wallet/payment_cancel_dialog_test.dart` and `prototype_tools/additional_review_actions_test.dart`: pending payment and no credit; more states unverified. |
| D19 | Partial | `acceptance/overlays/audio_and_sign_out_test.dart`: cancel and single sign-out callback; route return needs coverage. |
| D20 | Partial | `prototype_tools/review_commerce_missing_test.dart`: acknowledgement/final confirmation; navigation and reset need coverage. |
| D21 | Partial | `prototype_tools/additional_review_actions_test.dart`: block target and confirm; other contexts unverified. |
| D22 | Partial | `prototype_tools/additional_review_actions_test.dart`: unblock same contact; other contexts unverified. |
| D23 | Partial | `settings/appearance_and_matching_test.dart`: permanent denial recovery/cancellation; other permissions unverified. |

New tests verified from `app/` with `dart format test/acceptance/overlays`, `flutter analyze test/acceptance/overlays`, and `flutter test test/acceptance/overlays` (8 tests). No device tests or HTML visual comparison were performed in this audit. All effects are simulated locally.
