import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_converter/core/utils/colors.dart';
import 'package:currency_converter/core/utils/widgets/cached_flag_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A list item widget for displaying a currency option.
class CurrencyListItem extends StatelessWidget {
  const CurrencyListItem({
    required this.currencyCode,
    required this.currencyName,
    super.key,
    this.flagUrl,
    this.isSelected = false,
    this.onTap,
  });

  /// The currency code (e.g., USD, EUR).
  final String currencyCode;

  /// The full currency name.
  final String currencyName;

  /// Optional flag image URL.
  final String? flagUrl;

  /// Whether this currency is currently selected.
  final bool isSelected;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.cyan : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag
            _buildFlag(),
            SizedBox(width: 4.w),
            // Currency info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyName,
                    style: TextStyle(
                      fontSize: 15.dp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    currencyCode,
                    style: TextStyle(
                      fontSize: 13.dp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark if selected
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: flagUrl != null
            ? CachedFlagImage(
                flagUrl: flagUrl!,
                 width: 48,
                height: 48,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
