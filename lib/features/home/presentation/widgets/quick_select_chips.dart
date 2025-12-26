import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A model for quick select amount options.
class QuickSelectOption {
  const QuickSelectOption({
    required this.amount,
    required this.currency,
    this.isSelected = false,
  });
  final int amount;
  final String currency;
  final bool isSelected;

  String get displayText => '$amount $currency';
}

/// A chip widget for quick amount selection.
class QuickSelectChip extends StatelessWidget {
  const QuickSelectChip({
    required this.option,
    super.key,
    this.onTap,
  });

  /// The quick select option to display.
  final QuickSelectOption option;

  /// Callback when the chip is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: option.isSelected ? AppColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: option.isSelected
                ? AppColors.cyan
                : AppColors.textMuted.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          option.displayText,
          style: TextStyle(
            fontSize: 13.dp,
            fontWeight: FontWeight.w600,
            color: option.isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// A horizontal list of quick select chips.
class QuickSelectChips extends StatelessWidget {
  const QuickSelectChips({
    required this.options,
    super.key,
    this.onOptionSelected,
  });

  /// The list of quick select options.
  final List<QuickSelectOption> options;

  /// Callback when an option is selected.
  final ValueChanged<QuickSelectOption>? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 14.dp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 1.5.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: QuickSelectChip(
                  option: option,
                  onTap: () => onOptionSelected?.call(option),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
