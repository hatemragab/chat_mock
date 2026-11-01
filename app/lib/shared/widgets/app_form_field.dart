import 'package:flutter/material.dart';

/// Standard editable field; the caller retains its draft and validation state.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.error,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    minLines: minLines,
    maxLines: maxLines,
    maxLength: maxLength,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      errorMaxLines: 3,
    ),
  );
}
