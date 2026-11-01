# S03 — Message actions

Implementation contract for `MessageActionsSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Chats and contacts**. Entry: Long-press message. Return: Composer, picker, details or confirmation.

| Typed input | Meaning |
| --- | --- |
| `ConversationId conversationId` | source thread |
| `MessageId messageId` | selected message |
| `MessagePermissions permissions` | own, eligibleEdit, eligibleDeleteForEveryone, deleted |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Selection summary | Rounded 12 canvas card with 14 padding; caption 11 then source text 14. |
| 2 | Quick reactions | 4 emoji choices plus More, 5 equal columns; gap 8; each target at least 44. |
| 3 | Action rows | Reply, Copy, eligible Edit, Forward, Star/Unstar, Pin/Unpin, Message info, Delete; each row minimum 48. |
| 4 | Footer | Close 44. |

Shared overlay title 18/24 at weight 700; primary body 13/20; secondary label 12/18; icons 24. Minimum touch target 44×44. Default option-row height 48 with 12 icon/text gap; allow height growth for wrapped labels. Header/body/footer are separate layout regions, with 16 between regions. Use semantic tokens from `design_tokens.json`; danger text and actions use the danger role rather than hardcoded red.

## Responsive presentation

| Width class | Presentation |
| --- | --- |
| Compact, below 600 | Bottom-aligned sheet, full available width, top radius 21, maximum 90% safe viewport height;20 horizontal content inset;35×4 handle centered with 8 top inset. |
| Medium,600–1023 | Centered modal sheet, maximum width 480; 24 outer clearance. |
| Expanded,1024–1439 | Centered modal sheet, maximum width 480; 24 outer clearance. |
| Large,1440+ | Centered modal sheet, maximum width 480; 24 outer clearance. Do not stretch to fill the entire application. |

Use a dimmed modal backdrop. The body scrolls when content exceeds available height; retain reachable title/close and footer. Respect safe-area and keyboard insets. Trap keyboard focus within the modal, focus its title or first suitable field, and use Escape/system Back as safe dismissal. A destructive action is never triggered by Enter from an unrelated focused field.

## Actions

- Quick reaction updates own reaction and closes; More opens S07.
- Reply/edit opens the matching composer mode and restores input focus.
- Forward opens P12 multiselect; Message info opens P18.
- Delete opens D02; Copy copies available text or offers text-selection fallback.

## Domain and state rules

- Hide edit for incoming or otherwise ineligible messages.
- Deleted markers hide reaction/reply/edit/forward actions; keep only actions permitted for the marker.
- Star/pin state belongs to messageId within conversationId, not a global boolean across messages.

## Review cases

- Own eligible message: Edit visible.
- Incoming message: Edit absent.
- Deleted message: compact permitted-action list.
- Unavailable clipboard: explain specific fallback without losing selected-message context.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
