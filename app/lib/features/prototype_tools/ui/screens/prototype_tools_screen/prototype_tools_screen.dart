import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/copy/common_copy.dart';
import '../../../copy/prototype_tools_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../../calls/controllers/calls_controller.dart';
import '../../../../calls/models/call_session.dart';
import '../../../../calls/ui/screens/call_screen/call_screen.dart';
import '../../../../chats/controllers/chats_controller.dart';
import '../../../../discover/controllers/discover_controller.dart';
import '../../../../business/controllers/business_controller.dart';
import '../../../../groups/controllers/group_controller.dart';
import '../../../../groups/controllers/group_directory.dart';
import '../../../../onboarding/controllers/onboarding_controller.dart';
import '../../../../publishing/controllers/publishing_controller.dart';
import '../../../../settings/controllers/settings_controller.dart';
import '../../../../stories/controllers/stories_controller.dart';
import '../../../../wallet/controllers/wallet_controller.dart';
import '../../../controllers/review_actions.dart';
import '../../widgets/group_business_controls.dart';
import '../../widgets/direct_receipt_review_controls.dart';
import '../../widgets/publication_review_controls.dart';
import '../../widgets/wallet_review_controls.dart';
import '../review_catalog_screen/review_catalog_screen.dart';

class PrototypeToolsScreen extends StatefulWidget {
  const PrototypeToolsScreen({
    super.key,
    required this.chats,
    this.discover,
    required this.calls,
    required this.group,
    this.groups,
    required this.business,
    required this.publishing,
    required this.stories,
    required this.wallet,
    required this.onReset,
    required this.onOnboarding,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onAdvanceClock,
    this.settings,
    this.profile,
    this.onProfileUpdated,
  });
  final ChatsController chats;
  final DiscoverController? discover;
  final CallsController calls;
  final GroupController group;
  final GroupDirectory? groups;
  final BusinessController business;
  final PublishingController publishing;
  final StoriesController stories;
  final WalletController wallet;
  final VoidCallback onReset;
  final VoidCallback onOnboarding;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Duration> onAdvanceClock;
  final SettingsController? settings;
  final OnboardingController? profile;
  final VoidCallback? onProfileUpdated;

  @override
  State<PrototypeToolsScreen> createState() => _PrototypeToolsScreenState();
}

class _PrototypeToolsScreenState extends State<PrototypeToolsScreen> {
  late ThemeMode themeMode = widget.themeMode;

  @override
  Widget build(BuildContext context) {
    final chats = widget.chats;
    final calls = widget.calls;
    final group = widget.group;
    final business = widget.business;
    final wallet = widget.wallet;
    return AppScaffold(
      appBar: AppHeader(title: const Text(PrototypeToolsCopy.prototypeTools)),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          chats,
          calls,
          group,
          business,
          wallet,
          widget.publishing,
        ]),
        builder: (context, _) {
          final incomingContact = chats.conversations
              .where((chat) => chat.id == 'sarah')
              .firstOrNull;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                PrototypeToolsCopy.reviewControls,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(PrototypeToolsCopy.sessionControlsDescription),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.search),
                title: const Text(PrototypeToolsCopy.searchReviewInventory),
                subtitle: const Text(PrototypeToolsCopy.inventoryDescription),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ReviewCatalogScreen(
                      actions: ReviewActions(
                        chats: chats,
                        discover: widget.discover,
                        calls: calls,
                        group: group,
                        groups: widget.groups,
                        business: business,
                        publishing: widget.publishing,
                        stories: widget.stories,
                        wallet: wallet,
                        settings: widget.settings,
                        profile: widget.profile,
                        onProfileUpdated: widget.onProfileUpdated,
                        onThemeChanged: widget.onThemeChanged,
                        themeMode: themeMode,
                        onSignOut: widget.onOnboarding,
                      ),
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<ThemeMode>(
                initialValue: themeMode,
                decoration: const InputDecoration(
                  labelText: PrototypeToolsCopy.appearance,
                ),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(PrototypeToolsCopy.light),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(PrototypeToolsCopy.dark),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(PrototypeToolsCopy.system),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => themeMode = value);
                    widget.onThemeChanged(value);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(PrototypeToolsCopy.online),
                subtitle: const Text(
                  PrototypeToolsCopy.offlineMessagesDescription,
                ),
                value: chats.online,
                onChanged: chats.setOnline,
              ),
              DirectReceiptReviewControls(chats: chats),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mark_chat_unread_outlined),
                title: const Text(PrototypeToolsCopy.simulateAnIncomingMessage),
                subtitle: Text(
                  PrototypeToolsCopy.incomingMessage(incomingContact?.name),
                ),
                enabled:
                    chats.online &&
                    chats.conversations.any(
                      (chat) => chat.id == 'sarah' && chats.canSendTo(chat),
                    ),
                onTap: () {
                  final matches = chats.conversations.where(
                    (chat) => chat.id == 'sarah',
                  );
                  if (matches.isNotEmpty) {
                    chats.receiveContactMessage(
                      matches.first,
                      'Hi Alex, are you free to catch up?',
                    );
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(PrototypeToolsCopy.callPermissionsAvailable),
                subtitle: const Text(
                  PrototypeToolsCopy.simulateMicrophoneAndCameraPermission,
                ),
                value: calls.permissionGranted,
                onChanged: calls.setPermissionGranted,
              ),
              if (calls.active case final call?) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text(PrototypeToolsCopy.advanceCallByOneMinute),
                  subtitle: Text(PrototypeToolsCopy.currentCall(call.name)),
                  enabled:
                      call.phase == CallPhase.active ||
                      call.phase == CallPhase.reconnecting,
                  onTap: () => calls.advance(60),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.call_outlined),
                  title: const Text(PrototypeToolsCopy.returnToActiveCall),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CallScreen(controller: calls, call: call),
                    ),
                  ),
                ),
                if (call.phase == CallPhase.ringing ||
                    call.phase == CallPhase.incoming)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final outcome in [
                        CallPhase.busy,
                        CallPhase.declined,
                        CallPhase.missed,
                      ])
                        OutlinedButton(
                          onPressed: () => calls.finishRinging(outcome),
                          child: Text(outcome.name),
                        ),
                    ],
                  ),
                if (call.phase == CallPhase.active ||
                    call.phase == CallPhase.reconnecting)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(PrototypeToolsCopy.callReconnecting),
                    value: call.phase == CallPhase.reconnecting,
                    onChanged: calls.setReconnecting,
                  ),
              ] else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.call_received),
                  title: const Text(PrototypeToolsCopy.simulateAnIncomingCall),
                  enabled:
                      chats.online &&
                      incomingContact != null &&
                      chats.canCommunicateWithContact(incomingContact),
                  onTap: () {
                    final contact = incomingContact;
                    if (contact == null ||
                        !chats.online ||
                        !chats.canCommunicateWithContact(contact)) {
                      return;
                    }
                    final call = calls.start(
                      name: contact.name,
                      kind: CallKind.audio,
                      incoming: true,
                      contactId: contact.id,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CallScreen(controller: calls, call: call),
                      ),
                    );
                  },
                ),
              const Divider(),
              GroupBusinessControls(
                group: group,
                business: business,
                onAdvanceClock: widget.onAdvanceClock,
              ),
              const Divider(height: 32),
              PublicationReviewControls(publishing: widget.publishing),
              const Divider(height: 32),
              WalletReviewControls(wallet: wallet),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.login),
                title: const Text(PrototypeToolsCopy.startOnboarding),
                onTap: () {
                  Navigator.pop(context);
                  widget.onOnboarding();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt),
                title: const Text(PrototypeToolsCopy.resetDemo),
                subtitle: const Text(PrototypeToolsCopy.resetDescription),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(PrototypeToolsCopy.resetDemoTitle),
                      content: const Text(
                        PrototypeToolsCopy.sessionChangesWillBeLost,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text(CommonCopy.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(PrototypeToolsCopy.reset),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    Navigator.pop(context);
                    widget.onReset();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
