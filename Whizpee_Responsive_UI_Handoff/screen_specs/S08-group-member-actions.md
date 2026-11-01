# S08 — Group member actions

Implementation contract for `GroupMemberActionsSheet`. English only. All sizes below are logical pixels; CSS pixels in the HTML reference map to Flutter logical pixels at 100% zoom. This is a specification, not evidence of a Flutter implementation.

## Context and entry

Feature: **Groups**. Entry: Group members. Return: Contact info or group confirmation.

| Typed input | Meaning |
| --- | --- |
| `GroupId groupId` | selected group |
| `UserId memberId` | selected member |
| `GroupRole actorRole` | owner/admin/member |
| `GroupRole targetRole` | selected member role |

Pass context as typed route/overlay arguments. Keep it stable if another pane changes selection. Dismissal returns to the initiating control and restores its focus when it still exists.

## Anatomy and metrics

| Order | Element | Specification |
| --- | --- | --- |
| 1 | Identity | 46 circular avatar; gap 12; member name 15, role 12. |
| 2 | Action order | View contact; Message privately when not self; Make admin or Dismiss admin when allowed; Remove when allowed; Transfer ownership for owner; Leave when self. |
| 3 | Footer | Close 44. |

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

- View opens P15 with permitted contact context; Message opens P14.
- Promote, demote, remove and transfer open D08, D09, D07 and D10 respectively.
- Self Leave opens D06.

## Domain and state rules

- Owner cannot be removed or demoted through a generic member action.
- Ordinary members do not receive management controls.
- Role labels and permissions refresh across P25/P26/P27 after confirmation.
- Private communication remains subject to relationship/privacy rules.

## Review cases

- Owner, admin and member perspectives have distinct available actions.
- Self view omits Message privately.
- Permission lost while open: prevent confirmation and return to refreshed group data.

Test both themes at 320×640,768×1024,1024×768 and 1440×900; also test keyboard-open and 150% text scale where a field or wrapped label is present. Confirm correct target identity, safe cancellation and no duplicate mutation.

## Status

- Specification: authored from the current prototype registry and approved responsive direction.
- Baseline renderer: inherited in the HTML prototype.
- Responsive visual verification: pending package-level QA.
- Flutter implementation and platform integration: to be performed by the receiving agent.
