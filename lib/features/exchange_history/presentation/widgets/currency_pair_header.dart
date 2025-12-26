import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A header widget displaying currency pair with flags and swap button.
class CurrencyPairHeader extends StatelessWidget {
  const CurrencyPairHeader({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromCurrencyName,
    required this.toCurrencyName,
    super.key,
    this.fromFlagUrl,
    this.toFlagUrl,
    this.onSwapTap,
  });

  /// The source currency code.
  final String fromCurrency;

  /// The target currency code.
  final String toCurrency;

  /// The source currency full name.
  final String fromCurrencyName;

  /// The target currency full name.
  final String toCurrencyName;

  /// Optional flag URL for source currency.
  final String? fromFlagUrl;

  /// Optional flag URL for target currency.
  final String? toFlagUrl;

  /// Callback when swap button is tapped.
  final VoidCallback? onSwapTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Currency flags stacked
        _buildStackedFlags(),
        SizedBox(width: 4.w),
        // Currency pair info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$fromCurrency / $toCurrency',
                style: TextStyle(
                  fontSize: 18.dp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                '$fromCurrencyName to $toCurrencyName',
                style: TextStyle(
                  fontSize: 13.dp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Swap button
        GestureDetector(
          onTap: onSwapTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedFlags() {
    return SizedBox(
      width: 60,
      height: 40,
      child: Stack(
        children: [
          // First flag (behind)
          Positioned(
            left: 0,
            child: _buildFlagCircle(fromFlagUrl),
          ),
          // Second flag (in front)
          Positioned(
            left: 22,
            child: _buildFlagCircle(toFlagUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCircle(String? flagUrl) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: flagUrl != null
            ? CachedNetworkImage(
                imageUrl: flagUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildFlagPlaceholder(),
                errorWidget: (context, url, error) => _buildFlagPlaceholder(),
              )
            : _buildFlagPlaceholder(),
      ),
    );
  }

  Widget _buildFlagPlaceholder() {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.flag_rounded,
        size: 18,
        color: Colors.grey.shade400,
      ),
    );
  }
}
