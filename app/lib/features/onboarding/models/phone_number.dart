import '../copy/onboarding_copy.dart';

/// Country dial codes used by the offline prototype's phone picker.
class PhoneCountry {
  const PhoneCountry(this.name, this.code);

  final String name;
  final String code;

  static const countries = <PhoneCountry>[
    PhoneCountry(OnboardingCopy.cameroon, '+237'),
    PhoneCountry(OnboardingCopy.egypt, '+20'),
    PhoneCountry(OnboardingCopy.unitedStates, '+1'),
    PhoneCountry(OnboardingCopy.unitedKingdom, '+44'),
    PhoneCountry(OnboardingCopy.france, '+33'),
    PhoneCountry(OnboardingCopy.nigeria, '+234'),
    PhoneCountry(OnboardingCopy.kenya, '+254'),
    PhoneCountry(OnboardingCopy.india, '+91'),
    PhoneCountry(OnboardingCopy.unitedArabEmirates, '+971'),
  ];
}

/// An editable international number split into a selected prefix and local part.
class PhoneNumber {
  const PhoneNumber({
    required this.country,
    required this.local,
    this.unsupportedPrefix = false,
  });

  final PhoneCountry country;
  final String local;
  final bool unsupportedPrefix;

  String get international => '${country.code}$local';

  String? get validationError {
    if (unsupportedPrefix) return OnboardingCopy.chooseASupportedCountryCode;
    if (local.isEmpty) return OnboardingCopy.enterYourPhoneNumber;
    if (local.length < 6 || international.length > 16) {
      return OnboardingCopy.enterAValidPhoneNumber;
    }
    return null;
  }

  /// Handles both locally entered digits and a pasted + or 00 number.
  PhoneNumber withInput(String input) {
    final trimmed = input.trim();
    final internationalInput =
        trimmed.startsWith('+') || trimmed.startsWith('00');
    var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (!internationalInput) {
      return PhoneNumber(country: country, local: digits);
    }
    if (trimmed.startsWith('00') && digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    final matches =
        PhoneCountry.countries
            .where(
              (candidate) => digits.startsWith(candidate.code.substring(1)),
            )
            .toList()
          ..sort((a, b) => b.code.length.compareTo(a.code.length));
    if (matches.isEmpty) {
      return PhoneNumber(
        country: country,
        local: digits,
        unsupportedPrefix: true,
      );
    }
    final selected = matches.first;
    return PhoneNumber(
      country: selected,
      local: digits.substring(selected.code.length - 1),
    );
  }

  PhoneNumber withCountry(PhoneCountry selected) =>
      PhoneNumber(country: selected, local: local);
}
