import 'dart:async';

import 'package:currency_converter/config/routes/route_definitions/exchange_history_routes.dart';
import 'package:currency_converter/core/di/injectable_config.dart';
import 'package:currency_converter/core/utils/colors.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_cubit.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_state.dart';
import 'package:currency_converter/features/home/presentation/widgets/currency_input_card.dart';
import 'package:currency_converter/features/home/presentation/widgets/exchange_rate_card.dart';
import 'package:currency_converter/features/home/presentation/widgets/quick_select_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:go_router/go_router.dart';

/// The main home page for the currency converter app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();

  // Cubit instance
  late final ConvertCubit _convertCubit;

  @override
  void initState() {
    super.initState();
    _convertCubit = getIt<ConvertCubit>();

    // Restore amount from cubit
    final savedAmount = _convertCubit.currentAmount;
    _amountController.text = savedAmount > 0 ? savedAmount.toString() : '1';

    // Initial conversion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_convertCubit.triggerConversion());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    unawaited(_convertCubit.close());
    super.dispose();
  }

  void _onAmountChanged(String value) {
    _convertCubit.updateAmount(value);
  }

  List<QuickSelectOption> _buildQuickSelectOptions(ConvertUiState uiState) {
    return [
      QuickSelectOption(
        amount: 100,
        currency: uiState.fromCurrency,
        isSelected: uiState.selectedQuickAmount == 100,
      ),
      QuickSelectOption(
        amount: 500,
        currency: uiState.fromCurrency,
        isSelected: uiState.selectedQuickAmount == 500,
      ),
      QuickSelectOption(
        amount: 1000,
        currency: uiState.fromCurrency,
        isSelected: uiState.selectedQuickAmount == 1000,
      ),
      QuickSelectOption(
        amount: 5000,
        currency: uiState.fromCurrency,
        isSelected: uiState.selectedQuickAmount == 5000,
      ),
    ];
  }

  void _onQuickSelectTapped(QuickSelectOption option) {
    _amountController.text = option.amount.toString();
    unawaited(_convertCubit.selectQuickAmount(option.amount));
  }

  void _onSwapCurrencies() {
    unawaited(_convertCubit.swapCurrencies());
  }

  Future<void> _openFromCurrencyPicker() async {
    final result = await context.push<Currency>(
      '/currency-picker',
      extra: _convertCubit.fromCurrency,
    );
    if (result != null && mounted) {
      unawaited(_convertCubit.setFromCurrency(result));
    }
  }

  Future<void> _openToCurrencyPicker() async {
    final result = await context.push<Currency>(
      '/currency-picker',
      extra: _convertCubit.toCurrency,
    );
    if (result != null && mounted) {
      unawaited(_convertCubit.setToCurrency(result));
    }
  }

  void _openExchangeHistory(ConvertUiState uiState) {
    unawaited(
      context.push(
        '/exchange-history',
        extra: ExchangeHistoryArgs(
          fromCurrency: uiState.fromCurrency,
          toCurrency: uiState.toCurrency,
          fromCurrencyName: uiState.fromCurrencyName,
          toCurrencyName: uiState.toCurrencyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _convertCubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: BlocBuilder<ConvertCubit, ConvertState>(
            builder: (context, state) {
              final uiState = state.uiState;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    _buildHeader(),
                    SizedBox(height: 3.h),
                    _buildExchangeRateCard(state, uiState),
                    SizedBox(height: 3.h),
                    _buildConverterSection(state, uiState),
                    SizedBox(height: 2.h),
                    _buildExchangeRateInfo(state),
                    SizedBox(height: 3.h),
                    QuickSelectChips(
                      options: _buildQuickSelectOptions(uiState),
                      onOptionSelected: _onQuickSelectTapped,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              );
            },
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
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: () {
              // TODO(developer): Navigate to settings.
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeRateCard(ConvertState state, ConvertUiState uiState) {
    var rate = 0.0;

    if (state is ConvertSuccess) {
      rate = state.rate;
    }

    return ExchangeRateCard(
      fromCurrency: uiState.fromCurrency,
      toCurrency: uiState.toCurrency,
      rate: rate,
      onTap: () => _openExchangeHistory(uiState),
    );
  }

  Widget _buildConverterSection(ConvertState state, ConvertUiState uiState) {
    var convertedAmount = '0.00';
    var isLoading = false;
    String? errorMessage;

    if (state is ConvertSuccess) {
      convertedAmount = state.convertedAmount.toStringAsFixed(2);
    } else if (state is ConvertLoading) {
      isLoading = true;
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
              currencyCode: uiState.fromCurrency,
              currencyName: uiState.fromCurrencyName,
              flagUrl: uiState.fromFlagUrl,
              isEditable: true,
              onAmountChanged: _onAmountChanged,
              onCurrencyTap: _openFromCurrencyPicker,
            ),
            SizedBox(height: 2.h),
            // YOU GET Card with loading/error states
            _buildYouGetCard(
              uiState: uiState,
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
  }

  Widget _buildYouGetCard({
    required ConvertUiState uiState,
    required String convertedAmount,
    required bool isLoading,
    String? errorMessage,
  }) {
    return Stack(
      children: [
        CurrencyInputCard(
          label: 'YOU GET',
          amount: isLoading ? '...' : convertedAmount,
          currencyCode: uiState.toCurrency,
          currencyName: uiState.toCurrencyName,
          flagUrl: uiState.toFlagUrl,
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
              child: const Center(
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

  Widget _buildExchangeRateInfo(ConvertState state) {
    var timeText = 'Calculating...';

    if (state is ConvertSuccess) {
      timeText = state.formattedTimestamp;
    } else if (state is ConvertError) {
      timeText = '!';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
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
  }
}
