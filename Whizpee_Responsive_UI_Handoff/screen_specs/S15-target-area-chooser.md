# S15 — Target-area chooser

Implementation contract for `TargetAreaSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Publishing**. Entry: Targeting location. Return: Location page.

| Typed input | Meaning |
| --- | --- |
| `AdvertisementDraftId draftId` | target draft |
| `GeoArea current` | country/city/neighborhood |
| `GeoArea pending` | editable selection before commit |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Fields | Country selector 48, City 48, Neighborhood 48; label 12, label-field gap 8, field groups 16. |
| 2 | Guidance | Radius is refined in P46; optional neighborhood is identified. |
| 3 | Actions | Use this area 44; Cancel 44. |

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

- Country change refreshes dependent city/neighborhood choices.
- Use this area commits the area summary and returns to P46.
- Cancel retains the earlier area and radius.

## Domain and state rules

- Use explicit country/city identity where available rather than concatenated strings as model keys.
- Location permission is optional; manual area selection remains available.
- Targeting belongs to publication drafts, not Discover browsing.

## Review cases

- Default fixture Cameroon/Douala/Bonapriso.
- Country chosen with no city: require valid configured locality or clearly country-only targeting.
- No permission: manual fields remain usable.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
