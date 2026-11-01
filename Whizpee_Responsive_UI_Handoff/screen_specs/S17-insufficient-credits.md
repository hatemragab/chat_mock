# S17 — Insufficient Credits

Implementation contract for `InsufficientCreditsSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Wallet**. Entry: Any paid confirmation. Return: Buy Credits or previous action.

| Typed input | Meaning |
| --- | --- |
| `CreditAmount required` | price of interrupted action |
| `CreditAmount available` | current balance |
| `InterruptedAction action` | typed publication/room/call intent with target IDs |
| `ReturnDestination returnTo` | review destination after top-up |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Hero | 58 credit icon in soft circle. |
| 2 | Explanation | 13/20 copy explaining preserved selection. |
| 3 | Price summary | Required, Your balance, Amount missing;14 padding,12 label/value gap. |
| 4 | Actions | Buy Credits 44; Cancel 44. |

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

- Buy Credits opens P57 with intact interrupted action.
- Cancel returns to the source review without spending or clearing its draft.

## Domain and state rules

- Missing amount=max(0,required-available).
- Purchase confirmation returns to review/confirmation; it must not silently execute the interrupted charge.
- Keep target IDs and reviewed configuration version, not a global last-screen string.

## Review cases

- Changed balance after sheet opens: refresh amount before proceeding.
- Successful top-up: preserve draft/room selection and resume review.
- Pending/failed purchase: do not apply Credits or execute action.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
