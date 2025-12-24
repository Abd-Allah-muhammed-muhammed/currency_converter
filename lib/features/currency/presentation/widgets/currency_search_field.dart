import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/utils/colors.dart';

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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.2),
          width: 1,
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
          prefixIcon: Icon(
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
