# P34 — Full-screen Story viewer

Feature: Stories and Discover. Surface: Page. Layout family: `story_stage`.

**Implementation contract:** This file defines the responsive design and Flutter behavior. The HTML prototype demonstrates the flow; it is not a Flutter implementation.

**Validation status:** Surface exists in the inherited prototype registry; responsive specification is documented. Visual and interaction verification are tracked separately in `coverage_matrix.csv`.

## Purpose and route context

Image/video/audio; own/contact/Business modes; segmented progress, next/previous, hold/pause, volume, report and eligible Contact.

- Entry: Status / Discover / Business profile / My Publications.
- Exit: Source page, Story viewers or Business contact.
- Typed context: `storyId; mode:own/contact/business; sourceReturnTo; publicationId?; position`.
- Flutter screen: `FullScreenStoryViewerScreen`; each screen has its own directory within its feature.

The route owns its contextual IDs. Do not infer a different selected entity from whichever screen was visited last. Reopening the route with the same IDs shows the existing in-session object.

## Ordered anatomy

1. Segmented progress.
2. Source identity and options.
3. Fit 9:16 photo/video/audio stage.
4. Pause/mute/previous/next controls.
5. Caption.
6. Own viewers or eligible Business Contact CTA.

## Shared component bindings

| ID | Component | Flutter widget |
|---|---|---|
| C01 | AdaptiveScaffold | `WhizpeeAdaptiveScaffold` |
| C02 | AppHeader | `WhizpeeAppHeader` |
| C05 | ActionButton | `WhizpeeActionButton` |
| C06 | IconButton | `WhizpeeIconButton` |
| C35 | AsyncState | `WhizpeeAsyncState` |
| C40 | Toast | `WhizpeeToast` |
| C24 | MediaAttachment | `WhizpeeMediaAttachment` |
| C29 | StoryViewer | `WhizpeeStoryViewer` |
| C30 | CallPreview | `WhizpeeCallPreview` |
| C36 | ProgressIndicator | `WhizpeeProgressIndicator` |

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
| Compact | bottom navigation if route permits; stage max 420; gutter 20. |
| Medium | icon rail 76 and single active pane; stage max 420; gutter 24. |
| Expanded | icon rail 76; stage max 420; Status master 336 only for contact/own Story; no master for Business Story entered from Discover; gutter 32. |
| Large | icon rail 76; stage max 420; Status master 336 only for contact/own Story; no master for Business Story entered from Discover; gutter 32. |

At a breakpoint, move the existing logical destination into its new container. Preserve selected IDs, draft fields, message delivery state and financial operation references. Layout changes are never a submit or a retry.

## Actions and outcomes

- Hold/pause.
- next/previous.
- options → S12/S14.
- own viewers → P51.
- eligible Business contact → S16.
- profile → P36.

## Rules, guards and failure recovery

- Max stage 420 logical px wide, proportionate to available height.
- Expired/removed disables new paid contact.
- Promoted analytics aggregate.
- Story expiry does not end an active room.

## Loading, empty and scenario states

| Scenario | Required visible behavior |
|---|---|
| V056 — Contact Story | Show privacy-permitted contact identity. |
| V057 — Business Story | Use originating cover and public Business context. |
| V058 — Own Story | Show management/viewers entry. |
| V059 — Image playback | Show timed segments. |
| V060 — Video playback | Play video and advance when complete. |
| V061 — Audio playback | Show cover/waveform and audio controls. |
| V062 — Seen Story | Keep accessible until expiration with seen appearance. |
| V063 — Paused Story | Hold/pause freezes playback progress. |
| V064 — Muted playback | Reflect audio mute status. |
| V065 — Expired Story | Prevent new eligible paid contact action. |
| V066 — Removed Story | Stop distribution and show unavailable explanation. |
| V067 — Story media failed to load | Retry or move to next eligible Story. |

## Scrolling, focus and keyboard

- The media stage fits the viewport; controls remain within safe areas. Escape closes an eligible overlay/viewer and returns focus to its source.
- Media is proportionately contained; close, previous/next and playback controls remain keyboard reachable.

## Visual acceptance

- Open `P34` at 386×802, 768×1024, 1280×900 and 1600×1000 logical pixels in both themes.
- Check no horizontal overflow; app-bar titles never overlap 44×44 actions; controls remain usable at increased text size.
- Verify the page-specific actions and guards above. Record actual results rather than inferring that registry presence means behavior passed.
