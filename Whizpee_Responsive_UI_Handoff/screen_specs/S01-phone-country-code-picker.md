# S01 — Phone country-code picker

Implementation contract for `PhoneCountryCodeSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Onboarding**. Entry: Complete profile. Return: Profile phone input.

| Typed input | Meaning |
| --- | --- |
| `PhoneFieldTarget` | profile phone or edited profile phone control |
| `String selectedDialCode` | current + prefix |
| `String query` | current country/code search query |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Search row | 48-high search field plus 44-high Find action; gap 8; retain query. |
| 2 | Country rows | Minimum 48 high; ISO badge, country name, right-aligned +prefix. Row order: Cameroon, Egypt, Gabon, Congo, Chad, France, United Kingdom, United States. |
| 3 | Footer | 44-high Close action. |

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

- Find filters by case-insensitive country name or dialing prefix without dismissing.
- Selecting a country updates the originating prefix/local-number control and closes.
- Close, Escape or backdrop leaves the previous prefix and local digits unchanged.

## Domain and state rules

- Do not concatenate an already-entered international prefix twice.
- Changing prefix preserves local digits; pasting + or 00 international numbers must be parsed by PhoneNumberField.
- The row receives the full country identity and prefix; the UI should not infer country from a display label.

## Review cases

- Empty query: show all configured countries.
- No matches: replace rows with No matching country and search guidance; retain field.
- Keyboard open: country list scrolls; search and footer remain reachable.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
