# D22 — Unblock account / Business

Implementation contract for `UnblockIdentityDialog`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Safety**. Entry: Relevant action in the owning flow. Return: Confirm action or return without change.

| Typed input | Meaning |
| --- | --- |
| `IdentityId targetId` | selected blocked identity |
| `IdentityKind kind` | personal/Business |
| `ReturnDestination returnTo` | P73 or conversation context |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Title | Unblock this account?18/24. |
| 2 | Explanation | Removed from blocked list; contact/privacy rules still apply 13/20. |
| 3 | Actions | Unblock 44 primary; Cancel 44. |

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

- Confirm removes only target identity from blocked set and refreshes related views.
- Cancel keeps blocked state.

## Domain and state rules

- Unblocking does not create mutual-contact relationship or grant a paid Business room.
- Do not expose private Business identity through the confirmation.
- If blocked list becomes empty, P73 shows its empty state.

## Review cases

- Selected personal or Business identity.
- Already unblocked: safe no-op.
- Expired Business room stays read-only after unblock.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
