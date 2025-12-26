import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';

/// Model for the convert API response.
///
/// Example response:
/// ```json
/// {
///   "success": true,
///   "query": {
///     "from": "CAD",
///     "to": "EUR",
///     "amount": 1000
///   },
///   "info": {
///     "timestamp": 1766664244,
///     "quote": 0.620998
///   },
///   "result": 620.998
/// }
/// ```
class ConversionResultModel {
  const ConversionResultModel({
    required this.success,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.quote,
    required this.result,
    required this.timestamp,
  });

  /// Creates a [ConversionResultModel] from API JSON response.
  factory ConversionResultModel.fromJson(Map<String, dynamic> json) {
    final query = json['query'] as Map<String, dynamic>;
    final info = json['info'] as Map<String, dynamic>;

    return ConversionResultModel(
      success: json['success'] as bool? ?? false,
      fromCurrency: query['from'] as String,
      toCurrency: query['to'] as String,
      amount: (query['amount'] as num).toDouble(),
      quote: (info['quote'] as num).toDouble(),
      result: (json['result'] as num).toDouble(),
      timestamp: info['timestamp'] as int,
    );
  }

  /// Whether the API request was successful.
  final bool success;

  /// The source currency code.
  final String fromCurrency;

  /// The target currency code.
  final String toCurrency;

  /// The amount to convert.
  final double amount;

  /// The exchange rate (1 FROM = quote TO).
  final double quote;

  /// The converted result (amount * quote).
  final double result;

  /// Unix timestamp when the rate was calculated.
  final int timestamp;

  /// Converts to domain entity.
  ConversionResult toEntity() {
    return ConversionResult(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      quote: quote,
      result: result,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  @override
  String toString() {
    return 'ConversionResultModel('
        'success: $success, '
        'from: $fromCurrency, '
        'to: $toCurrency, '
        'amount: $amount, '
        'quote: $quote, '
        'result: $result, '
        'timestamp: $timestamp)';
  }
}
