import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/colors.dart';
import '../../domain/entities/exchange_history.dart';
import '../cubit/exchange_history_cubit.dart';
import '../cubit/exchange_history_state.dart';
import '../widgets/currency_pair_header.dart';
import '../widgets/exchange_rate_display.dart';
import '../widgets/time_period_selector.dart';
import '../widgets/history_chart.dart';
import '../widgets/statistics_row.dart';

/// Page displaying historical exchange rate data.
class ExchangeHistoryPage extends StatelessWidget {
  const ExchangeHistoryPage({
    super.key,
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.fromCurrencyName = 'US Dollar',
    this.toCurrencyName = 'Euro',
  });

  /// The source currency code.
  final String fromCurrency;

  /// The target currency code.
  final String toCurrency;

  /// The source currency full name.
  final String fromCurrencyName;

  /// The target currency full name.
  final String toCurrencyName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExchangeHistoryCubit>(
      create: (context) => sl<ExchangeHistoryCubit>()
        ..loadHistory(
          sourceCurrency: fromCurrency,
          targetCurrency: toCurrency,
          sourceCurrencyName: fromCurrencyName,
          targetCurrencyName: toCurrencyName,
          days: 7,
        ),
      child: const _ExchangeHistoryView(),
    );
  }
}

class _ExchangeHistoryView extends StatefulWidget {
  const _ExchangeHistoryView();

  @override
  State<_ExchangeHistoryView> createState() => _ExchangeHistoryViewState();
}

class _ExchangeHistoryViewState extends State<_ExchangeHistoryView> {
  TimePeriod _selectedPeriod = TimePeriod.oneWeek;

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });

    final days = _getDaysForPeriod(period);
    context.read<ExchangeHistoryCubit>().changePeriod(days);
  }

  int _getDaysForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.oneWeek:
        return 7;
      case TimePeriod.oneMonth:
        return 30;
      case TimePeriod.threeMonths:
        return 90;
      case TimePeriod.oneYear:
        return 365;
    }
  }

  void _onSwapCurrencies() {
    context.read<ExchangeHistoryCubit>().swapCurrencies();
  }

  String? _getFlagUrl(String currencyCode) {
    final currencyToCountry = {
      'USD': 'us',
      'EUR': 'eu',
      'GBP': 'gb',
      'JPY': 'jp',
      'EGP': 'eg',
      'SAR': 'sa',
      'AED': 'ae',
      'CAD': 'ca',
      'AUD': 'au',
      'CHF': 'ch',
      'CNY': 'cn',
      'INR': 'in',
    };

    final countryCode = currencyToCountry[currencyCode];
    if (countryCode != null) {
      return 'https://flagcdn.com/w80/$countryCode.png';
    }
    return null;
  }

  List<HistoryChartData> _convertToChartData(List<RateDataPoint> rates) {
    return rates
        .map((r) => HistoryChartData(date: r.date, rate: r.rate))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: BlocBuilder<ExchangeHistoryCubit, ExchangeHistoryState>(
        builder: (context, state) {
          if (state is ExchangeHistoryInitial ||
              state is ExchangeHistoryLoading) {
            return _buildLoadingState();
          }

          if (state is ExchangeHistoryError) {
            return _buildErrorState(state);
          }

          if (state is ExchangeHistoryLoaded) {
            return _buildLoadedState(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Exchange History',
        style: TextStyle(
          fontSize: 18.dp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_horiz_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            // TODO: Show options menu
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.cyan),
    );
  }

  Widget _buildErrorState(ExchangeHistoryError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Failed to load exchange history',
              style: TextStyle(
                fontSize: 16.dp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              state.message,
              style: TextStyle(fontSize: 14.dp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                context.read<ExchangeHistoryCubit>().retry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14.dp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(ExchangeHistoryLoaded state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            // Currency info card
            _buildCurrencyInfoCard(state),
            SizedBox(height: 3.h),
            // Time period selector
            TimePeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
            ),
            SizedBox(height: 2.h),
            // Chart
            HistoryChart(
              data: _convertToChartData(state.chartData),
              showDayLabels: false,
            ),
            SizedBox(height: 1.h),
            // Day labels (only show for 1W period)
            if (_selectedPeriod == TimePeriod.oneWeek) const DayLabelsRow(),
            SizedBox(height: 4.h),
            // Statistics
            StatisticsRow(
              high: state.highRate,
              low: state.lowRate,
              average: state.averageRate,
              periodLabel: _selectedPeriod.label,
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInfoCard(ExchangeHistoryLoaded state) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
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
          // Currency pair header
          CurrencyPairHeader(
            fromCurrency: state.sourceCurrency,
            toCurrency: state.targetCurrency,
            fromCurrencyName: state.sourceCurrencyName,
            toCurrencyName: state.targetCurrencyName,
            fromFlagUrl: _getFlagUrl(state.sourceCurrency),
            toFlagUrl: _getFlagUrl(state.targetCurrency),
            onSwapTap: _onSwapCurrencies,
          ),
          SizedBox(height: 2.h),
          // Exchange rate display
          ExchangeRateDisplay(
            rate: state.currentRate,
            toCurrency: state.targetCurrency,
            changePercentage: state.changePercentage,
            isPositive: state.isPositiveChange,
          ),
        ],
      ),
    );
  }
}
