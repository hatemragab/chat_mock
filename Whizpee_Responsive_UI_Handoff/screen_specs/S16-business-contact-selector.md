# S16 — Business contact selector

Implementation contract for `BusinessContactSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Business conversations**. Entry: Eligible promoted Story. Return: Room confirmation or call preflight.

| Typed input | Meaning |
| --- | --- |
| `StoryId sourceStoryId` | eligible originating Story |
| `BusinessRoomId? roomId` | existing room for this source |
| `RoomAccess access` | active/expired/missing |
| `PlatformCapabilities platform` | web/native/review |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Business identity | 50 Story cover; public name 15; About this Story subtitle 12. |
| 2 | Balance | 14-padded summary card with current Credits. |
| 3 | Message row | Continue conversation when active; otherwise Message with 10 Credits/24 h terms. |
| 4 | Native/review call rows | Audio 15 Credits/started 60 s; video 25 Credits/started 60 s; absent from normal web. |
| 5 | Footer | Cancel 44. |

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

- Active room opens P47 without another charge.
- Missing/expired eligible room opens D16 after cap validation.
- Reached cap opens D17.
- Native/review call rows open S11 with media kind.

## Domain and state rules

- All paid contact paths retain the originating Story.
- No detached contact path from a Business profile without eligible active Story.
- Messages within active room have no per-message fee.
- Recipient can reply without purchasing access.

## Review cases

- Customer active room vs recipient active room.
- Source expired but existing room active: Continue remains usable.
- Expired room/source unavailable: explain read-only history; no purchase CTA.
- Normal web exposes Message/Continue only.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
