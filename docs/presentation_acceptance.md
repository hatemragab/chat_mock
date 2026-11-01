# Presentation acceptance evidence

These widget tests exercise native Flutter layouts and customer actions at **320 × 640**, **386 × 802**, and **430 × 900**, in both light and dark themes with **1.3× text scaling**. Keyboard insets and safe areas are included where noted. Passing these checks establishes the tested layout and behavior, not HTML visual parity or physical-device acceptance.

| Area | Exercised behavior | Evidence |
| --- | --- | --- |
| Direct/group conversations, recipients and member actions | Multiline/emoji messaging; voice lock, stop, send and cancel; attachment/file actions; recipient footer; group permissions and member actions. Conversation and recipient tests retain a 220 px keyboard inset. | [Chat presentation tests](../app/test/acceptance/chat_presentation_test.dart) |
| Publishing and creator tools | Advertisement creation through targeting, price review, publication, details, analytics and contact activity; photo editing, Boost cancellation, viewers, filters and removal; video capture/retake and audio recording/playback. Relevant editing, targeting and Boost checks include a keyboard inset. | [Publishing presentation tests](../app/test/publishing/publishing_responsive_test.dart) |
| Business profile/rooms | Profile → contact sheet → call preflight or message room; multiline message sending and info with a 240 px keyboard inset. | [Business presentation tests](../app/test/business/business_presentation_test.dart) |
| Calls | Ringing/busy with zero charge; incoming answer and summary; video controls/output; low-balance dialog and warning contrast; minimize, return and end; history/details/deletion. | [Call presentation tests](../app/test/calls/call_presentation_test.dart) |
| Wallet, Business profile editing and reports | Balance navigation; payment review and pending status without credit; invalid conversion without debit; withdrawal confirmation/tracking; required profile validation; report submission. Conversion/profile/report tests retain a 200 px keyboard inset. | [Wallet/settings layout tests](../app/test/acceptance/layout/wallet_settings_layout_test.dart) |

The checks exposed and now cover regressions for wrapping voice/video controls, scrolling Business contact sheets, compact Business context while typing, dark call-warning colors, and long payment/payout method or phone values.

Other focused layout tests cover onboarding and selected settings screens. A complete inventory-wide visual review, all combinations of states/data, and native device/keyboard behavior remain open. The browser security policy denied the local HTML reference. Device/UI testing is restricted to the specified iPhone simulator, while this repository has only the requested Android and web targets.

Additional matrices cover onboarding, Stories/Discover, P65–P80 settings/profile/support/safety and the remaining wallet sheets/details:

- [Onboarding and Discover](../app/test/onboarding/onboarding_discovery_presentation_test.dart), [Story viewer](../app/test/stories/story_presentation_test.dart), and [retained Discover query](../app/test/discover/discover_query_retention_test.dart).
- [Settings/support/safety](../app/test/acceptance/settings/settings_support_presentation_test.dart), including profile edits, audience/privacy/notifications, recovery, account confirmation, help/legal and report/restriction returns.
- [Remaining wallet presentation](../app/test/wallet/wallet_remaining_presentation_test.dart), including scrolling sheets above the keyboard, ledger pagination/filters/links and withdrawal rejection/recredit.
- [Shared header](../app/test/theme/app_header_test.dart): compact/subtitle heights, long-title truncation, aligned 44 px controls and working back navigation.
