# P04 — Discover tab

Feature: Navigation. Surface: Tab. Layout family: `discover_grid`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Target-eligible Boosted, Sponsored and Popular Story cards; category browsing.

- Entry: Bottom navigation.
- Exit: Story viewer, search or public Business profile.
- Typed context: `category:For you or categoryId; eligibleStoryId?`.
- Flutter screen: `DiscoverTabScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Discover app bar and Credits shortcut.
2. Search field.
3. Category chips.
4. Section captions.
5. Responsive promoted Story cards with cover, badge, Business name and description.

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
| C10 | FilterChip | `WhizpeeFilterChip` |
| C11 | StatusBadge | `WhizpeeStatusBadge` |
| C28 | StoryCard | `WhizpeeStoryCard` |
| C34 | MetricCard | `WhizpeeMetricCard` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 56 high; 72 when a subtitle is needed; 44×44 action targets | Title 20/26, weight 700; action icon 20, 8 gap |
| Body gutter | 20 compact; 24 medium; 32 expanded/large | Use logical horizontal/vertical insets |
| Field/button | 48-high text fields; 44-high buttons; 12 internal horizontal padding | Label 12/18; input 14/21; field-to-field gap 16 |
| Sections | 24 between major sections; 16 within a section; 8 label/control gap | Divider 1, card radius 12, button radius 9 |
| Feed grid | Gap 16; card min 220 wide on expanded; compact 2 columns where each fits≥120 | Coveraspect 4:5; captions 12/18; cap content 1200 |
| Feed header | Search 44; chip strip 32; sectiongap 24 | No permanent desktop inspector |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; centered content max 1200; gutter 20. |
| Medium | icon rail 76 and single active pane; centered content max 1200; gutter 24. |
| Expanded | icon rail 76; centered content max 1200; gutter 32. |
| Large | icon rail 76; centered content max 1200; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Search → P35.
- card → P34(mode=business,storyId).
- public identity → P36.
- Credits → P54.

## Rules, guards and failure recovery

- Discover contains eligible published promoted content.
- Category fee alone does not imply promotion.
- Start destination is P04.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V069 — No eligible promoted content | Show appropriate empty state. |

## Scrolling, focus and keyboard

- The content pane owns vertical scroll; persistent master navigation has independent scroll. Do not nest unbounded vertical scrollers.
- Tab follows visual order; focus ring is visible in both themes. Escape dismisses the top dismissible overlay. Browser Back returns to the contextual source.
- Preserve query/draft/selection when a child route or picker closes. On save, restore focus to the source row or next logical action.

## Visual acceptance

- Open `P04` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
