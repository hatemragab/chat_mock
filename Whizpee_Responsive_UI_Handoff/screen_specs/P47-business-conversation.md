# P47 — Business conversation

Feature: Business conversations. Surface: Page. Layout family: `conversation`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Originating Story cover, room expiry, payer/recipient modes; paid-room terms, messages and read-only expired history.

- Entry: Paid-room confirmation / Chats / notification.
- Exit: Business info, shared media or Business call review.
- Typed context: `conversationId; businessId; originatingStoryId; payerRole:customer/recipient; roomState; expiresAt`.
- Flutter screen: `BusinessConversationScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. 58 px Story-cover header.
2. Business room terms/expiry banner.
3. Shared grouped thread.
4. Payer/recipient identity mode.
5. Active composer or read-only expiry state.

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
| Large | icon rail 76 plus master 336 plus detail; optional 320 info pane (P48) when explicitly opened; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Info → P48/context panel.
- messages → S03.
- attach → S04.
- eligible reopen → D16.
- insufficient → S17.
- cap → D17.

## Rules, guards and failure recovery

- Open 10 Credits for 24 h; active-room access no extra charge; no per-message fees; recipient replies free.
- Source Story expiry leaves active room usable until room expires.
- Separate messages by Story ID.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V084 — Customer active room | Show expiry and no per-message charge. |
| V085 — Recipient active room | Allow replies without recipient purchase. |
| V086 — Active room / originating Story expired | Room remains usable until its own expiration. |
| V087 — Expired room / source still eligible | Read-only history and paid reopening option. |
| V088 — Expired room / source unavailable | Read-only history; new CTA unavailable. |
| V089 — Interaction reopening cap reached | Explain configured limit. |
| V090 — Active room reopened from Story | Open the existing room without charging again. |

## Scrolling, focus and keyboard

- Header and composer remain fixed in their pane; only the message thread scrolls. Opening a context pane does not reset message scroll.
- Enter sends with a hardware keyboard; Shift+Enter inserts a newline. Emoji inserts at the active caret. Edit/reply cancellation restores focus to the composer.
- When already at the bottom, follow new messages. When reading history, preserve position and expose a jump-to-latest action.

## Visual acceptance

- Open `P47` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
