# Remaining implementation and acceptance work

The 124-surface and 130-scenario inventories remain the scope. Existing dispatch paths, passing tests and layout matrices are evidence for their named behavior, not blanket sign-off.

## Confirmed implementation work

- No further concrete feature gap was found in the latest bounded source review after its corrections. This is not full visual or native acceptance.
- Keep the evidence ledgers aligned with actual user actions tested; do not treat route counts as acceptance.

Completed organization work includes feature English-copy catalogs and parameterized messages, shared scaffold/header/navigation, form/search/section/state/person rows, avatars, conversation layout, Story progress/header controls, publication price breakdown and responsive wallet components. Wallet correlations, call end causes and chat/publication/call-history/review filters use typed state. Fixtures and stable technical identifiers remain data.

The latest requirement pass added public Business metadata, Group info member previews/actions, global conversation-name search, original publication terms and category descriptions. Chat attachment editing, contact reports, file metadata, unsent receipt labels, group photos/submission retry, Business message actions and incoming video previews have regression coverage. Combined validation passed 750 tests, formatting, analysis and Android/web builds; see the acceptance audit.

## Remaining acceptance work

- Verify every page/sheet/dialog requirement and contextual return path, using the surface and scenario evidence ledgers. The current presentation matrices cover many complete customer flows but not every state/data combination.
- Review all surfaces against the standalone visual specification and available permitted references. Browser security policy denied access to the local HTML reference; do not work around that denial.
- Verify the remaining layouts and theme states outside the documented matrices, including long content, safe areas, keyboard use and scaled text.
- Native/device and full offline-runtime validation remain unproven. Current project targets are Android and web; device/UI tests are restricted to the specified iPhone simulator. Do not substitute a device or add an iOS target without user direction.

## Delivery evidence

Keep run instructions, build artifacts and actual formatter/analyzer/test/build results current in the README and acceptance audit. Do not mark the goal complete until the full requirement audit is supported by current evidence.
