import 'package:flutter/material.dart';

import '../../../../../shared/copy/common_copy.dart';
import '../../../../../shared/widgets/app_search_field.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../copy/prototype_tools_copy.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/review_actions.dart';
import '../../../models/review_entry.dart';

enum _InventoryFilter {
  all(''),
  pages('P'),
  sheets('S'),
  dialogs('D'),
  scenarios('V');

  const _InventoryFilter(this.prefix);
  final String prefix;
}

class ReviewCatalogScreen extends StatefulWidget {
  const ReviewCatalogScreen({super.key, required this.actions});
  final ReviewActions actions;

  @override
  State<ReviewCatalogScreen> createState() => _ReviewCatalogScreenState();
}

class _ReviewCatalogScreenState extends State<ReviewCatalogScreen> {
  String query = '';
  _InventoryFilter filter = _InventoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final results = reviewEntries.where((entry) {
      final matchesFilter = entry.id.startsWith(filter.prefix);
      final matchesQuery = '${entry.id} ${entry.title}'.toLowerCase().contains(
        query.trim().toLowerCase(),
      );
      return matchesFilter && matchesQuery;
    }).toList();
    return AppScaffold(
      appBar: AppHeader(title: const Text(PrototypeToolsCopy.reviewInventory)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: AppSearchField(
              query: query,
              onChanged: (value) => setState(() => query = value),
              hintText: PrototypeToolsCopy.searchIdOrName,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final item in _InventoryFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(switch (item) {
                        _InventoryFilter.all => CommonCopy.all,
                        _InventoryFilter.pages => PrototypeToolsCopy.pages,
                        _InventoryFilter.sheets => PrototypeToolsCopy.sheets,
                        _InventoryFilter.dialogs => PrototypeToolsCopy.dialogs,
                        _InventoryFilter.scenarios =>
                          PrototypeToolsCopy.scenarios,
                      }),
                      selected: filter == item,
                      onSelected: (_) => setState(() => filter = item),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                widget.actions.group,
                widget.actions.business,
                widget.actions.publishing,
                widget.actions.chats,
                widget.actions.calls,
                widget.actions.wallet,
                widget.actions.stories,
                widget.actions.discover,
                widget.actions.profile,
                widget.actions.settings,
              ]),
              builder: (context, _) => results.isEmpty
                  ? const Center(
                      child: Text(PrototypeToolsCopy.noMatchingReviewItems),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final entry = results[index];
                        final available = widget.actions.canOpen(entry.id);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SizedBox(
                            width: 50,
                            child: Text(
                              entry.id,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(entry.title),
                          subtitle: Text(
                            available
                                ? PrototypeToolsCopy.openCurrentImplementation
                                : PrototypeToolsCopy
                                      .notAvailableInTheCurrentSession,
                          ),
                          trailing: available
                              ? const Icon(Icons.chevron_right)
                              : null,
                          enabled: available,
                          onTap: available
                              ? () => widget.actions.open(context, entry.id)
                              : null,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
