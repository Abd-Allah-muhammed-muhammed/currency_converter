import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A card widget displaying a single statistic.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    required this.label,
    required this.value,
    super.key,
  });

  /// The label of the statistic (e.g., "High", "Low", "Avg").
  final String label;

  /// The value to display.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.dp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.dp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of statistics cards displaying High, Low, and Average values.
class StatisticsRow extends StatelessWidget {
  const StatisticsRow({
    required this.high,
    required this.low,
    required this.average,
    required this.periodLabel,
    super.key,
  });

  /// The highest rate in the period.
  final double high;

  /// The lowest rate in the period.
  final double low;

  /// The average rate in the period.
  final double average;

  /// The label for the period (e.g., "1W").
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics ($periodLabel)',
          style: TextStyle(
            fontSize: 16.dp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: StatisticCard(
                label: 'High',
                value: high.toStringAsFixed(4),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: StatisticCard(
                label: 'Low',
                value: low.toStringAsFixed(4),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: StatisticCard(
                label: 'Avg',
                value: average.toStringAsFixed(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
