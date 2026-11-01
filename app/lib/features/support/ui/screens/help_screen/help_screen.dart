import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_state_view.dart';

import '../../../copy/support_copy.dart';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../help_article_screen/help_article_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String query = '';
  final Map<String, String> topics = const {
    SupportCopy.gettingStarted:
        SupportCopy.chooseYourInterestsAndCompleteYourProfileTo,
    SupportCopy.privacyAndBlocking:
        SupportCopy.controlYourProfilePhotoVisibilityAndStatusAudience,
    SupportCopy.walletAndCredits:
        SupportCopy.creditsAreUsedForEligibleActionsDiamondsAre,
    SupportCopy.storiesAndPublishing:
        SupportCopy.createAStatusOrAnAdvertisementInPublishing,
    SupportCopy.callsAndChats:
        SupportCopy.personalCallsAreFreeBusinessCallsShowTheir,
  };
  @override
  Widget build(BuildContext context) {
    final results = topics.entries
        .where(
          (entry) => '${entry.key} ${entry.value}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(SupportCopy.helpSupport)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppSearchField(
            query: query,
            hintText: SupportCopy.searchHelpTopics,
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            const AppStateView(
              title: SupportCopy.noHelpArticlesMatchYourSearch,
            ),
          ...results.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.key),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      HelpArticleScreen(title: entry.key, content: entry.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
