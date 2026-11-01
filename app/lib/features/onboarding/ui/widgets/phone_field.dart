import '../../copy/onboarding_copy.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/onboarding_controller.dart';
import '../../models/phone_number.dart';
import '../sheets/phone_country_code_sheet/phone_country_code_sheet.dart';

/// A single horizontal country-prefix and local-number control.
class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.showError = false,
    this.initiallyOpenCountryPicker = false,
  });

  final OnboardingController controller;
  final bool showError;
  final bool initiallyOpenCountryPicker;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late final TextEditingController _number = TextEditingController(
    text: widget.controller.phone.local,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initiallyOpenCountryPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chooseCountry();
      });
    }
  }

  Future<void> _chooseCountry() async {
    final selected = await showModalBottomSheet<PhoneCountry>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) =>
          PhoneCountryCodeSheet(selected: widget.controller.phone.country),
    );
    if (mounted && selected != null) widget.controller.setCountry(selected);
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  void _updateNumber(String value) {
    widget.controller.setPhone(value);
    final normalized = widget.controller.phone.local;
    if (value != normalized) {
      _number.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final error = widget.showError
          ? widget.controller.phone.validationError
          : null;
      final border = Theme.of(context).colorScheme.outlineVariant;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(OnboardingCopy.phoneNumber),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: error == null
                    ? border
                    : Theme.of(context).colorScheme.error,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _chooseCountry,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_drop_down),
                  label: Text(widget.controller.phone.country.code),
                ),
                Container(height: 28, width: 1, color: border),
                Expanded(
                  child: TextField(
                    key: const ValueKey('phone_local'),
                    controller: _number,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [LengthLimitingTextInputFormatter(24)],
                    decoration: const InputDecoration(
                      hintText: OnboardingCopy.phoneNumber,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: _updateNumber,
                  ),
                ),
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}
