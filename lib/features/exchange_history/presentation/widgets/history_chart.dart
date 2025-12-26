import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../core/utils/colors.dart';

/// Data model for history chart points.
class HistoryChartData {
  final DateTime date;
  final double rate;

  HistoryChartData({required this.date, required this.rate});
}

/// A large chart widget for displaying exchange rate history.
class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
     required this.data,
    this.height = 280,
    this.showDayLabels = true,
  });

  /// The exchange rate history data points.
  final List<HistoryChartData> data;

  /// The height of the chart.
  final double height;

  /// Whether to show day labels on X axis.
  final bool showDayLabels;


  @override
  Widget build(BuildContext context) {
    final chartData = data ;
    // Calculate min and max for better visualization
    final rates = chartData.map((e) => e.rate).toList();
    final minRate = rates.reduce((a, b) => a < b ? a : b);
    final maxRate = rates.reduce((a, b) => a > b ? a : b);
    final padding = (maxRate - minRate) * 0.2;

    return SizedBox(
      height: height,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.only(top: 2.h, right: 2.w),
        primaryXAxis: DateTimeAxis(
          isVisible: showDayLabels,
          majorGridLines: const MajorGridLines(width: 0),
          minorGridLines: const MinorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: TextStyle(
            fontSize: 11.dp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),

          intervalType: DateTimeIntervalType.days,
          interval: 1,
          majorTickLines: const MajorTickLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          minimum: minRate - padding,
          maximum: maxRate + padding,
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppColors.textMuted.withValues(alpha: 0.15),
            dashArray: const [5, 5],
          ),
          plotBands: [
            PlotBand(
              start: maxRate,
              end: maxRate,
              borderColor: AppColors.textMuted.withValues(alpha: 0.3),
              borderWidth: 1,
              dashArray: const [5, 5],
            ),
            PlotBand(
              start: minRate,
              end: minRate,
              borderColor: AppColors.textMuted.withValues(alpha: 0.3),
              borderWidth: 1,
              dashArray: const [5, 5],
            ),
          ],
        ),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: AppColors.cyan,
          lineWidth: 1,
          lineDashArray: const [5, 5],
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 12,
            width: 12,
            color: Colors.white,
            borderWidth: 3,
            borderColor: AppColors.cyan,
          ),
          tooltipSettings: const InteractiveTooltip(
            enable: true,
            color: AppColors.textPrimary,
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
        series: <CartesianSeries<HistoryChartData, DateTime>>[
          SplineAreaSeries<HistoryChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (HistoryChartData data, _) => data.date,
            yValueMapper: (HistoryChartData data, _) => data.rate,
            splineType: SplineType.natural,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.cyan.withValues(alpha: 0.3),
                AppColors.cyan.withValues(alpha: 0.05),
              ],
            ),
            borderColor: AppColors.cyan,
            borderWidth: 3,
          ),
        ],
      ),
    );
  }

  dynamic _getDayFormat() {
    // Return day abbreviation format
    return null; // Will use custom label formatter in real implementation
  }
}

/// Custom day label formatter widget.
class DayLabelsRow extends StatelessWidget {
  const DayLabelsRow({super.key});

  static const List<String> _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _days.map((day) {
          return Text(
            day,
            style: TextStyle(
              fontSize: 11.dp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          );
        }).toList(),
      ),
    );
  }
}
