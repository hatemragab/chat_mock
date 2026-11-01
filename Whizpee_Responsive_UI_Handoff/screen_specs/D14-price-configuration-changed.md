# D14 — Price / configuration changed

Implementation contract for `ChangedPublicationPriceDialog`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Publishing**. Entry: Relevant action in the owning flow. Return: Confirm action or return without change.

| Typed input | Meaning |
| --- | --- |
| `PublicationDraftId draftId` | preserved media/caption/targeting |
| `PriceConfigVersion oldVersion` | previous review |
| `PriceConfigVersion newVersion` | refreshed config |
| `PublicationPriceBreakdown updated` | category+Boost+ad |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Title | The price has changed 18/24. |
| 2 | Explanation | Updated category/Boost/ad terms require review 13/20. |
| 3 | Summary | Category fee, Boost fee or Not selected, advertisement fee or Not selected;14 padding. |
| 4 | Actions | Review updated price 44; Cancel 44. |

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

- Review opens P44 with latest itemized terms and requires another explicit publish confirmation.
- Cancel preserves the draft without publishing.

## Domain and state rules

- Do not auto-accept price changes.
- Category+Boost+advertisement charges remain additive.
- No debit occurs from opening this dialog or acknowledging new terms.

## Review cases

- Higher/lower price or quota/lifetime change.
- Mandatory Boost retained for audio/video.
- Draft persists across top-up and refreshed configuration.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
