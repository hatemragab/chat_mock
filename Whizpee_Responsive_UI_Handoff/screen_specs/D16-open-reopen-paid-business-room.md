# D16 — Open / reopen paid Business room

Implementation contract for `OpenBusinessRoomDialog`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Business conversations**. Entry: Relevant action in the owning flow. Return: Confirm action or return without change.

| Typed input | Meaning |
| --- | --- |
| `StoryId sourceStoryId` | eligible originating Story |
| `BusinessRoomId? existingRoom` | matching historical room |
| `RoomTerms terms` | price 10 Credits/duration 24 h example |
| `ActionId purchaseId` | unique room-opening attempt |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Business identity | 48 Story cover; public name 15; About this Story 12. |
| 2 | Summary | Room access 24 h, one-time price 10 Credits, projected balance;14 padding. |
| 3 | Explanation | No per-message fee and no private-profile disclosure 13/20. |
| 4 | Actions | Pay 10 Credits & open 44; Cancel 44. |

Shared overlay title 18/24 at weight 700; primary body 13/20; secondary label 12/18; icons 24. Minimum touch target 44×44. Default option-row height 48 with 12 icon/text gap; allow height growth for wrapped labels. Header/body/footer are separate layout regions, with 16 between regions. Use semantic tokens from `design_tokens.json`; danger text and actions use the danger role rather than hardcoded red.

## Responsive presentation

| Width class | Presentation |
| --- | --- |
| Compact, below 600 | Centered dialog width=min(420, viewport−48), radius 17, padding 20. |
| Medium,600–1023 | Centered confirmation dialog, maximum width 420; 24 outer clearance. |
| Expanded,1024–1439 | Centered confirmation dialog, maximum width 420; 24 outer clearance. |
| Large,1440+ | Centered confirmation dialog, maximum width 420; 24 outer clearance. Do not stretch to fill the entire application. |

Use a dimmed modal backdrop. The body scrolls when content exceeds available height; retain reachable title/close and footer. Respect safe-area and keyboard insets. Trap keyboard focus within the modal, focus its title or first suitable field, and use Escape/system Back as safe dismissal. A destructive action is never triggered by Enter from an unrelated focused field.

## Actions

- Confirm rechecks source eligibility, cap, balance and existing room before single debit/open P47.
- Already-active room bypasses payment and opens directly.
- Insufficient Credits opens S17 with preserved source context.
- Cancel spends nothing.

## Domain and state rules

- Room is keyed by originating Story and participants.
- Recipient replies free within room.
- Story expiry does not prematurely close an active room; expired room is read-only.
- Reopening requires explicit fresh confirmation and remaining allowance.

## Review cases

- New eligible room.
- Expired eligible room reopening.
- Source unavailable/cap reached: no Pay action.
- Double-confirm cannot debit twice.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
