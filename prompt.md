You are implementing the complete **Whizpee mobile UI prototype** inside an existing, freshly created Flutter project named **`app`**.

Implement the app now. Do not stop at planning, scaffolding, a few example screens, or a collection of disconnected mockups. Continue until the complete prototype is navigable, interactive, tested, and ready for presentation.

## 1. Objective and boundaries

Build a polished Flutter demonstration app that reproduces Whizpee’s approved design and simulates its complete client experience.

The scope contains:

- **80 full pages, including the five main tabs.**
- **21 bottom sheets.**
- **23 dialogs.**
- **124 product surfaces in total.**
- **130 named scenario/state cases**, listed below. These are states of existing screens, not 130 additional pages.

Mandatory requirements:

- English UI.
- Light, dark, and system appearance.
- The same custom visual design on Android and iOS.
- Fully navigable inner pages, sheets, dialogs, and contextual flows.
- Shared widgets, shared design tokens, and reusable feature components.
- Each screen in its own directory.
- Feature-based UI organization, including each feature’s inner screens.
- Stateful simulations that remain consistent while navigating.
- Local bundled assets and in-memory mock data.

This is **client prototype scope only**.

Do not implement:

- Any backend or server.
- API clients, HTTP requests, WebSockets, or real-time infrastructure.
- SQLite, Drift, Hive, Isar, ObjectBox, or any other database.
- SharedPreferences, secure storage, or other application-state persistence.
- Firebase, Supabase, Appwrite, or similar services.
- Real OAuth, payments, withdrawals, calls, contact synchronization, notifications, camera capture, or microphone recording.
- An application administration module.

Group **owner/admin/member** roles are part of the client experience. They do not mean an Admin app.

Use RAM-only models, controllers, mock services, timers, simulated delays, and deterministic fixtures. Changes must survive navigation during the session. Restarting the app or choosing **Reset demo** may restore the fixtures.

Bundled image, SVG, font, audio, and video assets are allowed. Do not confuse bundled assets with database or state persistence.

## 2. Inspect the existing project and follow my code style

The Flutter project already exists and its name is `app`.

Before implementation:

1. Read the repository instructions, including `AGENTS.md` if present.
2. Inspect `pubspec.yaml`, analysis rules, installed Flutter/Dart versions, existing files, naming conventions, and any established architecture.
3. **Follow my existing code style and conventions.**
4. Reuse existing state-management, routing, dependency-injection, and theme conventions where present.
5. If the project is genuinely fresh and contains only starter code, choose a simple, consistent structure and proceed without asking me to select an architecture.

Do not:

- Run `flutter create` over the existing project.
- Create a second Flutter project inside it.
- Replace platform configuration unnecessarily.
- Introduce multiple competing state-management approaches.
- Add elaborate production infrastructure for a mock application.
- Put the entire app, all screens, or all state in one giant Dart file.

Use native Flutter widgets. **Do not wrap the HTML prototype in a WebView, display screenshots as screens, or render the app through embedded HTML.**

## 3. Reference and source priority

Look for these reference assets in the workspace or attachments:

- `Whizpee_UI_Prototype.html`
- The supplied Whizpee logo.
- Supplied screenshots.

The latest HTML prototype contains embedded design information and inventory under:

- `whizpee-design-spec`
- `whizpee-inventory`

If available, inspect its visual appearance, interactions, embedded assets, screen inventory, and scenario definitions. Extract reusable assets into the Flutter asset structure.

This prompt is also a standalone implementation specification. If references are unavailable, continue from the requirements here. Do not leave screens unfinished while waiting for references.

Priority:

1. Explicit requirements in this prompt.
2. The latest supplied prototype and screenshots.
3. Older source descriptions.

Two corrections override stale inventory wording:

- Payments use **SmobilPay/Maviance with MTN Mobile Money and Orange Mobile Money only**. Do not add PayPal or VISA.
- Invitation systems are outside this scope. An empty contacts state may offer Add contact or permission recovery, but do not invent invitation links or invitation flows.

Reproduce the intended experience while fixing layout defects or incomplete interactions. Do not reproduce known bugs.

## 4. Visual direction

The approved direction is **“A — Familiar & compact.”**

The app should feel familiar to a WhatsApp user while retaining Whizpee’s identity and features:

- Teal accents.
- Clear typography.
- Compact conversation lists.
- Restrained cards and borders.
- Circular personal avatars.
- Story-cover imagery for Business interactions.
- Carefully aligned titles, icons, labels, fields, and actions.
- Consistent spacing across parent and inner screens.

Use one custom design across Android and iOS. Flutter framework infrastructure may be used, but visible controls must follow our design rather than default Material or Cupertino styling.

### Theme tokens

Centralize these values. Do not scatter colors throughout screen files.

| Token | Light | Dark |
|---|---|---|
| Brand/accent | `#087F70` | `#64D9B8` |
| Page background | `#FFFFFF` | `#12211B` |
| Surface | `#FFFFFF` | `#192C22` |
| General canvas | `#F2F5F3` | `#0E1C16` |
| Primary text | `#192D28` | `#E5EEE7` |
| Secondary text | `#728179` | `#9BAD9E` |
| Border/divider | `#E8EEEA` | `#293C2E` |
| Conversation background | `#F1F6F5` | `#101F20` |
| Incoming chat bubble | `#FFFFFF` | `#203333` |
| Outgoing chat bubble | `#DAF2ED` | `#14514E` |

Use the conversation-specific colors for chat bubbles. Do not copy the green palette from the chat reference or use the older generic green outgoing token.

Typography guidance:

- Inter when available as a bundled font; otherwise a consistent readable sans-serif.
- Typical body text: 14 logical pixels.
- Labels: approximately 12.
- Captions: approximately 11.
- App-bar titles: approximately 20.
- Preserve hierarchy and accessibility rather than rigidly forcing every text element to the same size.

General geometry:

- Centralized spacing scale: 4, 8, 12, 16, 20, 24.
- Consistent content gutters around 19–20 logical pixels.
- Buttons around 9–12 radius.
- Cards around 12 radius.
- Rounded conversation bubbles with grouping-dependent corners.
- Properly sized touch targets.

### App bars

- Normal app bar: approximately **56 logical pixels**.
- App bar with subtitle: approximately **72**.
- Chat header: approximately **58**.
- Back buttons and normal app-bar icon actions use **44 × 44** touch areas.
- Center icons inside their touch areas.
- Keep title and action centers aligned.
- Long titles should truncate appropriately instead of overlapping actions.
- Respect the real device’s safe areas and system bars.

Do not reproduce the desktop HTML phone frame, fake `9:41` status bar, or fake home indicator inside the Flutter app. Those were presentation framing, not product UI.

### Profile photos

Keep the avatar in normal layout flow and centered beneath the app bar.

Only the small camera badge should overlay the avatar. Do not accidentally position the entire avatar absolutely or let it overlap the title.

### Phone entry

On profile completion and profile editing:

- Country-code selector and local phone input share one horizontal control.
- Prefix is on the left, local number on the right.
- Country selection updates the prefix without duplicating it.
- Pasting a full `+` or `00` international number updates both parts correctly.
- Keep a full international phone value in the in-memory profile model.
- Empty and invalid input must produce appropriate validation.

### Responsive behavior

Verify at least:

- 320 × 640.
- 386 × 802.
- 430 × 900.

Support scrolling where appropriate, keyboard insets, safe areas, and text scaling. Do not reserve permanent scrollbar width that shifts centered content.

Call controls and the chat composer must remain accessible on short phones.

## 5. Navigation and initial state

Main tab order must be:

1. **Discover — P04**
2. **Chats — P01**
3. **Calls — P02**
4. **Status — P03**
5. **Profile — P05**

The seeded, signed-in prototype opens on **Discover**.

Onboarding must still be fully accessible through sign-out or prototype tools:

Welcome → Complete profile → Choose at least three interests → Contacts explanation → Discover.

Declining contacts permission must not block onboarding.

Do not require OTP verification during onboarding.

Use appropriate full-screen routes for conversations, calls, media viewers, and Story viewers. Do not blindly keep the bottom tab bar visible on every inner page.

Preserve:

- Back navigation.
- Selected tab and list context.
- Drafts and form values when appropriate.
- Contextual return destinations.
- Selected Story, publication, transaction, member, or conversation IDs.

Use typed route arguments or an equivalent clear mechanism. Do not rely on unrelated global “currently selected” objects that leak one screen’s context into another.

## 6. Feature-based code organization

Follow existing project conventions, but preserve this structure conceptually:

```text
lib/
  app/
    app.dart
    navigation/
    theme/

  core/
    config/
    demo/
    utilities/

  shared/
    widgets/
    models/

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

Inside a feature, organize its UI approximately like:

```text
features/chats/
  models/
  controllers/
  data/
    mock/
  ui/
    screens/
      chats_screen/
        chats_screen.dart
        widgets/
      direct_conversation_screen/
        direct_conversation_screen.dart
        widgets/
      contact_info_screen/
        contact_info_screen.dart
        widgets/
    sheets/
      message_actions_sheet/
      attachment_sheet/
    dialogs/
      delete_message_dialog/
    widgets/
```

Adapt names to my coding style.

Requirements:

- Every full screen has its own directory.
- Feature inner screens stay with their feature.
- Sheets and dialogs belong to their relevant feature unless genuinely shared.
- Screen-only widgets remain local to that screen.
- Feature-wide widgets are shared within that feature.
- App-wide widgets live in the shared design system.
- Avoid unnecessary one-line wrapper widgets and unnecessary architectural layers.
- Keep business simulation logic out of widget build methods.

Create reusable components for at least:

- App scaffold and app bar.
- Bottom navigation.
- Buttons and icon buttons.
- Form fields, phone field, dropdowns, validation messages.
- Search bars and filter chips.
- Section headings and list rows.
- Personal avatar, Business Story cover, profile photo editor button.
- Conversation list row.
- Shared conversation layout.
- Message bubbles, timestamps, receipts, quotes, reactions.
- Composer, emoji tray, voice-recording controls, attachment previews.
- Contact/member picker and member rows.
- Story cards, progress segments, and Story viewer controls.
- Publication price breakdown.
- Balance cards, ledger rows, transaction receipts.
- Loading, empty, error, offline, and success states.
- Bottom sheets and confirmation dialogs.

Direct, group, and Business chats must reuse a shared conversation UI while supplying their own identity, permissions, and room context.

## 7. Complete page inventory

Implement all IDs below. These are distinct navigable destinations or clearly defined modes of the specified shared destination.

### Main tabs

- **P01 — Chats:** All, Unread, Contacts, Groups, and Business filters; unread indicators, search, archive access, and floating new-chat action.
- **P02 — Calls:** Recent, missed, and Business call filters; call history and start-call entry.
- **P03 — Status:** Own Status, contact updates, seen updates, rectangular previews/rings, create entry, and Discover preview.
- **P04 — Discover:** Eligible promoted Stories and advertisements; Boosted, Sponsored, and Popular presentation; category browsing and search.
- **P05 — Profile:** Personal identity, Wallet summary, Business tools, Publishing, My Publications, earnings, settings, and support.

### Onboarding

- **P06 — Welcome/sign-in:** Whizpee branding, simulated Google/Apple sign-in, Terms, Privacy, and progress/failure/cancellation.
- **P07 — Complete profile and phone:** Photo, name, side-by-side prefix/local phone field, gender, consent, validation, and Continue.
- **P08 — Interest selection:** At least three onboarding interests; edit mode; reusable single-interest advertisement-targeting mode.
- **P09 — Contacts access explanation:** Mutual matching explanation, Allow/Not now, matching progress, denied and empty results.
- **P10 — Terms of Service:** Readable prototype legal content and return navigation.
- **P11 — Privacy Policy:** Readable privacy content and return navigation.

### Chats and contacts

- **P12 — Contacts/recipient picker:** Single selection for chat/call; multiselect for group creation, adding members, forwarding, and audience selection. Include search, selected chips, existing-member states, and a full-width continuation footer.
- **P13 — Chat/message search:** Global or conversation-scoped search; query retention; meaningful results and jump-to-message behavior.
- **P14 — Direct conversation:** Complete text/media/document/voice-note conversation with message actions, receipts, reply/edit, reactions, and call entries.
- **P15 — Contact/direct-chat info:** Permitted identity, phone/about, shared content, starred messages, search, mute, block/report, and history actions.
- **P16 — Shared media/files/links:** Segmented browser reused by direct, group, and Business chats.
- **P17 — Media viewer:** Photo/video/audio presentation, relevant playback/zoom controls, and return to source.
- **P18 — Message details/receipts:** Sent/delivered/read information; group Read by and Delivered to lists.
- **P19 — Archived chats:** Open, unarchive, and empty state.
- **P20 — Starred messages:** Global/conversation modes, jump to original message, and unstar.
- **P21 — Add/edit contact:** Name/phone, validation, duplicate feedback, and simulated device-contact handoff.
- **P22 — File preview:** File metadata, supported/unsupported preview, simulated download/open, and source-message link.

### Groups

- **P23 — Group conversation:** Sender names, mentions, system events, normal messaging features, and permission-aware composer.
- **P24 — Create/edit group details:** Photo, name, description, selected members, validation, submission, and retry.
- **P25 — Group info:** Identity, description, shared content, member preview, mute, permissions, add members, and leave/delete actions.
- **P26 — Group members:** Search, owner/admin/member badges, role-aware member actions, add-member entry, and ownership-transfer selection mode.
- **P27 — Group permissions:** Who can send, edit group details, and manage membership; role-aware behavior.

### Calls

- **P28 — Call details:** Participant, type, direction, result, duration, call-again/message actions, and Business Story/cost context.
- **P29 — Outgoing/ringing call:** Personal/Business and audio/video variants, cancel, ringing progress, busy/declined/unanswered outcomes.
- **P30 — Incoming call:** Correct identity, audio/video variants, answer/decline, and relevant preview.
- **P31 — Active audio call:** Timer, mute, output, minimize, end, reconnecting, and Business payer information.
- **P32 — Active video call:** Mock remote/self preview, microphone/camera controls, switch camera, minimize, and end.
- **P33 — Call summary:** Result, duration, actual simulated cost, reason, and next actions.

### Stories and Discover

- **P34 — Full-screen Story viewer:** Own/contact/Business modes; photo/video/audio; progress segments; next/previous; hold/pause; mute; options; eligible Business contact.
- **P35 — Discover search/results:** Query/category filtering, promoted results, retained refinements, and empty state.
- **P36 — Public Business profile:** Public identity, cover/logo, category, description, optional public location, active eligible Stories, and own-profile edit entry where appropriate.

### Publishing

- **P37 — Publishing hub:** Create Status, Create Advertisement, and My Publications.
- **P38 — Category selection:** Name/icon/description, free/paid labels, and category fee before continuing.
- **P39 — Media library picker:** Photo/video/audio modes, bundled sample selection, and simulated permission/import states.
- **P40 — Camera capture:** Mock photo/video capture, camera switch, capture/retake, and context-sensitive return.
- **P41 — Photo preview/editor:** Visible crop/rotate simulation, caption, replace, cover editing, and Story/chat contexts.
- **P42 — Video preview/editor:** Playback, trim-range simulation, caption, replace, and mandatory-Boost context for publications.
- **P43 — Audio recorder/preview:** Record/pause/stop, timer/waveform, import, playback, re-record, cover selection, and mandatory Boost.
- **P44 — Publication price review:** Itemized category/Boost/ad fees, total, balance, slot usage, lifetime, configuration-change review, and confirmation.
- **P45 — Advertisement audience targeting:** Geography, gender, one interest, and audience summary.
- **P46 — Targeting location/radius:** Country/city/neighborhood/radius, schematic map/manual selection, and denied-location fallback.

### Business conversations

- **P47 — Business conversation:** Originating Story cover, payer/recipient modes, room expiry, full chat UI, active/free-within-room messaging, and expired read-only history.
- **P48 — Business conversation info:** Originating Story, public Business identity, room terms, expiry, eligible reopening, shared content, and report/block.

### Creator tools

- **P49 — My Publications:** Statuses/ads, filters, active/expired/removed states, viewer/details/analytics actions, and creation entry.
- **P50 — Publication details:** Media, type/category, lifetime, original commercial terms, status, and relevant statistics.
- **P51 — Story viewers:** Permitted viewers and timestamps for owned contact Stories; promoted content directs to aggregate analytics.
- **P52 — Promotion analytics:** Total/qualified unique views, Popular progress, aggregate engagement, charts, and Diamond rewards.
- **P53 — Promotion contact activity:** Originating-Story conversation/call activity and links to relevant rooms or call details.

### Wallet

- **P54 — Wallet overview:** Separate Credits, Diamonds, and Cash; available/pending/frozen presentation; purchase/convert/withdraw entries.
- **P55 — Balance activity:** Separate ledger modes, correct units, filters, pagination/load-more simulation, and empty state.
- **P56 — Transaction details:** Amount/unit/direction, reference, date, status, explanation, and related activity.
- **P57 — Buy Credits:** Packages/custom amount, estimate, selected payment method, and interrupted-action context.
- **P58 — Payment review:** Credits, amount/currency, method, phone, and simulated provider handoff.
- **P59 — Payment status:** Processing/pending/failed/cancelled/confirmed, refresh/retry, one-time credit, and contextual return.
- **P60 — Convert Diamonds:** Available versus pending/frozen, quantity, rate, Cash received, validation, and review.
- **P61 — Withdrawal form:** Cash amount, minimum, configured fees/frequency, payout method/destination, and validation.
- **P62 — Withdrawal review:** Amount, fee, net payout, method/destination, and confirmation.
- **P63 — Withdrawal history:** Requests, dates/amounts, filters, and status presentation.
- **P64 — Withdrawal details/tracking:** Pending, In Progress, Approved, Rejected, Paid, failure/recredit, timeline, reason, and reference.

### Profile, settings, and support

- **P65 — Edit personal profile:** Private photo/name/about, side-by-side phone field, gender/interests, validation, and Save.
- **P66 — Edit Business profile:** Public name, logo/cover, category, description, optional location, validation, and Save.
- **P67 — Settings:** Entries to all settings, account, permissions, support, and appearance screens.
- **P68 — Privacy settings:** Photo visibility, Story audience, read receipts, blocked accounts, and explanations.
- **P69 — Status audience:** Contacts options, exclusions/selected contacts, shared picker, and Save.
- **P70 — Notification settings:** Message/group/call preferences, previews/vibration where shown, and simulated permission status.
- **P71 — Appearance:** Light/dark/system, preview, and readable typography controls.
- **P72 — Permissions/contact sync:** Contact matching status; camera/microphone/media/location/notification mock permissions; recovery.
- **P73 — Blocked accounts:** Personal/Business identities, search, empty state, and unblock confirmation.
- **P74 — Account settings:** Mock linked sign-in, phone information, sign out, and delete-account entry.
- **P75 — Help/support:** Searchable topics and support entries.
- **P76 — Help article:** Reusable readable article details and back navigation.
- **P77 — About Whizpee:** Logo, version, app information, Terms, and Privacy links.
- **P78 — Delete-account explanation:** Consequences, required acknowledgement, and final-confirmation entry.

### Safety

- **P79 — Report form:** Correct Story/account/chat context, reason, optional explanation, submitting/success/failure.
- **P80 — Account restriction notice:** Warning/suspension/ban, reason, applicable restrictions, and support route.

## 8. Complete bottom-sheet inventory

Implement all 21 sheets with appropriate scroll behavior, keyboard handling, safe areas, dismissal, and contextual data.

- **S01 — Phone country-code picker:** Search countries/codes and update the shared phone control.
- **S02 — Chat-list actions:** Pin/unpin, archive/unarchive, mute, mark read/unread, starred messages, delete.
- **S03 — Message actions:** Reply, copy, permitted edit/delete, forward, star/unstar, pin/unpin, reactions, and information.
- **S04 — Attachment tray:** Photo/video, camera, document, audio, contact, and gallery entries.
- **S05 — Media source/photo actions:** Camera, library/import, replace, remove; context-aware reuse.
- **S06 — Mute-duration chooser:** Supported durations and unmute.
- **S07 — Reaction picker:** Expanded choices and remove own reaction.
- **S08 — Group member actions:** View, message, promote/demote, remove, transfer; role-aware.
- **S09 — Audio-output chooser:** Simulated earpiece/speaker/device options.
- **S10 — Minimized-call overlay:** Persistent call context, ongoing timer, return, and end.
- **S11 — Business call preflight:** Rate, balance, affordable duration, and confirmation.
- **S12 — Story options:** Public profile, report/block, or own-publication actions.
- **S13 — Boost explanation/options:** Optional photo Boost, mandatory video/audio Boost, price, lifetime, and Continue.
- **S14 — Publication actions:** Open, details, appropriate viewers/analytics/contact activity, and delete.
- **S15 — Target-area chooser:** Country/city/neighborhood selection.
- **S16 — Business contact selector:** Message room, audio call, video call, prices, and existing-room shortcut.
- **S17 — Insufficient Credits:** Required/current/missing amount, Buy Credits, Cancel, and preserved return context.
- **S18 — Payment-method chooser:** **SmobilPay/Maviance: MTN Mobile Money and Orange Mobile Money only**, with applicable phone details.
- **S19 — Diamond conversion review:** Quantity, rate, resulting Cash, and confirmation.
- **S20 — Payout-method chooser:** Configured mock payout methods, destination type, and fee explanation.
- **S21 — Private-photo visibility:** Supported privacy options, current selection, Save/Cancel.

## 9. Complete dialog inventory

Implement all 23 dialogs:

- **D01 — Discard unsaved changes.**
- **D02 — Delete message:** Delete for me; delete for everyone only for an eligible own message.
- **D03 — Delete conversation.**
- **D04 — Clear conversation history.**
- **D05 — Delete device contact:** Simulated device-contact management handoff.
- **D06 — Leave group:** Handle required owner transfer.
- **D07 — Remove group member.**
- **D08 — Promote member to admin.**
- **D09 — Demote group admin.**
- **D10 — Transfer group ownership.**
- **D11 — Delete call-history entry.**
- **D12 — Low paid-call balance warning.**
- **D13 — Delete own publication.**
- **D14 — Price/configuration changed:** Show refreshed terms before another confirmation.
- **D15 — Image-slot limit reached.**
- **D16 — Open/reopen paid Business room.**
- **D17 — Business interaction limit reached.**
- **D18 — Cancel in-progress payment.**
- **D19 — Sign out.**
- **D20 — Final account deletion.**
- **D21 — Block account/Business.**
- **D22 — Unblock account/Business.**
- **D23 — Permission recovery guidance:** Simulated Open Settings action.

Dialogs must identify the correct target and consequences. Cancel must preserve the previous state.

## 10. Functional simulation requirements

### General behavior

Every visible interactive control must do something meaningful:

- Navigate to the correct destination.
- Open the correct sheet/dialog.
- Update in-memory state.
- Start/stop a relevant simulation.
- Show specific validation or actionable feedback.

Do not use the same generic “Coming soon” toast for unimplemented controls.

Use coherent mock state machines. Implement loading, success, failure, retry, cancellation, empty, blocked, and read-only variants where relevant.

A retry must preserve input and context and must not create duplicate messages, publications, requests, charges, or ledger entries.

### Seed data

Provide attractive, realistic fixtures across all features:

- Personal profile: Alex Morgan.
- Example contacts: Sarah Wilson, Amira Hassan, John Davis, Karim Diallo, Maya Chen, Leo Martin.
- Group: Design Team, with owner/admin/member examples.
- Businesses/Stories such as Maison Studio, Daily Brew, Made Local, and Green Corner.
- Different media types, message states, publication states, call outcomes, transactions, and withdrawal statuses.
- Enough data to demonstrate scrolling, searching, filtering, and empty-state switching.

Opening balances/configuration:

- 3,000 Credits.
- 350 available Diamonds.
- 40 pending Diamonds.
- 0 frozen Diamonds.
- 1,000 XAF Cash.
- Photo Status slots: 2 used out of 3.
- Paid-category example: 5 Credits.
- Boost: 50 Credits.
- Advertisement fee: 100 Credits.
- Popular threshold: 50 qualified unique views.
- Conversion example: 1 Diamond → 5 XAF.
- Credit-purchase estimate: 10 XAF per Credit.
- Withdrawal minimum: 1,000 XAF.

Keep configurable mock prices, quotas, limits, fees, and durations in one configuration model, not in individual widgets.

### Contacts and onboarding

- Free contact communication requires mutual address-book matching.
- Simulate matching with fixture relationships.
- Declined permission does not block registration.
- Do not read or modify the actual device address book.
- Add/edit/delete-device-contact routes demonstrate their intended handoff.
- No mandatory onboarding OTP.
- Interest selection supports onboarding minimum three and targeting maximum one.
- Profile changes update all appropriate in-session views.

### Conversations

Use the latest approved chat design:

- Close grouping of consecutive messages.
- Incoming/outgoing alignment and grouping-dependent corners.
- Inline timestamps and appropriate sent/delivered/read indicators.
- Group sender names inside bubbles.
- Quotes containing author and source text.
- Text wrapping, Unicode, multiline messages, captions, attachments, and reactions.
- Centered day separators and appropriate system messages.
- Visually distinct deleted-message markers.

Composer:

- One rounded pill with emoji action, multiline field, and paperclip.
- One circular action outside the pill.
- Empty field shows microphone; nonempty field shows Send immediately.
- No duplicate Send button.
- No loss of focus or cursor position while typing.
- Emoji insertion at the current caret.
- Enter sends and Shift+Enter inserts a newline where a hardware keyboard is present.
- Bounded multiline expansion.
- Keyboard-safe placement.
- Reply/edit cancellation and correct focus restoration.
- Recording, locked recording, cancel, stop, and send simulations.

Actions:

- Edit only an eligible own message.
- Delete for me removes the local row.
- Delete for everyone is available only for an eligible own message and retains a deletion marker.
- Deleted messages must not expose inappropriate editing/reaction actions.
- Reply, forward, star/unstar, pin/unpin, copy, and message information must work in memory.
- Search results and starred messages should navigate to the relevant conversation/message.
- Simulated offline sending queues messages, then progresses or fails/retries without duplicates.
- Attachment upload progress/failure should be visible and retryable.

Use a bounded scrollable message area. Header and composer remain usable while the thread scrolls.

### Groups

- Create/edit a group and update its identity across screens.
- Add selected eligible members.
- Existing members cannot be added twice.
- Search members.
- Show owner/admin/member badges.
- Enforce role-aware management options.
- Promote, demote, remove, transfer ownership, and leave update all relevant views.
- Handle owner-transfer prerequisites.
- Permission changes affect composer availability.
- Removed/left members retain the appropriate read-only history.
- Include mention suggestions and partial/all-read receipt examples.
- Keep group role state separate from Business payer/recipient state.

### Business identity and paid rooms

Business interactions must retain their **originating Story context**.

- Use the originating Story cover/public Business identity.
- Never substitute the customer’s or creator’s private avatar/phone into this context.
- Keep rooms and messages separated by originating Story.
- Switching to a contact Story and back must not corrupt Business identity or room state.
- A Business profile with no eligible active Story must not expose a detached paid-contact path.

Pricing:

- 10 Credits opens a 24-hour Business message room.
- Messages within an active room have no per-message fee.
- Opening an already active room must not charge again.
- The recipient can reply without buying a room.
- A Story expiring does not prematurely end an already active room.
- Expired rooms become read-only.
- Reopening requires an eligible originating Story, confirmation, sufficient Credits, and remaining configured allowance.
- If the source is unavailable or the interaction cap is reached, explain why reopening is unavailable.

### Calls

Calls are simulated **1:1 audio/video only**.

Provide:

- Ringing, incoming, answered, busy, declined, missed, cancelled, reconnecting, and ended states.
- Timer.
- Mute/output/camera/switch-camera controls with visible state.
- Mock remote/self preview.
- Minimize/return/end behavior.
- Call history and summary updates.

Personal contact calls are free.

Business rates:

- Audio: 15 Credits per started 60-second block after answer.
- Video: 25 Credits per started 60-second block after answer.
- Ringing, unanswered, declined, and busy calls cost zero.
- The incoming recipient is not charged.
- Warn before available balance is exhausted.
- Stop at the paid-block boundary when the next block cannot be covered.
- Minimized calls retain their session and timer.
- Rebuilding widgets, returning to the call, or repeated End actions must not duplicate charges or ledger entries.

Use a controllable mock clock so these states can be reviewed without waiting real minutes.

### Stories, Discover, publishing, and analytics

Discover is for browsing published, eligible promoted content. Creation and audience targeting belong in Publishing.

Support:

- Own, contact, and Business Story contexts.
- Photo, video, and audio.
- Progress, next/previous, pause/hold, mute, seen, expired, removed, and failed-media states.
- Contact Story viewer identities where permitted.
- Aggregate analytics for promoted content, without private viewer identity leakage.
- Popular progress using qualified unique views.
- Exclusion/holding of self or suspicious views.

Publishing flow:

Publishing hub → Category → Media → Editor → Audience when advertisement → Price review → Publish → Publication details/viewer.

Rules:

- Category fee, Boost fee, and advertisement fee are additive.
- Video and audio publications require Boost.
- Photo Boost is optional.
- Example paid-category video/audio advertisement: **5 + 50 + 100 = 155 Credits**.
- Photo Statuses consume image slots, including paid-category photos.
- Paying a category fee does not purchase another slot.
- Preserve the correct quota behavior by publication type.
- Ordinary lifetime: 24 hours.
- Boost lifetime: 48 hours.
- One eligible 24-hour extension, maximum 72 hours.
- A category fee alone must not promise Discover promotion.
- Configuration changes require a refreshed itemized review.
- Failed publication preserves media, caption, category, and targeting.
- Successful publication updates publications, applicable slot usage, balance, and activity once.
- Removal/expiration updates relevant viewer/list states.

Mock media editing must visibly affect the preview or draft metadata: crop/rotate, trim range, caption, cover selection, capture/retake, and recording controls cannot be decorative.

### Wallet

Keep Credits, Diamonds, and Cash separate.

- Credits pay for eligible app actions.
- Diamonds are rewards.
- Diamonds must be converted into Cash before withdrawal.
- Pending or frozen Diamonds cannot be converted.
- Withdrawals use Cash only.

Purchases:

- SmobilPay/Maviance simulation only.
- MTN and Orange Mobile Money.
- Processing/pending states do not credit the balance.
- Confirmation credits once.
- Retry/refresh/repeated confirmation must not double-credit.
- Preserve an interrupted action and return to its appropriate review/confirmation context after top-up.

Conversion:

- Validate available Diamonds.
- Show rate and resulting Cash.
- Confirm before applying.
- Debit Diamonds and credit Cash once.
- Record the corresponding activities.
- Support changed-rate, submitting, failure, and success scenarios.

Withdrawal:

- Validate minimum, available Cash, destination, fees, and configured frequency limits.
- Show amount, fees, and net payout.
- Confirm once.
- Create a request and reserve/debit Cash once.
- Track Pending → In Progress → Approved → Paid, with rejected/failed alternatives.
- Recredit rejected/failed payouts once when appropriate.
- Repeated status refresh must not recredit again.
- Keep history, details, balance, and ledger presentation synchronized.

### Settings and safety

- Theme changes update the entire app immediately without resetting session data.
- System theme follows the host appearance.
- Audience/privacy/notification settings update their related mock behavior.
- Permission denied/permanently denied flows remain usable.
- Blocking/unblocking updates relevant lists and conversation states.
- Report success/failure preserves correct target context.
- Sign-out opens Welcome.
- Account deletion requires explanation, acknowledgement, and final confirmation.
- Restriction states show appropriate allowed actions.

## 11. Required loading and scenario coverage

Implement the following **130 named states**, retaining IDs for review/testing.

The following list is a minimum. Ordinary interaction states such as emoji-tray visibility, selected filters, and open editors must also work.

### Navigation

- V001 — Initial application loading.
- V002 — Offline/reconnecting.
- V003 — Recoverable page error.

### Onboarding

- V004 — Sign-in in progress.
- V005 — Sign-in cancelled.
- V006 — Sign-in failed.
- V007 — Invalid required phone/profile.
- V008 — Terms not accepted.
- V009 — Fewer than three interests.
- V010 — Single-interest advertisement mode.
- V011 — Contacts permission declined.
- V012 — Contact matching in progress.
- V013 — No matching app contacts.

### Chats and contacts

- V014 — Sending message.
- V015 — Message sent.
- V016 — Message delivered.
- V017 — Message read.
- V018 — Offline queued message.
- V019 — Message failed.
- V020 — Reply composer.
- V021 — Edit composer.
- V022 — Voice recording.
- V023 — Voice recording locked.
- V024 — Blocked direct chat.
- V025 — Attachment upload progress/failure.
- V026 — No search matches.
- V027 — Empty archived list.
- V028 — Unsupported file preview.

### Groups

- V029 — Owner view.
- V030 — Admin view.
- V031 — Member view.
- V032 — Only admins may send.
- V033 — Mention suggestions.
- V034 — Removed member.
- V035 — Left group.
- V036 — Member search has no results.
- V037 — Owner transfer selection.
- V038 — No permission for member action.
- V039 — Group creation/update in progress.
- V040 — Group creation/update failed.
- V041 — Partial group delivery/reads.
- V042 — All group recipients read.
- V043 — Add members/already present.
- V044 — Empty multiselect.

### Calls

- V045 — Personal call ringing.
- V046 — Business call ringing.
- V047 — Busy.
- V048 — Declined.
- V049 — Unanswered/missed.
- V050 — Incoming personal call.
- V051 — Incoming Business call.
- V052 — Business call answered.
- V053 — Reconnecting call.
- V054 — Balance-boundary stop.
- V055 — Permission-blocked call.

### Stories and Discover

- V056 — Contact Story.
- V057 — Business Story.
- V058 — Own Story.
- V059 — Image playback.
- V060 — Video playback.
- V061 — Audio playback.
- V062 — Seen Story.
- V063 — Paused Story.
- V064 — Muted playback.
- V065 — Expired Story.
- V066 — Removed Story.
- V067 — Story media failed to load.
- V068 — No contact Stories.
- V069 — No eligible promoted content.
- V070 — No eligible search results.
- V071 — No eligible active Stories on a Business profile.

### Publishing

- V072 — Free category.
- V073 — Paid category.
- V074 — Image slot available.
- V075 — Paid-category image uses a slot.
- V076 — Mandatory video/audio Boost.
- V077 — Video/audio advertisement total.
- V078 — Insufficient Credits.
- V079 — Price/configuration changed.
- V080 — Publishing in progress.
- V081 — Publication failed.
- V082 — Publication succeeded.
- V083 — Location denied/manual targeting.

### Business conversations

- V084 — Customer active room.
- V085 — Recipient active room.
- V086 — Active room/originating Story expired.
- V087 — Expired room/source still eligible.
- V088 — Expired room/source unavailable.
- V089 — Interaction reopening cap reached.
- V090 — Active room reopened from Story without another charge.

### Creator tools

- V091 — No contact viewers yet.
- V092 — Contact viewers available.
- V093 — Below Popular threshold.
- V094 — Popular threshold reached.
- V095 — Suspicious views held.
- V096 — No publications/no filter matches.

### Wallet

- V097 — Payment processing.
- V098 — Payment pending.
- V099 — Payment failed.
- V100 — Payment cancelled.
- V101 — Payment confirmed.
- V102 — MTN Mobile Money selected.
- V103 — Orange Mobile Money selected.
- V104 — SmobilPay provider confirmation.
- V105 — No activity for selected balance.
- V106 — Pending Diamonds.
- V107 — Frozen Diamonds.
- V108 — Conversion submitted/failed.
- V109 — Conversion confirmed.
- V110 — Below withdrawal minimum.
- V111 — Fee/net payout review.
- V112 — Invalid destination.
- V113 — Frequency limit reached.
- V114 — Pending withdrawal.
- V115 — Withdrawal in progress.
- V116 — Withdrawal approved.
- V117 — Withdrawal rejected.
- V118 — Withdrawal paid.
- V119 — Technical payout failure/recredit.

### Profile and settings

- V120 — Light theme.
- V121 — Dark theme.
- V122 — System theme.
- V123 — No blocked accounts.
- V124 — Business profile incomplete.
- V125 — Permission permanently denied.

### Safety

- V126 — Report submitted.
- V127 — Report failed.
- V128 — Warning.
- V129 — Suspension.
- V130 — Permanent ban.

Loading must be intentional and contextual:

- Skeletons for content lists/cards where appropriate.
- Button progress for submissions.
- Upload progress for attachments/publications.
- Playback/recording progress for media simulations.
- Retryable errors that retain user input.
- Appropriate empty states with relevant next actions.

Do not implement a scenario merely by changing a label or showing a generic toast. It must visibly demonstrate the specified state and its available actions.

## 12. Prototype review tools

Provide a clearly separated prototype-review entry, such as **Prototype tools** in an appropriate overflow/menu.

It must allow a reviewer to:

- Search and open every P01–P80 page.
- Open every S01–S21 sheet and D01–D23 dialog in suitable context.
- Select the 130 scenario cases.
- Switch light/dark/system.
- Switch group owner/admin/member perspective.
- Switch Business payer/recipient perspective.
- Simulate online/offline, loading, failure, retry, and success.
- Advance the mock clock.
- Trigger incoming calls and call outcomes.
- Set payment and withdrawal outcomes.
- Test insufficient balance, image limits, changed configuration, and room expiry.
- Reset the complete demo.
- Start onboarding.

These controls are supplementary review UI, not an Admin product module or extra product-page scope.

Keep developer explanations and scenario controls out of ordinary customer flows.

## 13. Code quality and lifecycle

- Use typed models and enums where appropriate.
- Keep IDs stable and relationships explicit.
- Use a single coherent in-memory source of truth for shared entities.
- Keep feature logic modular.
- Avoid duplicating direct/group/Business implementations.
- Dispose timers, animation controllers, focus nodes, and text controllers correctly.
- Do not start timers or perform mutations in widget build methods.
- Prevent setState/controller updates after disposal.
- Preserve active sessions when minimizing or navigating.
- Avoid full-screen rebuilds that interrupt typing or reset scroll unnecessarily.
- Use accessible labels for icon actions.
- Handle back navigation, keyboard dismissal, sheet dismissal, and unsaved drafts consistently.
- Centralize English copy so future localization is straightforward.
- Bundle assets so the app works offline.
- Do not leave broken images, raw SVG markup, placeholder routes, dead buttons, default counter screens, or TODO-based implementations.

Do not add group calls, text-only Stories, invitation links/join requests, saved payout-account systems, or new detached Business contact routes.

## 14. Implementation and completion criteria

Work in sensible internal milestones, but keep implementing until the full goal is complete.

Maintain an implementation checklist, for example:

- `docs/ui_surface_checklist.md`
- `docs/prototype_scenarios.md`

The checklist must account for all 124 product surfaces and all 130 scenario cases. Record actual implementation and validation status rather than marking everything complete by assumption.

Verify at least:

1. The app starts on Discover in its seeded demo state.
2. All five tabs and all inner routes work.
3. Every sheet/dialog has a working entry, contextual content, confirm/cancel behavior, and correct return.
4. Onboarding completes with permission accepted or declined.
5. Prefix/local phone composition works without duplication.
6. Profile avatars never overlap headers.
7. App-bar controls are centered and aligned.
8. Chat typing retains focus; mic/send switches immediately.
9. Emoji insertion, multiline entry, reply, edit, delete, forward, reactions, and receipts work.
10. Group membership/role/permission changes update related screens.
11. Business identity remains tied to its originating Story.
12. Active-room reopening does not debit again.
13. Unanswered calls cost zero.
14. Answered Business calls charge correctly and remain consistent while minimized.
15. Publication totals, quotas, and changed-price confirmation work.
16. Pending payments do not add Credits; confirmation adds them once.
17. Diamonds convert to Cash correctly; pending/frozen amounts are excluded.
18. Withdrawal failure/rejection recredits only once when applicable.
19. Both themes cover every screen, sheet, dialog, field, and status.
20. Layouts remain usable at the specified phone sizes and with the keyboard open.
21. Reset restores a clean, coherent seeded demo.
22. The prototype works without any backend, database, or network connection.

Add meaningful tests for routing, shared interactions, and mock state transitions, especially the rules above. Do not create hundreds of superficial tests that only check that a screen title exists.

Run:

- Formatting.
- Flutter analysis.
- Appropriate widget and state/controller tests.
- A runnable build for the available target.
- Android debug build when supported.
- iOS build validation when the host supports it.

If a platform build cannot run because the required host tooling is unavailable, state the concrete limitation and complete the checks that are possible. Do not claim a build or test passed without running it.

At completion, provide:

- The implemented Flutter project.
- Clear run instructions.
- Available runnable build/artifact paths.
- The completed coverage checklist.
- A concise validation summary and any genuine remaining limitations.

**Start by inspecting the existing `app` project and my coding style, then implement the entire prototype. Do not stop after a plan or partial UI.**