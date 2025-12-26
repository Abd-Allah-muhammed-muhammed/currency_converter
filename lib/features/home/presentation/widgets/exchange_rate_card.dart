import 'package:currency_converter/core/utils/colors.dart';
import 'package:currency_converter/features/home/presentation/widgets/exchange_rate_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

/// A card widget displaying the exchange rate with a chart background.
class ExchangeRateCard extends StatelessWidget {
  const ExchangeRateCard({
    super.key,
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.rate = 0.92,
    this.chartData,
    this.onTap,
  });

  /// The source currency code.
  final String fromCurrency;

  /// The target currency code.
  final String toCurrency;

  /// The current exchange rate.
  final double rate;

  /// Optional chart data for display.
  final List<ExchangeRateData>? chartData;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.chartBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Chart at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ExchangeRateChart(
                  data: chartData,
                  height: 100,
                ),
              ),

              // Click indicator icon
              Positioned(
                top: 3.w,
                right: 3.w,
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_circle_right,
                    size: 25.dp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),


              // Content overlay
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXCHANGE RATE',
                      style: TextStyle(
                        fontSize: 11.dp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '1 $fromCurrency',
                          style: TextStyle(
                            fontSize: 22.dp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '≈ $rate $toCurrency',
                          style: TextStyle(
                            fontSize: 14.dp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
