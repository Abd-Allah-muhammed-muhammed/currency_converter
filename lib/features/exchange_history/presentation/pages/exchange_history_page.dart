import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import '../../../../core/utils/colors.dart';
import '../widgets/currency_pair_header.dart';
import '../widgets/exchange_rate_display.dart';
import '../widgets/time_period_selector.dart';
import '../widgets/history_chart.dart';
import '../widgets/statistics_row.dart';

/// Page displaying historical exchange rate data.
class ExchangeHistoryPage extends StatefulWidget {
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
  State<ExchangeHistoryPage> createState() => _ExchangeHistoryPageState();
}

class _ExchangeHistoryPageState extends State<ExchangeHistoryPage> {
  // State
  TimePeriod _selectedPeriod = TimePeriod.oneWeek;
  late String _fromCurrency;
  late String _toCurrency;
  late String _fromCurrencyName;
  late String _toCurrencyName;

  // Mock data
  double _currentRate = 0.9245;
  double _changePercentage = 0.05;
  bool _isPositive = true;
  double _highRate = 0.9310;
  double _lowRate = 0.9105;
  double _avgRate = 0.9200;

  @override
  void initState() {
    super.initState();
    _fromCurrency = widget.fromCurrency;
    _toCurrency = widget.toCurrency;
    _fromCurrencyName = widget.fromCurrencyName;
    _toCurrencyName = widget.toCurrencyName;
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
      // TODO: Fetch new data based on period
    });
  }

  void _onSwapCurrencies() {
    setState(() {
      final tempCurrency = _fromCurrency;
      final tempName = _fromCurrencyName;
      _fromCurrency = _toCurrency;
      _fromCurrencyName = _toCurrencyName;
      _toCurrency = tempCurrency;
      _toCurrencyName = tempName;
      // Recalculate inverse rate
      _currentRate = 1 / _currentRate;
      _highRate = 1 / _lowRate;
      _lowRate = 1 / _highRate;
      _avgRate = 1 / _avgRate;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              // Currency info card
              _buildCurrencyInfoCard(),
              SizedBox(height: 3.h),
              // Time period selector
              TimePeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),
              SizedBox(height: 2.h),
              // Chart
              HistoryChart(
                showDayLabels: false,
              ),
              SizedBox(height: 1.h),
              // Day labels
              const DayLabelsRow(),
              SizedBox(height: 4.h),
              // Statistics
              StatisticsRow(
                high: _highRate,
                low: _lowRate,
                average: _avgRate,
                periodLabel: _selectedPeriod.label,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
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

  Widget _buildCurrencyInfoCard() {
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
            fromCurrency: _fromCurrency,
            toCurrency: _toCurrency,
            fromCurrencyName: _fromCurrencyName,
            toCurrencyName: _toCurrencyName,
            fromFlagUrl: _getFlagUrl(_fromCurrency),
            toFlagUrl: _getFlagUrl(_toCurrency),
            onSwapTap: _onSwapCurrencies,
          ),
          SizedBox(height: 2.h),
          // Exchange rate display
          ExchangeRateDisplay(
            rate: _currentRate,
            toCurrency: _toCurrency,
            changePercentage: _changePercentage,
            isPositive: _isPositive,
          ),
        ],
      ),
    );
  }
}
