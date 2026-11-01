# P31 — Active audio call

Feature: Calls. Surface: Page. Layout family: `call_stage`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Time, mute, output, minimize and end; Business rate/balance panel for payer.

- Entry: Answered call.
- Exit: Minimized overlay or call summary.
- Typed context: `sessionId; mediaType:audio; payerRole; callClock; connectionState`.
- Flutter screen: `ActiveAudioCallScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Active-audio identity.
2. Timer.
3. Business rate/balance for payer.
4. Reconnecting label.
5. Mute/output/minimize/end controls.

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

- Mute toggles.
- output → S09.
- minimize → S10.
- End → P33.
- mock clock advances boundaries.

## Rules, guards and failure recovery

- Native/review-only on web.
- Business audio 15 Credits per started 60 s after answer; recipient free; minimize/resize cannot duplicate charges.
- Stop before unaffordable next block.
- These visual call pages are reachable through prototype review tools/native preview only. The normal web client must not offer usable start/answer controls.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V052 — Business call answered | Start paid-block billing presentation after answer. |
| V053 — Reconnecting call | Retain session context and show connection recovery. |

## Scrolling, focus and keyboard

- The media stage fits the viewport; controls remain within safe areas. Escape closes an eligible overlay/viewer and returns focus to its source.
- Media is proportionately contained; close, previous/next and playback controls remain keyboard reachable.

## Visual acceptance

- Open `P31` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
