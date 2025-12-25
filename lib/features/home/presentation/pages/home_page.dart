import 'package:currency_converter/core/di/injectable_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_definitions/exchange_history_routes.dart';
 import '../../../../core/utils/colors.dart';
import '../../../currency/domain/entities/currency.dart';
import '../cubit/convert_cubit.dart';
import '../cubit/convert_state.dart';
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

  // Currency selection
  late String _fromCurrency;
  String _fromCurrencyName = '';
  late String _toCurrency;
  String _toCurrencyName = '';
  int? _selectedQuickAmount;

  // Cubit instance
  late final ConvertCubit _convertCubit;

  @override
  void initState() {
    super.initState();
    _convertCubit = getIt<ConvertCubit>();

    // Restore currencies and amount from preferences via cubit
    _fromCurrency = _convertCubit.fromCurrency;
    _toCurrency = _convertCubit.toCurrency;
    _fromCurrencyName = _getCurrencyName(_fromCurrency);
    _toCurrencyName = _getCurrencyName(_toCurrency);

    // Restore amount or default to 1
    final savedAmount = _convertCubit.currentAmount;
    _amountController.text = savedAmount > 0 ? savedAmount.toString() : '1';

    // Initial conversion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerConversion(immediate: true);
    });
  }

  /// Gets the currency name from the currency code.
  String _getCurrencyName(String code) {
    const currencyNames = {
      'USD': 'United States Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'EGP': 'Egyptian Pound',
      'SAR': 'Saudi Riyal',
      'AED': 'UAE Dirham',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
      'CHF': 'Swiss Franc',
    };
    return currencyNames[code] ?? code;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertCubit.close();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    // Clear quick select when user types
    if (_selectedQuickAmount != null) {
      setState(() {
        _selectedQuickAmount = null;
      });
    }

    final amount = double.tryParse(value) ?? 0;
    if (amount > 0) {
      // Use debounce for user typing
      _convertCubit.convertWithDebounce(
        from: _fromCurrency,
        to: _toCurrency,
        amount: amount,
      );
    }
  }

  void _triggerConversion({bool immediate = false}) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0) {
      if (immediate) {
        _convertCubit.convertImmediately(
          from: _fromCurrency,
          to: _toCurrency,
          amount: amount,
        );
      } else {
        _convertCubit.convertWithDebounce(
          from: _fromCurrency,
          to: _toCurrency,
          amount: amount,
        );
      }
    }
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
    });

    // Call API immediately for quick select
    _convertCubit.convertImmediately(
      from: _fromCurrency,
      to: _toCurrency,
      amount: option.amount.toDouble(),
    );
  }

  void _onSwapCurrencies() {
    setState(() {
      final tempCurrency = _fromCurrency;
      final tempName = _fromCurrencyName;
      _fromCurrency = _toCurrency;
      _fromCurrencyName = _toCurrencyName;
      _toCurrency = tempCurrency;
      _toCurrencyName = tempName;
    });

    // Call API immediately for swap
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0) {
      _convertCubit.convertImmediately(
        from: _fromCurrency,
        to: _toCurrency,
        amount: amount,
      );
    }
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
      });

      // Call API immediately when currency changes
      _triggerConversion(immediate: true);
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
      });

      // Call API immediately when currency changes
      _triggerConversion(immediate: true);
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

    // Default: use first two letters of currency code
    if (currencyCode.length >= 2) {
      return 'https://flagcdn.com/w40/${currencyCode.substring(0, 2).toLowerCase()}.png';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _convertCubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                _buildHeader(),
                SizedBox(height: 3.h),
                _buildExchangeRateCard(),
                SizedBox(height: 3.h),
                _buildConverterSection(),
                SizedBox(height: 2.h),
                _buildExchangeRateInfo(),
                SizedBox(height: 3.h),
                QuickSelectChips(
                  options: _quickSelectOptions,
                  onOptionSelected: _onQuickSelectTapped,
                ),
                SizedBox(height: 4.h),
              ],
            ),
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

  Widget _buildExchangeRateCard() {
    return BlocBuilder<ConvertCubit, ConvertState>(
      builder: (context, state) {
        double rate = 0.0;

        if (state is ConvertSuccess) {
          rate = state.rate;
        } else if (state is ConvertLoading) {
          // Show previous rate if available
          rate = 0.0;
        }

        return ExchangeRateCard(
          fromCurrency: _fromCurrency,
          toCurrency: _toCurrency,
          rate: rate,
          onTap: _openExchangeHistory,
        );
      },
    );
  }

  Widget _buildConverterSection() {
    return BlocBuilder<ConvertCubit, ConvertState>(
      builder: (context, state) {
        String convertedAmount = '0.00';
        bool isLoading = false;
        String? errorMessage;

        if (state is ConvertSuccess) {
          convertedAmount = state.convertedAmount.toStringAsFixed(2);
        } else if (state is ConvertLoading) {
          isLoading = true;
          // Show loading indicator
        } else if (state is ConvertError) {
          errorMessage = state.message;
        }

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
                // YOU GET Card with loading/error states
                _buildYouGetCard(
                  convertedAmount: convertedAmount,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                ),
              ],
            ),
            // Swap Button
            Positioned(child: SwapCurrencyButton(onTap: _onSwapCurrencies)),
          ],
        );
      },
    );
  }

  Widget _buildYouGetCard({
    required String convertedAmount,
    required bool isLoading,
    String? errorMessage,
  }) {
    return Stack(
      children: [
        CurrencyInputCard(
          label: 'YOU GET',
          amount: isLoading ? '...' : convertedAmount,
          currencyCode: _toCurrency,
          currencyName: _toCurrencyName,
          flagUrl: _getFlagUrl(_toCurrency),
          isResult: true,
          onCurrencyTap: _openToCurrencyPicker,
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ),
          ),
        if (errorMessage != null && !isLoading)
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 11.dp, color: Colors.red.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExchangeRateInfo() {
    return BlocBuilder<ConvertCubit, ConvertState>(
      builder: (context, state) {
        String timeText = 'Calculating...';

        if (state is ConvertSuccess) {
          timeText = state.formattedTimestamp;
        } else if (state is ConvertError) {
          timeText = '!';
        }

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
              'Last updated at $timeText',
              style: TextStyle(fontSize: 12.dp, color: AppColors.textMuted),
            ),
          ],
        );
      },
    );
  }
}
