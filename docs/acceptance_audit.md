# Prototype acceptance audit

Full prototype acceptance remains open. At the publication checkpoint, formatting, analysis, 750 Flutter tests, the self-contained web build and Android debug build passed. The statuses below record current evidence; a passing focused test does not prove a requirement that spans every route, state, viewport or platform.

| Criterion | Current evidence and remaining work |
| --- | --- |
| 1. Seeded Discover start | Covered by app and Discover widget tests; full presentation review remains open. |
| 2. Tabs and inner routes | Five tabs and many contextual routes are tested; all routes and return contexts still need a complete audit. |
| 3. Sheets and dialogs | Reusable contextual flows and cancel/confirm tests exist; every entry, target, and return path is not yet verified. |
| 4. Onboarding and contacts choices | Both sign-in providers, profile validation, phone/interests and accepted/declined contacts complete in viewport/theme matrices; legal/cancellation and matching retry also have tests. Native acceptance remains open. |
| 5. Phone composition | Pasted international prefixes, empty and invalid values have focused tests; exhaustive country/code cases remain open. |
| 6. Profile avatar positioning | Onboarding responsive widget checks cover layout; all profile variants and real-device verification remain open. |
| 7. App-bar alignment | Shared AppHeader tests verify compact/subtitle height, long-title truncation and aligned 44 px controls; feature matrices exercise its adoption. Native rendering remains unverified. |
| 8. Chat focus and mic/send | Composer tests cover focus, sending, and session draft retention; keyboard behavior across every conversation variant remains open. |
| 9. Chat actions and receipts | Reply/edit/delete/forward/reaction, uploads, mentions and group receipt tests exist; all combinations and review scenarios remain open. |
| 10. Group changes | Role, permission, mutual matching, member selection, contact rename and membership tests exist; full scenario acceptance remains open. |
| 11. Business Story identity | Story-keyed room and shared chat tests cover blocked and restricted read-only behavior; all identity and return paths require further review. |
| 12. Active room no repeat charge | Controller tests cover active-room reuse, Popular changes and reentrant opening without duplicate debit; complete end-to-end acceptance remains open. |
| 13. Unanswered calls cost zero | Controller and minimized-call tests cover zero-charge unanswered outcomes; complete UI acceptance remains open. |
| 14. Business call charging | Controller tests cover paid blocks, insufficient funds and minimized state; presentation tests exercise call controls, low-balance warning, minimize/return/end and incoming outcomes. Other transitions and native acceptance remain open. |
| 15. Publishing totals and quotas | Controller tests cover the 155-Credit example, slots, changed price and retry; complete flow and every publication variant remain open. |
| 16. Payment credit timing | Wallet tests cover pending, one-time confirmation, and interrupted top-up return after Back; other return contexts remain open. |
| 17. Diamond conversion | Wallet tests and presentation flows cover available/pending/frozen balances, rate changes, failure, retry and one-time conversion; native behavior and additional data combinations remain open. |
| 18. Withdrawal recredit | Wallet tests cover rejected/failed one-time recredit, history/detail/timeline links and configured limits across presentation matrices; native acceptance remains open. |
| 19. Theme coverage | Theme switching, shared button styling and feature presentation matrices cover both themes; all remaining surfaces and state combinations still need review. |
| 20. Responsive and keyboard layouts | Presentation matrices exercise main chat, publishing, Business/call and key wallet/settings flows at all required sizes in both themes, with enlarged text and relevant keyboard insets; see [coverage](presentation_acceptance.md). Remaining inventory-wide and native rendering review is open. |
| 21. Reset | Integration tests cover seeded reset, drafts, connectivity and sign-out during a call; other active-session combinations remain open. |
| 22. Offline operation | Source inspection shows no application HTTP/database dependencies; one widget navigation test rejects HTTP-client creation. Full Android/web offline runtime acceptance remains open. |

Feature English copy lives in feature/app/shared copy catalogs with typed parameterized messages. Shared scaffold, person/form/search/section/state components, conversation layout, avatars, Story controls and price breakdowns are adopted. Key filters/call/wallet decisions use typed state. The latest bounded source review corrected public Business metadata, group photos/creation retry/member previews/info actions, chat media editing, reporting, file metadata, unsent receipts, global identity search, original publication terms, Business message actions and incoming video previews. See the [component inventory](component_inventory.md) and [remaining acceptance work](remaining_work.md).

Publication validation from `app/`:

- `dart format lib test` — 387 files, no further changes.
- `flutter analyze` — no issues.
- `flutter test --reporter expanded` — 750 passed.
- `flutter build web --no-web-resources-cdn` — passed; output `app/build/web/`.
- `flutter build apk --debug` — passed; output `app/build/app/outputs/flutter-apk/app-debug.apk`.

The web bootstrap points renderer and optional font fallback requests at local assets. Roboto, Noto Emoji and Noto Sans Symbols are bundled with their licenses. Static inspection confirms all 28 non-ASCII codepoints currently in application source are covered. This is packaging evidence, not a browser/device offline-runtime test.

No device/UI test has been run. The specified iPhone 17 Pro simulator is available, but this project has only the Android and web targets requested earlier. The local HTML reference could not be visually inspected because browser security policy denied access; visual fidelity is therefore not established.
