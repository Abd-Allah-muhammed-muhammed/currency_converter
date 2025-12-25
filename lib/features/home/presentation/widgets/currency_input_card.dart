import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/utils/colors.dart';

/// A widget for currency selection dropdown.
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.currencyCode,
    this.flagUrl,
    this.onTap,
  });

  /// The currency code to display (e.g., USD, EUR).
  final String currencyCode;

  /// Optional flag image URL.
  final String? flagUrl;

  /// Callback when the selector is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flag placeholder
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: flagUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: flagUrl!,
                        fit: BoxFit.cover,
                        width: 28,
                        height: 28,
                        placeholder: (context, url) => Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.flag_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
            ),
            SizedBox(width: 2.w),
            Text(
              currencyCode,
              style: TextStyle(
                fontSize: 14.dp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// A card widget for currency input (YOU PAY / YOU GET).
class CurrencyInputCard extends StatelessWidget {
  const CurrencyInputCard({
    super.key,
    required this.label,
    required this.currencyCode,
    required this.currencyName,
    this.amount,
    this.controller,
    this.flagUrl,
    this.isEditable = false,
    this.isResult = false,
    this.onAmountChanged,
    this.onCurrencyTap,
  });

  /// The label for the card (e.g., "YOU PAY", "YOU GET").
  final String label;

  /// The amount to display (used when not editable).
  final String? amount;

  /// Text controller for editable amount.
  final TextEditingController? controller;

  /// The currency code (e.g., USD, EUR).
  final String currencyCode;

  /// The full currency name.
  final String currencyName;

  /// Optional flag image URL.
  final String? flagUrl;

  /// Whether the amount field is editable.
  final bool isEditable;

  /// Whether this card shows the result (styled differently).
  final bool isResult;

  /// Callback when amount is changed.
  final ValueChanged<String>? onAmountChanged;

  /// Callback when currency selector is tapped.
  final VoidCallback? onCurrencyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.dp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: isEditable
                    ? TextField(
                        controller: controller,
                        onChanged: onAmountChanged,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 32.dp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 32.dp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        amount ?? '0',
                        style: TextStyle(
                          fontSize: 32.dp,
                          fontWeight: FontWeight.bold,
                          color: isResult ? AppColors.cyan : AppColors.textPrimary,
                        ),
                      ),
              ),
              CurrencySelector(
                currencyCode: currencyCode,
                flagUrl: flagUrl,
                onTap: onCurrencyTap,
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            currencyName,
            style: TextStyle(
              fontSize: 13.dp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A swap button widget for switching currencies.
class SwapCurrencyButton extends StatelessWidget {
  const SwapCurrencyButton({
    super.key,
    this.onTap,
  });

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cyan,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.swap_vert_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
