# P07 — Complete profile and phone

Feature: Onboarding. Surface: Page. Layout family: `form`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Name/photo, gender, required phone and consent; phone is not OTP-gated.

- Entry: First sign-in.
- Exit: Interest selection.
- Typed context: `mode:onboarding; profileDraft; phone:{countryCode,local,international}`.
- Flutter screen: `CompleteProfileAndPhoneScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Complete profile app bar.
2. Centered photo button with camera badge.
3. Name.
4. Horizontal phone-prefix/local-number control.
5. Gender.
6. Terms/Privacy consent.
7. Inline errors.
8. Continue footer.

## Shared component bindings

| ID | Component | Flutter widget |
|---|---|---|
| C01 | AdaptiveScaffold | `WhizpeeAdaptiveScaffold` |
| C02 | AppHeader | `WhizpeeAppHeader` |
| C05 | ActionButton | `WhizpeeActionButton` |
| C06 | IconButton | `WhizpeeIconButton` |
| C35 | AsyncState | `WhizpeeAsyncState` |
| C40 | Toast | `WhizpeeToast` |
| C07 | FormField | `WhizpeeFormField` |
| C08 | PhoneNumberField | `WhizpeePhoneNumberField` |
| C10 | FilterChip | `WhizpeeFilterChip` |
| C13 | ProfilePhotoEditor | `WhizpeeProfilePhotoEditor` |
| C15 | SettingsRow | `WhizpeeSettingsRow` |
| C26 | ContactMemberRow | `WhizpeeContactMemberRow` |
| C37 | ToggleRow | `WhizpeeToggleRow` |

Use these components where the anatomy calls for their role; their presence in this mapping does not require showing an irrelevant control. Screen-local composition remains with this screen; dimensions and states resolve through `component_specs.json` and `design_tokens.json`.

## Dimensions and alignment

| Region | Exact contract | Notes |
|---|---|---|
| Header | 56 high; 72 when a subtitle is needed; 44×44 action targets | Title 20/26, weight 700; action icon 20, 8 gap |
| Body gutter | 20 compact; 24 medium; 32 expanded/large | Use logical horizontal/vertical insets |
| Field/button | 48-high text fields; 44-high buttons; 12 internal horizontal padding | Label 12/18; input 14/21; field-to-field gap 16 |
| Sections | 24 between major sections; 16 within a section; 8 label/control gap | Divider 1, card radius 12, button radius 9 |

Use the semantic light/dark tokens and bundled font specified in `design_tokens.json`. Never infer a different color or font weight from screenshots. Avatar, icon and media sizes are layout dimensions, not replacements for accessible interaction targets.

## Responsive composition

| Mode | Composition |
|---|---|
| Compact | bottom navigation if route permits; centered content max 640; gutter 20. |
| Medium | standalone bounded onboarding/legal content; no navigation rail; max 640; gutter 24. |
| Expanded | standalone bounded onboarding/legal content; no navigation rail; max 640; gutter 32. |
| Large | standalone bounded onboarding/legal content; no navigation rail; max 640; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Photo → S05.
- prefix → S01.
- legal → P10/P11.
- Continue → P08 after validation.

## Rules, guards and failure recovery

- Require nonempty trimmed name, valid composed number and consent.
- No OTP.
- Prefix and local number stay side by side.
- International paste updates both without duplication.
- Validation appears next to the affected field, retains other input and moves focus to the first invalid control after explicit submission. A failed mutation keeps its draft and supports a meaningful retry.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V007 — Invalid required phone / profile | Inline field errors; preserve values. |
| V008 — Terms not accepted | Keep continuation unavailable until required consent. |

## Scrolling, focus and keyboard

- The content pane owns vertical scroll; persistent master navigation has independent scroll. Do not nest unbounded vertical scrollers.
- Tab follows visual order; focus ring is visible in both themes. Escape dismisses the top dismissible overlay. Browser Back returns to the contextual source.
- Preserve query/draft/selection when a child route or picker closes. On save, restore focus to the source row or next logical action.

## Visual acceptance

- Open `P07` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
