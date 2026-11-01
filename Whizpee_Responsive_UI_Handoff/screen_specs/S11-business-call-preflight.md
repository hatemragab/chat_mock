# S11 — Business call preflight

Implementation contract for `BusinessCallPreflightSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Calls**. Entry: Eligible Business contact / callback. Return: Outgoing call.

| Typed input | Meaning |
| --- | --- |
| `StoryId sourceStoryId` | eligible originating Story |
| `CallMedia media` | audio/video |
| `CreditBalance available` | current Credits |
| `PriceConfigVersion configVersion` | rate terms being reviewed |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Business identity | 48 Story cover, public name and call media label. |
| 2 | Price card | 14 padding; three label/value rows: rate, balance, affordable duration; row gap 12. |
| 3 | Terms | Billing starts after answer; charge per started 60-second block; boundary-stop explanation. |
| 4 | Actions | Start audio/video call 44; Cancel 44. |

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

- Start validates eligibility, configured cap, rate version and first-block balance before P29.
- Insufficient balance opens S17 while preserving call intent.
- Cancel keeps balance unchanged.

## Domain and state rules

- Audio 15 Credits/started 60 seconds; video 25 in example config.
- Ringing, busy, declined and unanswered cost zero.
- Recipient is never charged.
- Native/review-only; normal web excludes start-call actions.

## Review cases

- Audio and video rates differ.
- Low balance shows zero affordable blocks and top-up path.
- Terms changed: require refreshed review.
- Expired source disables new contact and explains why.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
