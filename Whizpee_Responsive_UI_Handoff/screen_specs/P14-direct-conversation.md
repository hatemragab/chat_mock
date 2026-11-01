# P14 — Direct conversation

Feature: Chats and contacts. Surface: Page. Layout family: `conversation`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Text, media, documents, voice notes; reply/edit composer; reactions; receipts; native audio/video actions; web uses an unavailable-capability presentation.

- Entry: Chats / recipient picker / notification.
- Exit: Chat info, media, message info or call.
- Typed context: `conversationId; contactId; targetMessageId?; replyToId?; editMessageId?`.
- Flutter screen: `DirectConversationScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. 58 px contact header.
2. Optional offline/banner or pinned message.
3. Independently scrolling day-separated thread.
4. Grouped incoming/outgoing bubbles.
5. Reply/edit strip.
6. Bounded multiline composer and single mic/send button.

## Shared component bindings

| ID | Component | Flutter widget |
|---|---|---|
| C01 | AdaptiveScaffold | `WhizpeeAdaptiveScaffold` |
| C02 | AppHeader | `WhizpeeAppHeader` |
| C05 | ActionButton | `WhizpeeActionButton` |
| C06 | IconButton | `WhizpeeIconButton` |
| C35 | AsyncState | `WhizpeeAsyncState` |
| C40 | Toast | `WhizpeeToast` |
| C12 | IdentityAvatar | `WhizpeeIdentityAvatar` |
| C17 | ConversationLayout | `WhizpeeConversationLayout` |
| C18 | MessageBubble | `WhizpeeMessageBubble` |
| C19 | MessageReceipt | `WhizpeeMessageReceipt` |
| C20 | QuotedMessage | `WhizpeeQuotedMessage` |
| C21 | MessageComposer | `WhizpeeMessageComposer` |
| C22 | EmojiTray | `WhizpeeEmojiTray` |
| C23 | ReactionPill | `WhizpeeReactionPill` |
| C24 | MediaAttachment | `WhizpeeMediaAttachment` |
| C25 | VoiceRecordingBar | `WhizpeeVoiceRecordingBar` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 58 high; avatar 36; actions 44×44 | Header stays outside thread scroller |
| Thread | 12 vertical inset; 16 horizontal compact / 24 wide | Day divider 11/16; group gaps 4; new-author gaps 12 |
| Bubble | Compact max min(82%,520 px); medium+ min(65%,520 px); text inset 12×8 | Message 14/20; timestamp 10/14; normal radius 11 |
| Composer | Textarea 44–120; pill 48–124; external action 44; gap 8 | Outer padding top 8, bottom 12, inline 12; total 68–144 excluding reply/emoji/safe inset. Input uses chat body 14/20; textarea vertical padding 12. |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; gutter 20. |
| Medium | icon rail 76 and single active pane; gutter 24. |
| Expanded | icon rail 76 plus master 336 plus detail; gutter 32. |
| Large | icon rail 76 plus master 336 plus detail; optional 320 info pane (P15) when explicitly opened; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Info → P15/context panel.
- message → S03.
- attach → S04.
- emoji tray.
- send/retry.
- quote jump.
- media → P17.
- file → P22.
- native calls → P29.

## Rules, guards and failure recovery

- Reuse shared conversation renderer.
- Preserve caret/focus/draft and scroll on receipt/theme updates.
- Edit/delete-for-everyone only eligible own messages.
- Web call controls unavailable.
- No duplicated sends after retry.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V014 — Sending message | Pending network indicator. |
| V015 — Message sent | Sent receipt. |
| V016 — Message delivered | Delivery receipt. |
| V017 — Message read | Read receipt where enabled. |
| V018 — Offline queued message | Pending state and later retry. |
| V019 — Message failed | Retry action without creating duplicate visible messages. |
| V020 — Reply composer | Quoted source and cancel reply. |
| V021 — Edit composer | Current message content, save and cancel. |
| V022 — Voice recording | Record timer, cancel, lock and send controls. |
| V023 — Voice recording locked | Hands-free recording with stop/cancel/send. |
| V024 — Blocked direct chat | Show restriction and route to unblock. |
| V025 — Attachment upload progress / failure | Progress and retry or remove attachment. |

## Scrolling, focus and keyboard

- Header and composer remain fixed in their pane; only the message thread scrolls. Opening a context pane does not reset message scroll.
- Enter sends with a hardware keyboard; Shift+Enter inserts a newline. Emoji inserts at the active caret. Edit/reply cancellation restores focus to the composer.
- When already at the bottom, follow new messages. When reading history, preserve position and expose a jump-to-latest action.

## Visual acceptance

- Open `P14` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
