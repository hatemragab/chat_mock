# S09 — Audio-output chooser

Implementation contract for `AudioOutputSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Calls**. Entry: Active audio/video call. Return: Active call.

| Typed input | Meaning |
| --- | --- |
| `CallSessionId sessionId` | native/review-only active call |
| `AudioOutput selected` | Earpiece, Speaker, Bluetooth headset |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Explanation | Choose where you hear this call;13/20 muted. |
| 2 | Rows | Earpiece, Speaker, Bluetooth headset; icon 24;48-minimum row;19 trailing radio. |
| 3 | Footer | Cancel 44. |

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

- Selecting output updates this mock session and closes.
- Cancel preserves the current output.

## Domain and state rules

- This is a mock device chooser; do not query actual output devices.
- Normal web product flows do not launch or answer calls. S09 is available through native simulation/review only.
- Changing output does not restart the call timer or create charges.

## Review cases

- Current output checked.
- Unavailable sample device may be disabled with explicit reason.
- Call ends while chooser is open: dismiss safely to P33.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
