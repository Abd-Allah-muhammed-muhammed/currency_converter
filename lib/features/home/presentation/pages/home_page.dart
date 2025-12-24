import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_definitions/exchange_history_routes.dart';
import '../../../../core/utils/colors.dart';
import '../../../currency/domain/entities/currency.dart';
import '../widgets/exchange_rate_card.dart';
import '../widgets/currency_input_card.dart';
import '../widgets/quick_select_chips.dart';

/// The main home page for the currency converter app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  Timer? _debounceTimer;
  
  // Debounce duration in milliseconds
  static const int _debounceDuration = 500;

  // Mock data for UI demonstration
  String _fromCurrency = 'USD';
  String _fromCurrencyName = 'United States Dollar';
  String _toCurrency = 'EUR';
  String _toCurrencyName = 'Euro';
  String _convertedAmount = '0.00';
  double _exchangeRate = 0.92;
  int? _selectedQuickAmount;

  @override
  void initState() {
    super.initState();
    _amountController.text = '1000';
    _convertAmount(_amountController.text);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Clear quick select when user types
    if (_selectedQuickAmount != null) {
      setState(() {
        _selectedQuickAmount = null;
      });
    }
    
    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: _debounceDuration), () {
      _convertAmount(value);
    });
  }

  void _convertAmount(String value) {
    final amount = double.tryParse(value) ?? 0;
    setState(() {
      _convertedAmount = (amount * _exchangeRate).toStringAsFixed(2);
    });
    // TODO: Call API for real conversion
    debugPrint('Converting: $value to $_convertedAmount');
  }

  List<QuickSelectOption> get _quickSelectOptions => [
        QuickSelectOption(
          amount: 100,
          currency: _fromCurrency,
          isSelected: _selectedQuickAmount == 100,
        ),
        QuickSelectOption(
          amount: 500,
          currency: _fromCurrency,
          isSelected: _selectedQuickAmount == 500,
        ),
        QuickSelectOption(
          amount: 1000,
          currency: _fromCurrency,
          isSelected: _selectedQuickAmount == 1000,
        ),
        QuickSelectOption(
          amount: 5000,
          currency: _fromCurrency,
          isSelected: _selectedQuickAmount == 5000,
        ),
      ];

  void _onQuickSelectTapped(QuickSelectOption option) {
    _amountController.text = option.amount.toString();
    setState(() {
      _selectedQuickAmount = option.amount;
      _convertedAmount = (option.amount * _exchangeRate).toStringAsFixed(2);
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
      // Recalculate with inverse rate
      _exchangeRate = 1 / _exchangeRate;
      final amount = double.tryParse(_amountController.text) ?? 0;
      _convertedAmount = (amount * _exchangeRate).toStringAsFixed(2);
    });
  }

  Future<void> _openFromCurrencyPicker() async {
    final result = await context.push<Currency>(
      '/currency-picker',
      extra: _fromCurrency,
    );
    if (result != null && mounted) {
      setState(() {
        _fromCurrency = result.code;
        _fromCurrencyName = result.name;
        // Recalculate conversion
        final amount = double.tryParse(_amountController.text) ?? 0;
        _convertedAmount = (amount * _exchangeRate).toStringAsFixed(2);
      });
    }
  }

  Future<void> _openToCurrencyPicker() async {
    final result = await context.push<Currency>(
      '/currency-picker',
      extra: _toCurrency,
    );
    if (result != null && mounted) {
      setState(() {
        _toCurrency = result.code;
        _toCurrencyName = result.name;
        // Recalculate conversion
        final amount = double.tryParse(_amountController.text) ?? 0;
        _convertedAmount = (amount * _exchangeRate).toStringAsFixed(2);
      });
    }
  }

  void _openExchangeHistory() {
    context.push(
      '/exchange-history',
      extra: ExchangeHistoryArgs(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        fromCurrencyName: _fromCurrencyName,
        toCurrencyName: _toCurrencyName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              // Header
              _buildHeader(),
              SizedBox(height: 3.h),
              // Exchange Rate Card with Chart
              ExchangeRateCard(
                fromCurrency: _fromCurrency,
                toCurrency: _toCurrency,
                rate: _exchangeRate,
                onTap: _openExchangeHistory,
              ),
              SizedBox(height: 3.h),
              // Currency Converter Section
              _buildConverterSection(),
              SizedBox(height: 2.h),
              // Exchange Rate Info
              _buildExchangeRateInfo(),
              SizedBox(height: 3.h),
              // Quick Select
              QuickSelectChips(
                options: _quickSelectOptions,
                onOptionSelected: _onQuickSelectTapped,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Currency Converter',
          style: TextStyle(
            fontSize: 22.dp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConverterSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // YOU PAY Card
            CurrencyInputCard(
              label: 'YOU PAY',
              controller: _amountController,
              currencyCode: _fromCurrency,
              currencyName: _fromCurrencyName,
              flagUrl: _getFlagUrl(_fromCurrency),
              isEditable: true,
              onAmountChanged: _onAmountChanged,
              onCurrencyTap: _openFromCurrencyPicker,
            ),
            SizedBox(height: 2.h),
            // YOU GET Card
            CurrencyInputCard(
              label: 'YOU GET',
              amount: _convertedAmount,
              currencyCode: _toCurrency,
              currencyName: _toCurrencyName,
              flagUrl: _getFlagUrl(_toCurrency),
              isResult: true,
              onCurrencyTap: _openToCurrencyPicker,
            ),
          ],
        ),
        // Swap Button
        Positioned(
          child: SwapCurrencyButton(
            onTap: _onSwapCurrencies,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeRateInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textMuted,
        ),
        SizedBox(width: 2.w),
        Text(
          'Mid-market exchange rate at ${_getCurrentTime()}',
          style: TextStyle(
            fontSize: 12.dp,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} UTC';
  }

  String? _getFlagUrl(String currencyCode) {
    // Map currency codes to country codes for flag
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
    };

    final countryCode = currencyToCountry[currencyCode];
    if (countryCode != null) {
      return 'https://flagcdn.com/w40/$countryCode.png';
    }
    return null;
  }
}
