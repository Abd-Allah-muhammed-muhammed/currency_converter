import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A section header widget for currency list sections.
class CurrencySectionHeader extends StatelessWidget {
  const CurrencySectionHeader({
    required this.title,
    super.key,
  });

  /// The section title.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, bottom: 1.5.h, top: 1.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.dp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
