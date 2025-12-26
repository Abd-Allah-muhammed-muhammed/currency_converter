import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Data model for exchange rate chart points.
class ExchangeRateData {
  ExchangeRateData({required this.date, required this.rate});
  final DateTime date;
  final double rate;
}

/// A widget that displays exchange rate history as a line chart.
class ExchangeRateChart extends StatelessWidget {
  const ExchangeRateChart({
    super.key,
    this.data,
    this.height = 120,
  });

  /// The exchange rate data points to display.
  final List<ExchangeRateData>? data;

  /// The height of the chart.
  final double height;

  /// Returns mock data for UI demonstration.
  List<ExchangeRateData> get _mockData => [
    ExchangeRateData(date: DateTime(2025, 12, 18), rate: 0.91),
    ExchangeRateData(date: DateTime(2025, 12, 19), rate: 0.915),
    ExchangeRateData(date: DateTime(2025, 12, 20), rate: 0.905),
    ExchangeRateData(date: DateTime(2025, 12, 21), rate: 0.92),
    ExchangeRateData(date: DateTime(2025, 12, 22), rate: 0.935),
    ExchangeRateData(date: DateTime(2025, 12, 23), rate: 0.925),
    ExchangeRateData(date: DateTime(2025, 12, 24), rate: 0.92),
  ];

  @override
  Widget build(BuildContext context) {
    final chartData = data ?? _mockData;

    return SizedBox(
      height: height,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: const DateTimeAxis(
          isVisible: false,
          majorGridLines: MajorGridLines(width: 0),
        ),
        primaryYAxis: const NumericAxis(
          isVisible: false,
          majorGridLines: MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<ExchangeRateData, DateTime>>[
          SplineAreaSeries<ExchangeRateData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ExchangeRateData data, _) => data.date,
            yValueMapper: (ExchangeRateData data, _) => data.rate,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.chartGradientStart,
                AppColors.chartGradientEnd,
              ],
            ),
            borderColor: AppColors.chartLine,
            borderWidth: 3,
          ),
        ],
      ),
    );
  }
}
