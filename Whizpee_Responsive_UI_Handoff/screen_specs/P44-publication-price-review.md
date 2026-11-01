# P44 — Publication price review

Feature: Publishing. Surface: Page. Layout family: `commercial_review`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Category fee + applicable Boost + ad fee; total, balance, image-slot use, lifetime and confirmation. Recheck changed prices.

- Entry: Media preview / ad targeting / successful top-up.
- Exit: Publish then publication details.
- Typed context: `draftId; configVersion; priceSnapshot; imageSlotState; returnAfterTopup?`.
- Flutter screen: `PublicationPriceReviewScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Review app bar/subtitle.
2. Step indicator.
3. Media/category recap.
4. Itemized category/Boost/ad fees.
5. Total.
6. Balance-after.
7. Lifetime/slot notice.
8. Confirm publication footer.

## Shared component bindings

| ID | Component | Flutter widget |
|---|---|---|
| C01 | AdaptiveScaffold | `WhizpeeAdaptiveScaffold` |
| C02 | AppHeader | `WhizpeeAppHeader` |
| C05 | ActionButton | `WhizpeeActionButton` |
| C06 | IconButton | `WhizpeeIconButton` |
| C35 | AsyncState | `WhizpeeAsyncState` |
| C40 | Toast | `WhizpeeToast` |
| C11 | StatusBadge | `WhizpeeStatusBadge` |
| C31 | PublicationPriceSummary | `WhizpeePublicationPriceSummary` |
| C32 | BalanceCard | `WhizpeeBalanceCard` |
| C33 | LedgerRow | `WhizpeeLedgerRow` |
| C36 | ProgressIndicator | `WhizpeeProgressIndicator` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 56 high; 72 when a subtitle is needed; 44×44 action targets | Title 20/26, weight 700; action icon 20, 8 gap |
| Body gutter | 20 compact; 24 medium; 32 expanded/large | Use logical horizontal/vertical insets |
| Field/button | 48-high text fields; 44-high buttons; 12 internal horizontal padding | Label 12/18; input 14/21; field-to-field gap 16 |
| Sections | 24 between major sections; 16 within a section; 8 label/control gap | Divider 1, card radius 12, button radius 9 |
| Receipt rows | Min 40 per row; label 12/18 and value 14/20; gap 16 | Total separated by 1 px border, top inset 16; wrap reference values |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; centered content max 640; gutter 20. |
| Medium | icon rail 76 and single active pane; centered content max 640; gutter 24. |
| Expanded | icon rail 76; centered content max 640; gutter 32. |
| Large | icon rail 76; centered content max 640; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Publish validates current config.
- insufficient → S17.
- config changed → D14.
- limit → D15.
- success → P50.
- retry retains draft.

## Rules, guards and failure recovery

- Example paid-category video/audio ad 5+50+100=155 Credits.
- Photo Status consumes slot even in paid category.
- Debit/create/slot change once.
- Ordinary 24 h,Boost 48 h plus one eligible 24 h extension,max 72 h.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V074 — Image slot available | Show post-publication slot usage. |
| V075 — Paid-category image uses slot | Charge category fee and consume available image slot. |
| V076 — Video / audio Boost mandatory | Include Boost in price and eligibility. |
| V077 — Video / audio advertisement total | Include category + mandatory Boost + advertisement fee. |
| V078 — Insufficient Credits | Route through shared balance sheet and resume after confirmed top-up. |
| V079 — Price / configuration changed | Require refreshed itemized review. |
| V080 — Publishing in progress | Show upload/publish progress and prevent duplicate submit. |
| V081 — Publication failed | Preserve selected media/targeting and offer retry. |
| V082 — Publication succeeded | Open publication details / own viewer with success feedback. |

## Scrolling, focus and keyboard

- The content pane owns vertical scroll; persistent master navigation has independent scroll. Do not nest unbounded vertical scrollers.
- Tab follows visual order; focus ring is visible in both themes. Escape dismisses the top dismissible overlay. Browser Back returns to the contextual source.
- Preserve query/draft/selection when a child route or picker closes. On save, restore focus to the source row or next logical action.

## Visual acceptance

- Open `P44` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
