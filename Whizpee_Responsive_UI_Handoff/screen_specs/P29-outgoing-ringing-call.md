# P29 — Outgoing / ringing call

Feature: Calls. Surface: Page. Layout family: `call_stage`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Audio/video and personal/Business modes; recipient context; cancel. Business ringing has no charge.

- Entry: Chat call action / recipient picker / Business preflight.
- Exit: Connected call or call summary.
- Typed context: `sessionId; contactId or storyId; mediaType:audio/video; direction:outgoing; payerRole`.
- Flutter screen: `OutgoingRingingCallScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Bounded ringing stage.
2. Identity.
3. Ringing status.
4. Rate explanation only if Business.
5. Cancel button.
6. Outcome feedback.

## Shared component bindings

| ID | Component | Flutter widget |
|---|---|---|
| C01 | AdaptiveScaffold | `WhizpeeAdaptiveScaffold` |
| C02 | AppHeader | `WhizpeeAppHeader` |
| C05 | ActionButton | `WhizpeeActionButton` |
| C06 | IconButton | `WhizpeeIconButton` |
| C35 | AsyncState | `WhizpeeAsyncState` |
| C40 | Toast | `WhizpeeToast` |
| C09 | SearchField | `WhizpeeSearchField` |
| C11 | StatusBadge | `WhizpeeStatusBadge` |
| C14 | SectionHeading | `WhizpeeSectionHeading` |
| C15 | SettingsRow | `WhizpeeSettingsRow` |
| C26 | ContactMemberRow | `WhizpeeContactMemberRow` |
| C33 | LedgerRow | `WhizpeeLedgerRow` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 56 high; 72 when a subtitle is needed; 44×44 action targets | Title 20/26, weight 700; action icon 20, 8 gap |
| Body gutter | 20 compact; 24 medium; 32 expanded/large | Use logical horizontal/vertical insets |
| Field/button | 48-high text fields; 44-high buttons; 12 internal horizontal padding | Label 12/18; input 14/21; field-to-field gap 16 |
| Sections | 24 between major sections; 16 within a section; 8 label/control gap | Divider 1, card radius 12, button radius 9 |
| Stage | Objectfit contain; max 640 general media; Storymax 420 and 9:16 | Fit available height without hiding controls |
| Controls | 44×44 minimum; end call/capture 56 where shown | Keep bottom controls outside cropped media |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; stage max 640; gutter 20. |
| Medium | icon rail 76 and single active pane; stage max 640; gutter 24. |
| Expanded | icon rail 76; stage max 640; gutter 32. |
| Large | icon rail 76; stage max 640; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Cancel → P33.
- review tools answer/busy/decline/no answer.
- answered → P31/P32.

## Rules, guards and failure recovery

- Native/review-only on web.
- Call session exists outside widget builds.
- Busy/declined/unanswered/cancelled ringing costs zero.
- These visual call pages are reachable through prototype review tools/native preview only. The normal web client must not offer usable start/answer controls.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V045 — Personal call ringing | Show normal contact identity and no paid controls. |
| V046 — Business call ringing | Originating cover and no charge while ringing. |
| V047 — Busy | Show busy result and retry. |
| V048 — Declined | Show declined result without charge. |
| V049 — Unanswered / missed | Show no-answer outcome without Business debit. |

## Scrolling, focus and keyboard

- The media stage fits the viewport; controls remain within safe areas. Escape closes an eligible overlay/viewer and returns focus to its source.
- Media is proportionately contained; close, previous/next and playback controls remain keyboard reachable.

## Visual acceptance

- Open `P29` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
