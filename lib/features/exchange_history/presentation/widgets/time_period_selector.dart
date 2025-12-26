import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// Available time period options for historical data.
enum TimePeriod {
  oneWeek('1W'),
  oneMonth('1M'),
  threeMonths('3M'),
  oneYear('1Y');

  const TimePeriod(this.label);
  final String label;
}

/// A widget for selecting time period tabs.
class TimePeriodSelector extends StatelessWidget {
  const TimePeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    super.key,
  });

  /// The currently selected time period.
  final TimePeriod selectedPeriod;

  /// Callback when a time period is selected.
  final ValueChanged<TimePeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.8.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cardBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: TextStyle(
                      fontSize: 14.dp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.cyan
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
