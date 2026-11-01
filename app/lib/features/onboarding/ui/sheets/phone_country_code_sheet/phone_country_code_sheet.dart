import '../../../copy/onboarding_copy.dart';
import '../../../../../shared/widgets/app_search_field.dart';

import 'package:flutter/material.dart';

import '../../../models/phone_number.dart';

/// Searches the offline country list and returns the selected dialing code.
class PhoneCountryCodeSheet extends StatefulWidget {
  const PhoneCountryCodeSheet({super.key, required this.selected});

  final PhoneCountry selected;

  @override
  State<PhoneCountryCodeSheet> createState() => _PhoneCountryCodeSheetState();
}

class _PhoneCountryCodeSheetState extends State<PhoneCountryCodeSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final matching = PhoneCountry.countries.where((country) {
      final value = '${country.name} ${country.code}'.toLowerCase();
      return value.contains(query.trim().toLowerCase());
    }).toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              OnboardingCopy.countryCode,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            AppSearchField(
              key: const ValueKey('country_code_search'),
              query: query,
              hintText: OnboardingCopy.searchCountryOrCode,
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: matching.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(OnboardingCopy.noCountriesMatchYourSearch),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: matching.length,
                      itemBuilder: (context, index) {
                        final country = matching[index];
                        return ListTile(
                          title: Text(country.name),
                          subtitle: Text(country.code),
                          trailing: country.code == widget.selected.code
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, country),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
