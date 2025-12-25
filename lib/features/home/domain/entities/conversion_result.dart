import 'package:flutter/foundation.dart';

/// Entity representing a currency conversion result.
///
/// This is a pure domain object with no dependencies on external
/// frameworks or data sources.
@immutable
class ConversionResult {
  /// Creates a new [ConversionResult] instance.
  const ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.quote,
    required this.result,
    required this.timestamp,
  });

  /// The source currency code (e.g., 'CAD').
  final String fromCurrency;

  /// The target currency code (e.g., 'EUR').
  final String toCurrency;

  /// The amount that was converted.
  final double amount;

  /// The exchange rate (1 FROM = quote TO).
  final double quote;

  /// The converted result (amount * quote).
  final double result;

  /// The timestamp when the rate was calculated.
  final DateTime timestamp;

  /// Returns the formatted exchange rate string.
  /// Example: "1 CAD ≈ 0.620998 EUR"
  String get formattedRate =>
      '1 $fromCurrency ≈ ${quote.toStringAsFixed(6)} $toCurrency';

  /// Returns the formatted result string.
  /// Example: "620.998 EUR"
  String get formattedResult => '${result.toStringAsFixed(2)} $toCurrency';

  /// Returns the formatted amount string.
  /// Example: "1000 CAD"
  String get formattedAmount => '${amount.toStringAsFixed(2)} $fromCurrency';

  /// Returns the formatted timestamp in UTC.
  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')} UTC';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionResult &&
          runtimeType == other.runtimeType &&
          fromCurrency == other.fromCurrency &&
          toCurrency == other.toCurrency &&
          amount == other.amount &&
          quote == other.quote &&
          result == other.result &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      fromCurrency.hashCode ^
      toCurrency.hashCode ^
      amount.hashCode ^
      quote.hashCode ^
      result.hashCode ^
      timestamp.hashCode;

  @override
  String toString() {
    return 'ConversionResult('
        'from: $fromCurrency, '
        'to: $toCurrency, '
        'amount: $amount, '
        'quote: $quote, '
        'result: $result, '
        'timestamp: $timestamp)';
  }
}
