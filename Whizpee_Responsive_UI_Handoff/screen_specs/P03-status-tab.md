# P03 — Status tab

Feature: Navigation. Surface: Tab. Layout family: `status_master`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Your Status, rectangular previews, contact rings, seen updates and Discover preview.

- Entry: Bottom navigation.
- Exit: Story viewer or publishing.
- Typed context: `source:Status; selectedStoryId?; seenFilter?`.
- Flutter screen: `StatusTabScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Status app bar and Create action.
2. Own Status row with add badge.
3. Recent updates.
4. Seen updates.
5. Rectangular contact previews.
6. Discover preview cards.

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
| C12 | IdentityAvatar | `WhizpeeIdentityAvatar` |
| C16 | ConversationRow | `WhizpeeConversationRow` |
| C28 | StoryCard | `WhizpeeStoryCard` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 56 high; 72 when a subtitle is needed; 44×44 action targets | Title 20/26, weight 700; action icon 20, 8 gap |
| Body gutter | 20 compact; 24 medium; 32 expanded/large | Use logical horizontal/vertical insets |
| Field/button | 48-high text fields; 44-high buttons; 12 internal horizontal padding | Label 12/18; input 14/21; field-to-field gap 16 |
| Sections | 24 between major sections; 16 within a section; 8 label/control gap | Divider 1, card radius 12, button radius 9 |
| Master list | 336 expanded/large; full available width compact/medium | Rows min 76; avatar 44; content gap 12; title 14/20; preview 12/18 |
| Search/chips | Search 44; chips 32 minimum; gap 8 | Horizontally scroll chip strip without losing selected state |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; gutter 20. |
| Medium | icon rail 76 and single active pane; gutter 24. |
| Expanded | icon rail 76; gutter 32. |
| Large | icon rail 76; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Own item → P34(mode=own).
- contact → P34(mode=contact).
- create → P37.
- Discover → P04.

## Rules, guards and failure recovery

- Seen appearance changes after viewing; unavailable contact updates do not block Create or Discover.
- Contact Story identity follows privacy rules.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V068 — No contact Stories | Maintain usable Status Home with create/discovery entries. |

## Scrolling, focus and keyboard

- The content pane owns vertical scroll; persistent master navigation has independent scroll. Do not nest unbounded vertical scrollers.
- Tab follows visual order; focus ring is visible in both themes. Escape dismisses the top dismissible overlay. Browser Back returns to the contextual source.
- Preserve query/draft/selection when a child route or picker closes. On save, restore focus to the source row or next logical action.

## Visual acceptance

- Open `P03` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
