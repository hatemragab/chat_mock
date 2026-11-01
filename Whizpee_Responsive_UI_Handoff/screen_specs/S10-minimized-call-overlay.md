# S10 — Minimized-call overlay

Implementation contract for `MinimizedCallCard`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Calls**. Entry: Active call minimize. Return: Active call or call summary.

| Typed input | Meaning |
| --- | --- |
| `CallSessionId sessionId` | persistent mock active session |
| `CallIdentity identity` | personal identity or originating Story Business cover |
| `CallClock clock` | elapsed seconds and current paid block |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Identity row | 48 avatar/Story cover; name 15 and audio/video+elapsed 12; gap 12. |
| 2 | Business notice | Optional paid-block continuity notice 12/18. |
| 3 | Actions | Return to call 44 then End call 44 danger; gap 8. |

Shared overlay title 18/24 at weight 700; primary body 13/20; secondary label 12/18; icons 24. Minimum touch target 44×44. Default option-row height 48 with 12 icon/text gap; allow height growth for wrapped labels. Header/body/footer are separate layout regions, with 16 between regions. Use semantic tokens from `design_tokens.json`; danger text and actions use the danger role rather than hardcoded red.

## Responsive presentation

| Width class | Presentation |
| --- | --- |
| Compact, below 600 | Compact persistent call card; width=min(360, viewport−32),16 side clearance; does not block navigation. |
| Medium,600–1023 | Nonblocking minimized-call card, top-right of client area; 360 maximum width, 16 from the top/right safe content edge. |
| Expanded,1024–1439 | Nonblocking minimized-call card, top-right of client area; 360 maximum width, 16 from the top/right safe content edge. |
| Large,1440+ | Nonblocking minimized-call card, top-right of client area; 360 maximum width, 16 from the top/right safe content edge. Do not stretch to fill the entire application. |

The minimized card follows its session rather than the current route. It remains inside the safe viewport and avoids the composer and review toolbar. It does not trap keyboard focus.

## Actions

- Return reopens P31 or P32 with the same session.
- End terminates that session once and opens summary P33.

## Domain and state rules

- Keep the timer and paid-block state outside the widget.
- Resizing or returning to the card cannot restart a paid block.
- Normal web has no active calls. This card is native/review-only.
- Do not reveal a private personal avatar in the Business variant.

## Review cases

- Personal free call variant.
- Business payer/recipient variants; recipient has no debit.
- Reconnecting badge retains elapsed time.
- Repeated End is idempotent.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
