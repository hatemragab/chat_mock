import 'copy/app_copy.dart';
import '../features/calls/copy/calls_copy.dart';

import 'package:flutter/material.dart';

import '../core/demo/demo_clock.dart';
import '../core/config/demo_config.dart';
import '../features/calls/controllers/calls_controller.dart';
import '../features/calls/models/call_session.dart';
import '../features/business/controllers/business_controller.dart';
import '../features/chats/controllers/chats_controller.dart';
import '../features/chats/models/chat_models.dart';
import '../features/creator_tools/controllers/creator_activity_controller.dart';
import '../features/discover/controllers/discover_controller.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';
import '../features/groups/controllers/group_controller.dart';
import '../features/groups/controllers/group_directory.dart';
import '../features/onboarding/ui/screens/onboarding_screen/onboarding_screen.dart';
import '../features/publishing/controllers/publishing_controller.dart';
import '../features/settings/controllers/settings_controller.dart';
import '../features/settings/adapters/settings_contacts_session.dart';
import '../features/settings/models/settings_models.dart';
import '../features/stories/controllers/stories_controller.dart';
import '../features/wallet/controllers/wallet_controller.dart';
import 'theme/app_theme.dart';
import 'theme/composed_text_scaler.dart';
import 'ui/screens/home_shell/home_shell.dart';

class WhizpeeApp extends StatefulWidget {
  const WhizpeeApp({super.key});
  @override
  State<WhizpeeApp> createState() => _WhizpeeAppState();
}

class _WhizpeeAppState extends State<WhizpeeApp> {
  final clock = DemoClock();
  final config = const DemoConfig();
  late final WalletController wallet;
  final chats = ChatsController();
  final discover = DiscoverController();
  late final StoriesController stories;
  final onboarding = OnboardingController();
  late final CallsController calls;
  late final PublishingController publishing;
  late final GroupController group;
  late final GroupDirectory groups;
  late final BusinessController business;
  late final SettingsController settings;
  ThemeMode themeMode = ThemeMode.system;
  bool signedIn = true;
  int sessionVersion = 0;

  void _resetDemo() {
    calls.reset();
    discover.reset();
    clock.reset();
    publishing.reset();
    wallet.reset();
    groups.reset();
    chats.reset();
    group.reset();
    business.reset();
    settings.reset();
    stories.reset();
    onboarding.reset();
    setState(() {
      themeMode = ThemeMode.system;
      signedIn = true;
      sessionVersion++;
    });
  }

  void _advanceClock(Duration duration) {
    clock.advance(duration);
    business.advance(Duration.zero);
    publishing.refreshExpiry();
  }

  void _signOut() {
    final call = calls.active;
    if (call != null) {
      if (call.phase == CallPhase.ringing || call.phase == CallPhase.incoming) {
        calls.finishRinging(
          call.incoming ? CallPhase.declined : CallPhase.cancelled,
        );
      } else {
        calls.end(reason: AppCopy.signedOutCallReason);
      }
    }
    setState(() => signedIn = false);
  }

  @override
  void initState() {
    super.initState();
    wallet = WalletController(
      config: config.wallet,
      clock: clock.now,
      seedActivity: true,
    );
    settings = SettingsController(chats: chats);
    onboarding.bindContactsSession(SettingsContactsSession(settings));
    chats.readReceiptsEnabled = () => settings.readReceipts;
    chats.canMessage = () => settings.canMessage;
    chats.onIncomingMessage = (chat, message) => settings.notifications.receive(
      kind: NotificationKind.message,
      sender: chat.name,
      message: message.text,
      blocked: chat.blocked,
    );
    settings.addListener(_settingsChanged);
    chats.addListener(_connectivityChanged);
    discover.load();
    ChatConversation? resolveCallContact(CallSession call) {
      final matches = chats.conversations.where(
        (chat) =>
            chat.kind == ChatKind.contact &&
            (call.contactId != null
                ? chat.id == call.contactId
                : chat.name == call.name),
      );
      return matches.length == 1 ? matches.single : null;
    }

    calls = CallsController(
      spendCredits: (id, amount, description) =>
          wallet.spendCredits(id: id, amount: amount, description: description),
      availableCredits: () => wallet.credits,
      canRecallContact: (call) {
        final contact = resolveCallContact(call);
        return contact != null && chats.canCommunicateWithContact(contact);
      },
      contactName: (call) => resolveCallContact(call)?.name,
      contactChanges: chats,
      seedHistory: true,
      audioBlockCredits: config.business.audioBlockCredits,
      videoBlockCredits: config.business.videoBlockCredits,
      onIncomingCall: (call) => settings.notifications.receive(
        kind: NotificationKind.call,
        sender: call.name,
        message: CallsCopy.incomingKind(call.kind.label),
      ),
    );
    publishing = PublishingController(
      wallet: wallet,
      config: config.publishing,
      clock: clock.now,
      seedPublications: true,
      authorName: () =>
          onboarding.name.isEmpty ? 'Alex Morgan' : onboarding.name,
      canPublish: () => settings.canPublish,
      canShareStatusWith: settings.canShareStatusWith,
    );
    stories = StoriesController(publishing: publishing, clock: clock.now);
    group = GroupController(chats: chats);
    groups = GroupDirectory(chats: chats, initialGroup: group);
    business = BusinessController(
      wallet: wallet,
      config: config.business,
      clock: clock.now,
      stories: stories,
      chats: chats,
      settings: settings,
    );
    publishing.attachContactActivity(
      CreatorActivityController(business: business, calls: calls),
    );
  }

  void _settingsChanged() => chats.refreshConversations();
  void _connectivityChanged() => discover.setOnline(chats.online);

  @override
  void dispose() {
    settings.removeListener(_settingsChanged);
    chats.removeListener(_connectivityChanged);
    calls.dispose();
    groups.dispose();
    group.dispose();
    business.dispose();
    stories.dispose();
    publishing.dispose();
    onboarding.dispose();
    settings.dispose();
    wallet.dispose();
    chats.dispose();
    discover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppCopy.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.create(Brightness.light),
      darkTheme: AppTheme.create(Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: ComposedTextScaler(
                media.textScaler,
                settings.textScaleFactor,
              ),
            ),
            child: child!,
          );
        },
      ),
      home: signedIn
          ? HomeShell(
              key: ValueKey(sessionVersion),
              wallet: wallet,
              chats: chats,
              discover: discover,
              calls: calls,
              publishing: publishing,
              group: group,
              groups: groups,
              business: business,
              settings: settings,
              profile: onboarding,
              stories: stories,
              themeMode: themeMode,
              onThemeChanged: (mode) => setState(() => themeMode = mode),
              onSignOut: _signOut,
              onReset: _resetDemo,
              onAdvanceClock: _advanceClock,
              onProfileUpdated: () => setState(() {}),
              profileName: onboarding.name.isEmpty
                  ? 'Alex Morgan'
                  : onboarding.name,
            )
          : OnboardingScreen(
              controller: onboarding,
              onComplete: () => setState(() => signedIn = true),
            ),
    );
  }
}
