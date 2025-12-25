import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:flutter/foundation.dart';

/// Base state for conversion.
@immutable
sealed class ConvertState {
  const ConvertState();
}

/// Initial state before any conversion.
class ConvertInitial extends ConvertState {
  const ConvertInitial();
}

/// Loading state while conversion is in progress.
class ConvertLoading extends ConvertState {
  const ConvertLoading({this.fromCurrency, this.toCurrency, this.amount});

  /// The source currency code.
  final String? fromCurrency;

  /// The target currency code.
  final String? toCurrency;

  /// The amount being converted.
  final double? amount;
}

/// Success state with conversion result.
class ConvertSuccess extends ConvertState {
  const ConvertSuccess({required this.result});

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
  const ConvertError({
    required this.message,
    this.fromCurrency,
    this.toCurrency,
    this.amount,
  });

  /// The error message.
  final String message;

  /// The source currency code when error occurred.
  final String? fromCurrency;

  /// The target currency code when error occurred.
  final String? toCurrency;

  /// The amount when error occurred.
  final double? amount;
}
