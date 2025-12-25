import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:flutter/foundation.dart';

/// Base class for all exchange history states.
@immutable
abstract class ExchangeHistoryState {
  const ExchangeHistoryState();
}

/// Initial state before any data is loaded.
class ExchangeHistoryInitial extends ExchangeHistoryState {
  const ExchangeHistoryInitial();
}

/// State when data is being loaded.
class ExchangeHistoryLoading extends ExchangeHistoryState {
  const ExchangeHistoryLoading({this.sourceCurrency, this.targetCurrency});

  /// The source currency being loaded.
  final String? sourceCurrency;

  /// The target currency being loaded.
  final String? targetCurrency;
}

/// State when data is successfully loaded.
class ExchangeHistoryLoaded extends ExchangeHistoryState {
  const ExchangeHistoryLoaded({
    required this.history,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sourceCurrencyName,
    required this.targetCurrencyName,
    required this.currentRate,
    required this.changePercentage,
    required this.isPositiveChange,
    required this.highRate,
    required this.lowRate,
    required this.averageRate,
    required this.chartData,
    required this.periodDays,
  });

  /// The exchange history data.
  final ExchangeHistory history;

  /// The source currency code.
  final String sourceCurrency;

  /// The target currency code.
  final String targetCurrency;

  /// The source currency name.
  final String sourceCurrencyName;

  /// The target currency name.
  final String targetCurrencyName;

  /// The current (latest) exchange rate.
  final double currentRate;

  /// The percentage change from start to end.
  final double changePercentage;

  /// Whether the change is positive (rate increased).
  final bool isPositiveChange;

  /// The highest rate in the period.
  final double highRate;

  /// The lowest rate in the period.
  final double lowRate;

  /// The average rate in the period.
  final double averageRate;

  /// Chart data points.
  final List<RateDataPoint> chartData;

  /// The number of days in the current period.
  final int periodDays;

  /// Creates a copy with updated values.
  ExchangeHistoryLoaded copyWith({
    ExchangeHistory? history,
    String? sourceCurrency,
    String? targetCurrency,
    String? sourceCurrencyName,
    String? targetCurrencyName,
    double? currentRate,
    double? changePercentage,
    bool? isPositiveChange,
    double? highRate,
    double? lowRate,
    double? averageRate,
    List<RateDataPoint>? chartData,
    int? periodDays,
  }) {
    return ExchangeHistoryLoaded(
      history: history ?? this.history,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      sourceCurrencyName: sourceCurrencyName ?? this.sourceCurrencyName,
      targetCurrencyName: targetCurrencyName ?? this.targetCurrencyName,
      currentRate: currentRate ?? this.currentRate,
      changePercentage: changePercentage ?? this.changePercentage,
      isPositiveChange: isPositiveChange ?? this.isPositiveChange,
      highRate: highRate ?? this.highRate,
      lowRate: lowRate ?? this.lowRate,
      averageRate: averageRate ?? this.averageRate,
      chartData: chartData ?? this.chartData,
      periodDays: periodDays ?? this.periodDays,
    );
  }
}

/// State when an error occurred.
class ExchangeHistoryError extends ExchangeHistoryState {
  const ExchangeHistoryError({
    required this.message,
    this.sourceCurrency,
    this.targetCurrency,
  });

  /// The error message.
  final String message;

  /// The source currency when the error occurred.
  final String? sourceCurrency;

  /// The target currency when the error occurred.
  final String? targetCurrency;
}
