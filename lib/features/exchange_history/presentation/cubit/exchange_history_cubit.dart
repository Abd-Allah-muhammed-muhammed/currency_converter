import 'dart:developer' as developer;

import 'package:currency_converter/features/exchange_history/data/models/GetExchangeHistoryParams.dart';
import 'package:currency_converter/features/exchange_history/domain/usecases/get_exchange_history.dart';
import 'package:currency_converter/features/exchange_history/presentation/cubit/exchange_history_state.dart';
import 'package:currency_converter/features/exchange_history/presentation/widgets/time_period_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit for managing exchange history state.
///
/// Handles:
/// - Loading exchange history for a currency pair
/// - Changing time periods (1W, 1M, 3M, 1Y)
/// - Swapping currencies
@injectable
class ExchangeHistoryCubit extends Cubit<ExchangeHistoryState> {
  ExchangeHistoryCubit({required GetExchangeHistory getExchangeHistory})
    : _getExchangeHistory = getExchangeHistory,
      super(const ExchangeHistoryInitial());

  final GetExchangeHistory _getExchangeHistory;

  /// Currently loaded currencies.
  String _sourceCurrency = 'USD';
  String _targetCurrency = 'EUR';
  String _sourceCurrencyName = 'US Dollar';
  String _targetCurrencyName = 'Euro';
  int _currentPeriodDays = 7;
  TimePeriod _selectedPeriod = TimePeriod.oneWeek;

  /// Gets the current source currency.
  String get sourceCurrency => _sourceCurrency;

  /// Gets the current target currency.
  String get targetCurrency => _targetCurrency;

  /// Gets the current source currency name.
  String get sourceCurrencyName => _sourceCurrencyName;

  /// Gets the current target currency name.
  String get targetCurrencyName => _targetCurrencyName;

  /// Gets the current period in days.
  int get currentPeriodDays => _currentPeriodDays;

  /// Gets the currently selected time period.
  TimePeriod get selectedPeriod => _selectedPeriod;

  /// Loads exchange history for the current currencies.
  ///
  /// [sourceCurrency] - The source currency code.
  /// [targetCurrency] - The target currency code.
  /// [sourceCurrencyName] - The source currency name.
  /// [targetCurrencyName] - The target currency name.
  /// [days] - The number of days to load (default: 7).
  Future<void> loadHistory({
    required String sourceCurrency,
    required String targetCurrency,
    required String sourceCurrencyName,
    required String targetCurrencyName,
    int days = 7,
  }) async {
    developer.log(
      'Loading exchange history: '
      '$sourceCurrency -> $targetCurrency, $days days',
      name: 'ExchangeHistoryCubit',
    );

    _sourceCurrency = sourceCurrency;
    _targetCurrency = targetCurrency;
    _sourceCurrencyName = sourceCurrencyName;
    _targetCurrencyName = targetCurrencyName;
    _currentPeriodDays = days;

    emit(
      ExchangeHistoryLoading(
        sourceCurrency: sourceCurrency,
        targetCurrency: targetCurrency,
      ),
    );

    final params = GetExchangeHistoryParams.forDays(
      sourceCurrency: sourceCurrency,
      targetCurrency: targetCurrency,
      days: days,
    );

    final result = await _getExchangeHistory(params);

    result.when(
      success: (history) {
        developer.log(
          'Exchange history loaded successfully: '
          '${history.rates.length} points',
          name: 'ExchangeHistoryCubit',
        );

        // Handle empty data
        if (history.rates.isEmpty) {
          emit(
            ExchangeHistoryError(
              message: 'No exchange rate data available for this period',
              sourceCurrency: sourceCurrency,
              targetCurrency: targetCurrency,
            ),
          );
          return;
        }

        emit(
          ExchangeHistoryLoaded(
            history: history,
            sourceCurrency: sourceCurrency,
            targetCurrency: targetCurrency,
            sourceCurrencyName: sourceCurrencyName,
            targetCurrencyName: targetCurrencyName,
            currentRate: history.latestRate ?? 0.0,
            changePercentage: history.changePercentage?.abs() ?? 0.0,
            isPositiveChange: history.isPositiveChange,
            highRate: history.highRate ?? 0.0,
            lowRate: history.lowRate ?? 0.0,
            averageRate: history.averageRate ?? 0.0,
            chartData: history.rates,
            periodDays: days,
            selectedPeriod: _selectedPeriod,
          ),
        );
      },
      failure: (error) {
        developer.log(
          'Error loading exchange history: ${error.failure.message}',
          name: 'ExchangeHistoryCubit',
          level: 1000,
        );

        emit(
          ExchangeHistoryError(
            message: error.failure.message ?? 'An unexpected error occurred',
            sourceCurrency: sourceCurrency,
            targetCurrency: targetCurrency,
          ),
        );
      },
    );
  }

  /// Changes the time period and reloads data.
  ///
  /// [period] - The new time period.
  Future<void> changePeriod(TimePeriod period) async {
    final days = _getDaysForPeriod(period);
    developer.log(
      'Changing period to ${period.label} ($days days)',
      name: 'ExchangeHistoryCubit',
    );

    _selectedPeriod = period;
    _currentPeriodDays = days;

    await loadHistory(
      sourceCurrency: _sourceCurrency,
      targetCurrency: _targetCurrency,
      sourceCurrencyName: _sourceCurrencyName,
      targetCurrencyName: _targetCurrencyName,
      days: days,
    );
  }

  /// Gets the number of days for a time period.
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

  /// Swaps the source and target currencies.
  Future<void> swapCurrencies() async {
    developer.log(
      'Swapping currencies: $_sourceCurrency <-> $_targetCurrency',
      name: 'ExchangeHistoryCubit',
    );

    final tempCurrency = _sourceCurrency;
    final tempName = _sourceCurrencyName;

    await loadHistory(
      sourceCurrency: _targetCurrency,
      targetCurrency: tempCurrency,
      sourceCurrencyName: _targetCurrencyName,
      targetCurrencyName: tempName,
      days: _currentPeriodDays,
    );
  }

  /// Retries loading with current parameters.
  Future<void> retry() async {
    await loadHistory(
      sourceCurrency: _sourceCurrency,
      targetCurrency: _targetCurrency,
      sourceCurrencyName: _sourceCurrencyName,
      targetCurrencyName: _targetCurrencyName,
      days: _currentPeriodDays,
    );
  }
}
