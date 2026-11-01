# Whizpee responsive Flutter UI handoff

This package specifies and demonstrates the Whizpee **client UI prototype**. The approved wide-screen direction is **A — Compact icon rail**. The receiving agent implements the Flutter UI in the existing project named `app`; this package does not contain a completed Flutter application.

The product surface inventory is 80 pages, 21 bottom sheets and 23 dialogs, plus 130 named scenario cases. Reuse the same logical destinations across widths. A desktop pane is a responsive presentation of an existing destination, not a second business object or a new application module.

## Read order and authority

1. Read this document and `README.md` for scope and run instructions.
2. Open `Whizpee_Responsive_Prototype.html` and review representative routes with both themes and all four width classes.
3. Open `Whizpee_Design_System.html`; inspect `design_tokens.json` and `component_specs.json` for exact shared values.
4. Read the relevant `screen_specs/Pxx-*.md`, `screen_specs/Sxx-*.md` and `screen_specs/Dxx-*.md` before implementing a feature.
5. Use `responsive_matrix.json` as the machine-readable presentation mapping. Use `coverage_matrix.csv` and `scenario_matrix.csv` to track actual implementation and verification.
6. Compare the rendered references in `references/` where included. Screenshots illustrate a state; semantic tokens, dimensions, IDs and behavior contracts define the implementation.

User-approved behavior and explicit scope override stale source descriptions. Current corrections are SmobilPay/Maviance with MTN and Orange Mobile Money only; no invitation flows; web has no usable calls or video-compression feature. Native/review call visuals remain available as demonstration surfaces.

## Boundaries

Use English UI, bundled assets, light/dark/system themes, and coherent in-memory entities. Prototype state survives route changes within the session. Reset demo restores the complete initial fixture set. Reloading/restarting may reset the demo.

Do not introduce backend services, real API clients, WebSockets, databases, SQLite, persistence packages, OAuth, payment SDKs, push subscriptions, actual contact sync, live calling, camera capture or microphone recording. Capture, permissions, upload, checkout and financial transitions are mock state machines. The user should see meaningful states and feedback for each visible action.

The HTML prototype is a visual and interaction reference. Implement native Flutter widgets; do not embed HTML in a WebView or use screenshots as screens.

## Existing project and code style

The Flutter project `app` already exists. Inspect its `AGENTS.md`, `pubspec.yaml`, SDK constraints, analysis rules, folder structure, naming, routing, state management and dependency injection. Follow the user's existing code style. If it is fresh starter code, choose one simple consistent approach and implement without creating another Flutter project or running `flutter create` over it.

Use a feature-based structure with each full screen in its own directory. Inner pages stay with the owning feature. Shared app-wide components live in a shared UI/design-system area; feature-shared widgets stay with the feature, and screen-only widgets stay inside that screen's directory.

```text
lib/
  app/
    navigation/
    theme/
  core/
    demo/
    config/
    utilities/
  shared/
    models/
    widgets/
  features/
    onboarding/
    discover/
    stories/
    chats/
    contacts/
    groups/
    calls/
    business/
    publishing/
    creator_tools/
    wallet/
    profile/
    settings/
    support/
    safety/
    prototype_tools/
```

For example, a conversation feature has `ui/screens/direct_conversation_screen/direct_conversation_screen.dart`, local `widgets/`, feature-wide conversation widgets, `ui/sheets/`, `ui/dialogs/`, typed models, controllers and mock fixtures. Adapt the exact naming to the existing project. Do not create one giant screen file or separate direct/group/Business copies of the same conversation UI.

## Typography and asset binding

Use the actual bundled **Roboto** font, not a network font or an unbundled Inter fallback. Files are `assets/fonts/Roboto-Regular.ttf` (400), `Roboto-Medium.ttf` (500), and `Roboto-Bold.ttf` (700). Flutter font family name is `Roboto`; the HTML uses `Whizpee Roboto`. Resolve size, line height, letter spacing and role weight from `design_tokens.json`. Do not request synthesized 550/600/650/750 weights; map normal to 400, medium to 500, bold to 700.

Preserve asset aspect ratio/crop rules. Personal avatars are circular. Business interactions use originating Story covers/public identity. Logo, profile and cover objects have different semantic roles and must not be substituted merely because they share image types.

## Adaptive shell and layout

All dimensions are Flutter logical pixels; browser CSS pixels correspond at 100% zoom. Use available width from constraints rather than device-name or orientation checks. Viewport size is not a source of business state.

| Width class | Range | Shell |
| --- | --- | --- |
| Compact | below 600 | Existing phone layout, bottom navigation on applicable routes, one active content destination. |
| Medium |600–1023 |76-wide compact icon rail and one active content pane. |
| Expanded |1024–1439 |76-wide rail; contextual 336-wide master and flexible detail where the family uses list/detail. |
| Large |1440+ | Expanded composition, with an optional 320-wide chat context panel when explicitly opened. |

Use gutters 20/24/32 for compact/medium/expanded-large. Major sections separate by 24; cards/related controls by 16; labels by 8. Forms are bounded 640. General grids/analytics are bounded 1200; the Profile root overview is bounded 960. Center bounded content in its available content region.

Chats P01 and inner chat/group/Business destinations use the contextual conversation master on expanded/large. P14, P23 and P47 can expose P15, P25 and P48 as their optional large context panel. An Info action opens the corresponding route at smaller widths. Closing the pane restores the initiating focus and leaves thread scroll/caret unchanged.

Calls history P02 and details/summary P28/P33 use history/detail where supported. Native call visual pages remain a separate bounded stage. Status contact/own viewers may keep a 336-wide Status master on expanded/large; a Business Story opened from Discover is a proportionate viewer without the contact-Status master.

P65–P78 use Profile/settings navigation with selected detail on wide layouts. P05 stays an overview. Safety P79/P80 stays a bounded contextual form/notice; do not discard its target or restriction context by forcing unrelated settings selection. Wallet/Publishing keep bounded content rather than acquiring a new administration sidebar.

Discover cards form a responsive grid with explicit card minimum width and gaps; they do not stretch a two-column phone layout indefinitely. Story/media stages use proportional containment. Story viewport max 420 wide with 9:16 target ratio; height constraints can reduce both dimensions. Do not crop away playback, Close or Contact controls.

## Shared component implementation

Map `component_specs.json` to reusable Flutter widgets. At minimum include adaptive scaffold, app bar, compact rail, bottom navigation, button/icon button, form/phone/search controls, chips/badges, avatar/Story cover, list rows, Story cards/viewer controls, message bubbles/quotes/receipts, shared composer, member picker, price summary, balance card, transaction row, state presentation, sheet and confirmation dialog.

Header heights are 56 standard,72 with subtitle,58 conversation. Normal header actions have 44×44 interaction targets and centered 20 icons. Text fields are 48 high minimum; buttons 44. Do not simulate the HTML phone frame, fake system time/status bar or home indicator inside Flutter.

The profile avatar remains in normal layout flow. Only its small camera badge overlays it. The phone prefix selector and local number field occupy one horizontal control; parsing an international `+` or `00` paste updates both parts without duplication and stores one canonical international value.

## Navigation and typed context

Use stable P/S/D IDs for review coverage while implementing idiomatic typed routes. Every conversation route carries conversationId; group carries groupId; Business route additionally carries originatingStoryId; media carries source/message/media IDs; receipts carry transactionId; tracking carries withdrawalId. Do not use an unrelated mutable global selected object as a substitute for route arguments.

Normal tab order is Discover, Chats, Calls, Status, Profile. Onboarding/legal P06–P11 hide the rail and bottom navigation at every width and keep a centered bounded 640-wide content region. Seeded signed-in startup opens Discover P04. Welcome/onboarding remains accessible through sign-out and review tools. Contacts permission decline never blocks onboarding; no mandatory OTP is introduced.

Browser Back must behave as navigation, not as a fresh initial page load. Maintain a meaningful URL/hash route and entity/query context in Flutter web. Back first dismisses the top dismissible modal, otherwise returns to the contextual source or previous location. Avoid duplicate history entries from purely cosmetic resizes/theme changes. Preserve selected tab, list filters, scroll, query and draft where appropriate. A deep link with an unavailable ID shows a safe unavailable state and a relevant return action.

Each master pane, detail body and message thread owns bounded scrolling. Do not put the entire desktop shell in one page scroller. The composer/header remain fixed while thread history scrolls. Lists retain their context while detail selection changes. Update only the necessary observable state so typing does not lose focus or caret.

## Overlay mapping

Every overlay has its own specification and explicit input/commit/cancel rules.

| IDs | Compact | Medium/expanded/large |
| --- | --- | --- |
| S01–S03, S05–S09, S11–S21 | Bottom sheet, full available width, top radius 21, max 90% safe viewport height. | Centered sheet, max 480, outer clearance 24. |
| S04 | Attachment bottom sheet. | Centered attachment sheet, max 640. |
| S10 | Nonblocking minimized-call card within safe viewport. | Nonblocking top-right card, max 360. |
| D01–D23 | Centered dialog, available width minus 48, max 85% safe height. | Centered dialog, max 420, outer clearance 24. |

S09/S10/S11/D12 are call native/review-only on web. S16 normal web Business contact exposes Message, with call capabilities unavailable. D11 call-history deletion remains usable on web. Avoid pretending a desktop sheet is an anchored popover unless the final implementation explicitly changes its mapping and corresponding specification.

Modal overlays dim the background, trap focus, offer a labelled Close or Cancel and restore initiating focus. Their body may scroll without making confirm/cancel inaccessible. Escape dismisses only an eligible top overlay; Enter activates the focused action, never an unrelated destructive confirmation.

S21 privacy choice follows the actual prototype: selecting an option commits immediately and closes. Cancel dismisses without a new change. There is no uncommitted privacy draft that a missing Save would lose.

## Shared in-memory state and lifecycle

Use one coherent in-memory source of truth for profiles, contacts, groups, messages, Stories, publications, wallet balances, transactions, requests, mock permissions and call sessions. Keep IDs and relationships explicit. Controllers hold state; widget builds do not start timers or perform mutations.

Use typed enums/state objects for upload, delivery, call, publication, payment, conversion, withdrawal and restriction states. Use a controllable mock clock for expiry and call billing. Dispose timers/focus/controllers correctly and never update disposed widgets. Minimized sessions outlive a screen widget, and returning to a page must not restart their timer.

Layout, navigation, refreshing a receipt and selecting another pane are read operations. They must not create messages, rooms, charges, reward conversions, publication debits or withdrawal requests. Every simulated operation has an explicit stable operation reference or applied guard.

## Conversation behavior

Direct/group/Business conversations share one layout with contextual identity and permission inputs. Consecutive same-author messages have close grouping; new-author groups have larger separation. Use inline timestamps and appropriate receipts, sender names in group bubbles, quoted-message author/source, reactions and deleted markers. Bubble max width is `min(82% of usable thread width,520)` in compact mode and `min(65%,520)` from medium mode. Timestamp typography is 10/14.

The composer has one rounded pill with emoji, bounded multiline input and paperclip; one external circular action switches immediately between microphone and Send based on nonempty input. Its textarea is 44–120 high, body 14/20 with 12 vertical padding; pill is 48–124; external action 44 and pill/action gap 8. Outer padding is 8 top, 12 bottom and 12 inline, so its total is 68–144 excluding reply/emoji content and host safe inset. The generic app body remains 14/21; conversation body is a separate intentional 14/20 role. Hardware Enter sends; Shift+Enter inserts a line break. Insert emoji at the current caret. Reply/edit cancellation restores normal composer state. Recording/locked recording/cancel/stop/send are meaningful mock states.

Only eligible own messages can be edited/deleted for everyone. Deleting for everyone retains a marker; deleting for me removes the local row. Offline queue, failed send and attachment retry retain IDs rather than creating duplicates. Message search, stars, forwarded context and receipt pages link back to the correct original entity.

Groups enforce owner/admin/member roles, membership and permissions. Existing members are not added twice. Transfer owner before owner departure when required. Removed/left membership retains permitted read-only history. Group role perspective is separate from Business customer/recipient perspective.

## Business rooms and calls

A paid Business room is bound to its originating Story and public Business identity. One room open costs 10 Credits for 24 h, with no per-message charge. Active room re-entry costs zero; the recipient can reply without purchase. Source Story expiry does not end the active room. Expired rooms are read-only; reopening requires an eligible source, remaining configured cap, sufficient balance and explicit confirmation. Missing source/cap states explain why reopening is unavailable.

Personal native contact calls are free; Business audio 15/video 25 Credits per started 60-second block only after answer. Ringing, busy, declined and unanswered outcomes cost zero. The incoming recipient is never charged. Warn before an unaffordable next block, then stop at the current paid boundary. Resize/minimize/return/repeated End cannot duplicate debit or ledger entry. Normal web flows do not start/answer calls; native/review mock pages demonstrate their visual states.

## Publishing rules

Category, Boost and advertisement fees are additive. Example paid-category video/audio advertisement is 5+50+100=155 Credits. Video/audio publications require Boost; photo Boost is optional. A paid-category photo Status still consumes an image slot; category payment never creates another slot. Lifetime is 24 h ordinary,48 h Boost plus one eligible 24 h extension, maximum 72 h.

Changed configuration requires a refreshed itemized review before confirmation. Failed publication keeps category, media, caption and targeting. Success creates the publication, debits Credits and changes applicable quota once. Discover browsing and ad creation/targeting stay separate. Contact Story viewers are privacy-permitted identities; promoted views use aggregate analytics. Qualified unique views determine Popular; self/suspicious views are excluded or held.

## Wallet rules

Credits fund app actions, Diamonds are rewards, Cash is withdrawable. Pending/frozen Diamonds are unavailable for conversion. Do not merge units or turn a Credit purchase into a Cash withdrawal balance.

SmobilPay/Maviance checkout uses MTN or Orange Mobile Money. Processing/pending adds no Credits; confirmed applies once per payment reference. Preserve the interrupted action and return to its review/confirmation context; a top-up does not silently authorize another paid action.

Conversion validates available Diamonds, shows the rate/net Cash and confirms once. Example 1 Diamond → 5 XAF. Debit Diamonds and credit Cash once, with matching activities. Withdrawal validates minimum 1000 XAF example, available Cash, destination type, fees and configured frequency. Show amount/fee/net. Create/debit one request; track Pending → In Progress → Approved → Paid with Rejected/Failed alternatives. If appropriate, recredit a previously debited failed/rejected payout once. Viewing/refreshing tracking is not another refund.

## Scenario and review tooling

Prototype tools are a separate review interface, not a client administration module. They should open every P/S/D surface, select the 130 named cases, change themes/widths/perspectives, set online/offline and mock outcomes, advance time, and reset the complete demo. Ordinary user flows do not show developer explanations or scenario buttons.

A scenario is implemented only when its stated visual state and available actions are demonstrated. A changed label or generic toast does not fulfill a loading/failure/read-only state. Matrices distinguish source registration, documented contract and actual verification; never convert them all to Passed without running the checks.

## Completion and validation for the Flutter agent

Run formatting, Flutter analysis, meaningful state/widget tests and builds supported by the host. Test route context and shared interactions, plus idempotent payment/room/call/publication/withdrawal transitions. Do not create hundreds of title-only tests.

Review at least 320×640,386×802,430×900,768×1024,1280×900 and 1600×1000; use light/dark/system, keyboard open, pointer/keyboard navigation and increased text size. Check wrapping/overflow, avatar/header alignment, prefix-number behavior, fixed composer, independent pane scroll, focus restoration and breakpoint stability.

Verify all 124 surfaces and 130 named cases against the per-surface specs. Record the target and actual result, including genuine tooling limitations. State unavailable Android/iOS host tooling instead of claiming unrun builds. Deliver the actual Flutter project, run commands, available build paths, completed coverage and concise remaining limitations.
