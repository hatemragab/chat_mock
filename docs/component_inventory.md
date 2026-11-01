# Shared component audit

The implementation uses a single Flutter theme and feature-based components. Native buttons, icon buttons, dropdowns, chips and confirmation surfaces use the shared theme rather than adding parallel control systems.

| Required responsibility | Owning source/evidence | Remaining work |
| --- | --- | --- |
| Page scaffold and app bar | `shared/widgets/app_scaffold.dart`, `app_header.dart`; safe areas, keyboard resizing, compact/subtitle geometry and truncation | Native rendering review |
| Main navigation | `app/ui/widgets/main_navigation_bar.dart` | Native rendering review |
| Buttons and icon buttons | `app/theme/app_theme.dart`, `app_spacing.dart`; centralized shapes, minimum sizes and palette | Review specialized media controls |
| Form fields and validation | `shared/widgets/app_form_field.dart`, onboarding `phone_field.dart`; feature-owned draft/validation state | Audit remaining specialized forms for useful reuse |
| Search | `shared/widgets/app_search_field.dart`; retained query/controller, clear action and ownership | Review all remaining search entry paths |
| Sections and rows | `app_section_heading.dart`, `app_person_row.dart`, `app_selectable_person_row.dart`, chats `conversation_list_row.dart`, groups `group_member_row.dart`, wallet rows | Native rendering review |
| Personal and Business identity | Shared `app_avatar.dart`; feature profile/group photo controls; calls `business_call_story_cover.dart` and Story covers | Native rendering review |
| Conversation layout | Shared `conversation_layout.dart` used by direct, group and Business screens; preserves bounded thread, context, notices and composer | Full state/visual review |
| Messages, timestamps, receipts, quotes and reactions | Chats `message_bubble.dart`, receipt models/screens and message actions | Full state/visual review |
| Composer, emoji, recording, attachments | Shared `chat_composer.dart`, typed attachment drafts/edits and `chat_media_visual.dart`; local crop/rotation/caption/replacement/trim | Full state/visual review |
| Contact/member selection | Chats `recipient_picker_screen.dart`, shared selectable person rows and feature member rows | Full state/visual review |
| Stories | `story_cover.dart`, `story_media_background.dart`, `story_progress_segments.dart`, `story_viewer_header.dart`, shared viewer | Native rendering review |
| Publication prices | `publication_price_breakdown.dart` reused by review, changed-price dialog and original publication terms | Native rendering review |
| Balances, ledger and receipts | `wallet/ui/widgets/wallet_balance_card.dart`, `wallet_ledger_row.dart`, `wallet_receipt_field.dart` | Native rendering review |
| Loading, empty, error and success | `shared/widgets/app_state_view.dart`; contextual Discover skeleton/error components | Remaining state adoption audit |
| Sheets and confirmations | Feature-owned reusable sheets/dialogs with target arguments | Complete inventory acceptance |

English interface copy now belongs to `app/copy`, `shared/copy` and feature `copy` classes, including parameterized descriptions. Stable fixtures, media sample names, technical identifiers and numeric formatting remain data. This provides an English source catalog; it does not add runtime language switching.
