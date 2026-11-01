# S20 — Payout-method chooser

Implementation contract for `PayoutMethodSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Wallet**. Entry: Withdrawal form. Return: Withdrawal form.

| Typed input | Meaning |
| --- | --- |
| `WithdrawalDraftId withdrawalId` | current Cash-withdrawal draft |
| `PayoutMethod selected` | configured mock method |
| `PayoutDestination destination` | phone/account type-specific value |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Introduction | Choose where to receive Cash;13/20 muted. |
| 2 | Method rows | Mobile Money: registered phone; Bank account: destination account;48 minimum, icons 24, subtitle 12, radio 19. |
| 3 | Explanation/footer | Methods and fees reviewed before confirmation; Cancel 44. |

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

- Selecting method updates P61 field label/validation and closes.
- Cancel preserves prior method/destination.

## Domain and state rules

- Methods are configuration-driven mock examples.
- Do not create a saved payout-account management system.
- A method change must validate the destination type before P62.
- Cash only; this chooser must not imply Credits/Diamonds are directly withdrawable.

## Review cases

- Mobile Money phone destination.
- Bank account destination.
- Unavailable configured method is disabled with explanation.
- Fee changes appear in refreshed P62 review.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
