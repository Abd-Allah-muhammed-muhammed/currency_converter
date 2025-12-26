import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A search text field widget for currency search.
class CurrencySearchField extends StatelessWidget {
  const CurrencySearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search currency or code...',
  });

  /// Text controller for the search field.
  final TextEditingController? controller;

  /// Callback when search text changes.
  final ValueChanged<String>? onChanged;

  /// Placeholder text.
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14.dp,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.dp,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.cyan,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
        ),
      ),
    );
  }
}
