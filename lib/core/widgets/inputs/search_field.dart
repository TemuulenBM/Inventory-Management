import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/widgets/layout/glass_panel.dart';

/// Search field with glass background and clear button
/// Дизайн: Search icon prefix, glass effect
class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool hasGlassEffect;
  final bool autofocus;

  const SearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.hasGlassEffect = true,
    this.autofocus = false,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Хайх...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.gray500,
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.gray500,
                ),
                onPressed: _onClear,
              )
            : null,
        filled: widget.hasGlassEffect ? false : true,
        fillColor: AppColors.surfaceLight,
        border: widget.hasGlassEffect
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: AppRadius.inputRadius,
                borderSide: const BorderSide(
                  color: AppColors.gray300,
                ),
              ),
        enabledBorder: widget.hasGlassEffect
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: AppRadius.inputRadius,
                borderSide: const BorderSide(
                  color: AppColors.gray300,
                ),
              ),
        focusedBorder: widget.hasGlassEffect
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: AppRadius.inputRadius,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: widget.onChanged,
    );

    if (widget.hasGlassEffect) {
      return GlassPanel(
        padding: EdgeInsets.zero,
        child: searchField,
      );
    }

    return searchField;
  }
}
