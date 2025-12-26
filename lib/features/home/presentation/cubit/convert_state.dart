import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:flutter/foundation.dart';

/// UI state that persists across all conversion states.
@immutable
class ConvertUiState {
  const ConvertUiState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'EUR',
    this.fromCurrencyName = 'United States Dollar',
    this.toCurrencyName = 'Euro',
    this.amount = 1.0,
    this.selectedQuickAmount,
  });

  /// The source currency code.
  final String fromCurrency;

  /// The target currency code.
  final String toCurrency;

  /// The source currency name.
  final String fromCurrencyName;

  /// The target currency name.
  final String toCurrencyName;

  /// The amount being converted.
  final double amount;

  /// The selected quick amount (100, 500, 1000, 5000).
  final int? selectedQuickAmount;

  /// Creates a copy with updated values.
  ConvertUiState copyWith({
    String? fromCurrency,
    String? toCurrency,
    String? fromCurrencyName,
    String? toCurrencyName,
    double? amount,
    int? selectedQuickAmount,
    bool clearQuickAmount = false,
  }) {
    return ConvertUiState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      fromCurrencyName: fromCurrencyName ?? this.fromCurrencyName,
      toCurrencyName: toCurrencyName ?? this.toCurrencyName,
      amount: amount ?? this.amount,
      selectedQuickAmount: clearQuickAmount
          ? null
          : (selectedQuickAmount ?? this.selectedQuickAmount),
    );
  }

  /// Gets the flag URL for a currency code.
  String? getFlagUrl(String currencyCode) {


    if (currencyCode.length >= 2) {
      return 'https://flagcdn.com/w40/${currencyCode.substring(0, 2).toLowerCase()}.png';
    }
    return null;
  }

  /// Gets the from currency flag URL.
  String? get fromFlagUrl => getFlagUrl(fromCurrency);

  /// Gets the to currency flag URL.
  String? get toFlagUrl => getFlagUrl(toCurrency);
}

/// Base state for conversion.
@immutable
sealed class ConvertState {
  const ConvertState({required this.uiState});

  /// The UI state that persists across all states.
  final ConvertUiState uiState;
}

/// Initial state before any conversion.
class ConvertInitial extends ConvertState {
  const ConvertInitial({required super.uiState});
}

/// Loading state while conversion is in progress.
class ConvertLoading extends ConvertState {
  const ConvertLoading({required super.uiState});
}

/// Success state with conversion result.
class ConvertSuccess extends ConvertState {
  const ConvertSuccess({required super.uiState, required this.result});

  /// The conversion result from the API.
  final ConversionResult result;

  /// The exchange rate (1 FROM = quote TO).
  double get rate => result.quote;

  /// The converted amount.
  double get convertedAmount => result.result;

  /// The timestamp of the rate.
  DateTime get timestamp => result.timestamp;

  /// Formatted timestamp in UTC.
  String get formattedTimestamp => result.formattedTimestamp;
}

/// Error state when conversion fails.
class ConvertError extends ConvertState {
  const ConvertError({required super.uiState, required this.message});

  /// The error message.
  final String message;
}
