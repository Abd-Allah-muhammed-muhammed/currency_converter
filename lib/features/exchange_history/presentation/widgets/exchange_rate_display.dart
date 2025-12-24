import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/utils/colors.dart';

/// A widget displaying the current exchange rate with change percentage.
class ExchangeRateDisplay extends StatelessWidget {
  const ExchangeRateDisplay({
    super.key,
    required this.rate,
    required this.toCurrency,
    this.changePercentage = 0.0,
    this.isPositive = true,
  });

  /// The current exchange rate.
  final double rate;

  /// The target currency code.
  final String toCurrency;

  /// The percentage change.
  final double changePercentage;

  /// Whether the change is positive.
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              rate.toStringAsFixed(4),
              style: TextStyle(
                fontSize: 32.dp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              toCurrency,
              style: TextStyle(
                fontSize: 16.dp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: isPositive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 13.dp,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 13.dp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
