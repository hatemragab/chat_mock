import '../../../copy/app_copy.dart';

import '../../../../shared/widgets/app_scaffold.dart';

import 'package:flutter/material.dart';

import '../../widgets/main_navigation_bar.dart';

import '../../../../features/calls/controllers/calls_controller.dart';
import '../../../../features/calls/models/call_session.dart';
import '../../../../features/calls/ui/screens/call_screen/call_screen.dart';
import '../../../../features/calls/ui/screens/calls_screen/calls_screen.dart';
import '../../../../features/calls/ui/widgets/minimized_call_bar.dart';
import '../../../../features/chats/controllers/chats_controller.dart';
import '../../../../features/chats/models/chat_models.dart';
import '../../../../features/chats/ui/screens/chats_screen/chats_screen.dart';
import '../../../../features/discover/ui/screens/discover_screen/discover_screen.dart';
import '../../../../features/discover/controllers/discover_controller.dart';
import '../../../../features/groups/controllers/group_controller.dart';
import '../../../../features/groups/controllers/group_directory.dart';
import '../../../../features/groups/ui/screens/create_group_screen/create_group_screen.dart';
import '../../../../features/groups/ui/screens/group_screen/group_screen.dart';
import '../../../../features/onboarding/controllers/onboarding_controller.dart';
import '../../../../features/business/controllers/business_controller.dart';
import '../../../../features/business/ui/screens/business_profile_screen/business_profile_screen.dart';
import '../../../../features/business/ui/screens/business_conversation_screen/business_conversation_screen.dart';
import '../../../../features/profile/ui/screens/profile_screen/profile_screen.dart';
import '../../../../features/profile/copy/profile_copy.dart';
import '../../../../features/prototype_tools/ui/screens/prototype_tools_screen/prototype_tools_screen.dart';
import '../../../../features/publishing/controllers/publishing_controller.dart';
import '../../../../features/publishing/ui/screens/publishing_screen/publishing_screen.dart';
import '../../../../features/publishing/ui/screens/publications_screen/publications_screen.dart';
import '../../../../features/settings/ui/screens/appearance_screen/appearance_screen.dart';
import '../../../../features/settings/controllers/settings_controller.dart';
import '../../../../features/settings/ui/screens/settings_screen/settings_screen.dart';
import '../../../../features/settings/ui/screens/edit_business_profile_screen/edit_business_profile_screen.dart';
import '../../../../features/support/ui/screens/help_screen/help_screen.dart';
import '../../../../features/settings/ui/dialogs/sign_out_dialog/sign_out_dialog.dart';
import '../../../../features/stories/controllers/stories_controller.dart';
import '../../../../features/stories/models/story.dart';
import '../../../../features/stories/ui/screens/status_screen/status_screen.dart';
import '../../../../features/wallet/controllers/wallet_controller.dart';
import '../../../../features/wallet/models/wallet_models.dart';
import '../../../../features/wallet/ui/screens/balance_activity_screen/balance_activity_screen.dart';
import '../../../../features/wallet/ui/screens/wallet_screen/wallet_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.wallet,
    required this.chats,
    required this.discover,
    required this.calls,
    required this.publishing,
    required this.group,
    required this.groups,
    required this.business,
    required this.settings,
    required this.profile,
    required this.stories,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onSignOut,
    required this.onReset,
    required this.onAdvanceClock,
    required this.profileName,
    required this.onProfileUpdated,
  });
  final WalletController wallet;
  final ChatsController chats;
  final DiscoverController discover;
  final CallsController calls;
  final PublishingController publishing;
  final GroupController group;
  final GroupDirectory groups;
  final BusinessController business;
  final SettingsController settings;
  final OnboardingController profile;
  final StoriesController stories;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onSignOut;
  final VoidCallback onReset;
  final ValueChanged<Duration> onAdvanceClock;
  final String profileName;
  final VoidCallback onProfileUpdated;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  late final void Function(ChatConversation, bool) _callHandler;

  @override
  void initState() {
    super.initState();
    _callHandler = _startContactCall;
    widget.chats.onStartCall = _callHandler;
  }

  @override
  void dispose() {
    if (identical(widget.chats.onStartCall, _callHandler)) {
      widget.chats.onStartCall = null;
    }
    super.dispose();
  }

  void _startContactCall(ChatConversation chat, bool video) {
    if (!widget.chats.canCommunicateWithContact(chat)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppCopy.mutualMatchRequired)),
      );
      return;
    }
    if (widget.calls.active != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppCopy.endCurrentCall)));
      return;
    }
    final call = widget.calls.start(
      name: chat.name,
      kind: video ? CallKind.video : CallKind.audio,
      contactId: chat.id,
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CallScreen(controller: widget.calls, call: call),
      ),
    );
  }

  Future<void> _createGroup() async {
    final group = await Navigator.push<GroupController>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGroupScreen(directory: widget.groups),
      ),
    );
    if (!mounted || group == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => GroupScreen(controller: group)),
    );
  }

  void _startBusinessCall(Story story, bool video) {
    if (widget.calls.active != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppCopy.endCurrentCall)));
      return;
    }
    final call = widget.calls.start(
      name: story.author,
      kind: video ? CallKind.video : CallKind.audio,
      business: true,
      storyId: story.id,
      story: story,
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CallScreen(controller: widget.calls, call: call),
      ),
    );
  }

  Widget _businessProfile(Story story) => BusinessProfileScreen(
    controller: widget.business,
    story: story,
    onCall: _startBusinessCall,
  );

  void _openBusinessProfile(Story story) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => _businessProfile(story)),
  );
  void _openWallet() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => WalletScreen(controller: widget.wallet),
    ),
  );
  void _openSettings() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => SettingsScreen(
        controller: widget.settings,
        profile: widget.profile,
        stories: widget.stories,
        onAppearance: _openAppearance,
        onSignOut: widget.onSignOut,
        onProfileUpdated: widget.onProfileUpdated,
      ),
    ),
  );
  void _openPublishing() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PublishingScreen(
        controller: widget.publishing,
        settings: widget.settings,
      ),
    ),
  );
  void _openAppearance() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => AppearanceScreen(
        mode: widget.themeMode,
        onChanged: widget.onThemeChanged,
        textScaleFactor: widget.settings.textScaleFactor,
        onTextScaleChanged: widget.settings.setTextScaleFactor,
      ),
    ),
  );
  void _openPrototypeTools() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PrototypeToolsScreen(
        chats: widget.chats,
        discover: widget.discover,
        calls: widget.calls,
        group: widget.group,
        groups: widget.groups,
        business: widget.business,
        publishing: widget.publishing,
        stories: widget.stories,
        wallet: widget.wallet,
        settings: widget.settings,
        profile: widget.profile,
        onProfileUpdated: widget.onProfileUpdated,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onReset: widget.onReset,
        onAdvanceClock: widget.onAdvanceClock,
        onOnboarding: widget.onSignOut,
      ),
    ),
  );
  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutDialog(),
    );
    if (confirmed == true && mounted) widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ListenableBuilder(
        listenable: widget.stories,
        builder: (context, _) => DiscoverScreen(
          controller: widget.stories,
          discover: widget.discover,
          onBusinessProfile: _openBusinessProfile,
          businessController: widget.business,
          settings: widget.settings,
        ),
      ),
      ChatsScreen(
        controller: widget.chats,
        onCreateGroup: _createGroup,
        specialMessageScreenBuilder: (chat, messageId) {
          final group = widget.groups.forChat(chat.id);
          if (group != null) {
            return GroupScreen(controller: group, initialMessageId: messageId);
          }
          final story = widget.business.storyForChat(chat);
          return story == null
              ? null
              : BusinessConversationScreen(
                  controller: widget.business,
                  story: story,
                  initialMessageId: messageId,
                );
        },
        specialScreenBuilder: (chat) {
          final group = widget.groups.forChat(chat.id);
          if (group != null) {
            return GroupScreen(controller: group);
          }
          if (chat.kind == ChatKind.business) {
            final story = widget.business.storyForChat(chat);
            if (story != null) {
              return BusinessConversationScreen(
                controller: widget.business,
                story: story,
              );
            }
          }
          return null;
        },
      ),
      CallsScreen(controller: widget.calls, chats: widget.chats),
      StatusScreen(
        controller: widget.stories,
        chatsController: widget.chats,
        businessController: widget.business,
        onBusinessProfile: _openBusinessProfile,
        settings: widget.settings,
        onDiscover: () => setState(() => selected = 0),
        onCreate: _openPublishing,
      ),
      ProfileScreen(
        onWallet: _openWallet,
        onAppearance: _openAppearance,
        onSignOut: _signOut,
        onPrototypeTools: _openPrototypeTools,
        onPublishing: _openPublishing,
        onSettings: _openSettings,
        wallet: widget.wallet,
        onBusinessTools: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                EditBusinessProfileScreen(controller: widget.settings),
          ),
        ),
        onPublications: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PublicationsScreen(
              controller: widget.publishing,
              settings: widget.settings,
            ),
          ),
        ),
        onEarnings: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BalanceActivityScreen(
              controller: widget.wallet,
              kind: BalanceKind.diamonds,
            ),
          ),
        ),
        onSupport: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
        ),
        name: widget.profileName,
        about: widget.settings.about,
        photoLabel: widget.profile.photoSelected
            ? (widget.profile.photoLabel ?? ProfileCopy.profilePhotoLabel)
            : null,
      ),
    ];
    return AppScaffold(
      safeArea: false,
      body: Column(
        children: [
          MinimizedCallBar(
            controller: widget.calls,
            onReturn: () {
              final call = widget.calls.active;
              if (call == null) return;
              widget.calls.setMinimized(false);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CallScreen(controller: widget.calls, call: call),
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(index: selected, children: tabs),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        selectedIndex: selected,
        onSelected: (index) => setState(() => selected = index),
      ),
    );
  }
}
