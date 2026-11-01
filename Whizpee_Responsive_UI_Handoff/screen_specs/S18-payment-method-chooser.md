# S18 — Payment-method chooser

Implementation contract for `PaymentMethodSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Wallet**. Entry: Buy Credits. Return: Payment review.

| Typed input | Meaning |
| --- | --- |
| `PaymentDraftId paymentId` | Credit purchase draft |
| `MobileMoneyProvider selected` | MTN Mobile Money/Orange Mobile Money |
| `InternationalPhone phone` | provider destination number |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Provider branding | SmobilPay title 15, Secure payments by Maviance subtitle 12; icon 24. |
| 2 | Provider rows | MTN Mobile Money followed by Orange Mobile Money;48 minimum; trailing 19 radio. |
| 3 | Phone field | Label 12, field 48, shared international phone formatting. |
| 4 | Footer | Done 44 plus provider-review guidance 12/18. |

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

- Selecting a provider updates only the current purchase selection.
- Done closes to P57/P58; final payment remains a separate confirmation.
- Escape/backdrop before any selection keeps original method/phone; committed selection is reflected consistently.

## Domain and state rules

- Only SmobilPay/Maviance with MTN and Orange Mobile Money.
- Do not reproduce stale inventory PayPal or VISA options.
- No real provider requests, OTP, API keys or payments are performed.
- Validate destination before review; pending status does not credit balance.

## Review cases

- MTN checked.
- Orange checked.
- Invalid/empty destination: retain input and show field error before purchase review.
- Provider failure is handled at P59 without losing method selection.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
