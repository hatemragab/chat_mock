import 'package:flutter/material.dart';

import '../copy/common_copy.dart';

/// A query field whose visible text follows its retained query or controller.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.query = '',
    this.controller,
    this.autofocus = false,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String query;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _owned;
  final _focus = FocusNode();
  TextEditingController get _controller => widget.controller ?? _owned!;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  void _bind() {
    if (widget.controller == null) {
      _owned = TextEditingController(text: widget.query);
    }
    _controller.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _owned!).removeListener(_changed);
      _owned?.dispose();
      _owned = null;
      _bind();
    } else if (widget.controller == null &&
        oldWidget.query != widget.query &&
        _controller.text != widget.query) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _owned?.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focus,
    autofocus: widget.autofocus,
    textInputAction: TextInputAction.search,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: widget.hintText,
      suffixIcon: _controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: CommonCopy.clearSearch,
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
                _focus.requestFocus();
              },
              icon: const Icon(Icons.close),
            ),
    ),
  );
}
