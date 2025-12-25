import 'package:flutter/foundation.dart';

/// Model representing the API response for exchange rate history.
///
/// Example API response:
/// ```json
/// {
///   "success": true,
///   "timeframe": true,
///   "start_date": "2025-12-19",
///   "end_date": "2025-12-25",
///   "source": "USD",
///   "quotes": {
///     "2025-12-19": { "USDEUR": 0.738541 },
///     "2025-12-20": { "USDEUR": 0.736145 }
///   }
/// }
/// ```
@immutable
class ExchangeHistoryModel {
  const ExchangeHistoryModel({
    required this.success,
    required this.timeframe,
    required this.startDate,
    required this.endDate,
    required this.source,
    required this.quotes,
  });

  /// Whether the API request was successful.
  final bool success;

  /// Whether the response contains timeframe data.
  final bool timeframe;

  /// The start date of the requested period.
  final String startDate;

  /// The end date of the requested period.
  final String endDate;

  /// The source (base) currency code.
  final String source;

  /// Map of date -> currency pair -> rate.
  ///
  /// Example: {"2025-12-19": {"USDEUR": 0.738541}}
  final Map<String, Map<String, double>> quotes;

  /// Creates an [ExchangeHistoryModel] from JSON.
  factory ExchangeHistoryModel.fromJson(Map<String, dynamic> json) {
    final quotesJson = json['quotes'] as Map<String, dynamic>? ?? {};
    final quotes = <String, Map<String, double>>{};

    for (final dateEntry in quotesJson.entries) {
      final dateKey = dateEntry.key;
      final ratesJson = dateEntry.value as Map<String, dynamic>? ?? {};
      final rates = <String, double>{};

      for (final rateEntry in ratesJson.entries) {
        rates[rateEntry.key] = (rateEntry.value as num).toDouble();
      }

      quotes[dateKey] = rates;
    }

    return ExchangeHistoryModel(
      success: json['success'] as bool? ?? false,
      timeframe: json['timeframe'] as bool? ?? false,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      source: json['source'] as String? ?? '',
      quotes: quotes,
    );
  }

  /// Gets the rate for a specific date and currency pair.
  ///
  /// [date] - The date in YYYY-MM-DD format.
  /// [targetCurrency] - The target currency code.
  ///
  /// Returns null if the rate is not found.
  double? getRateForDate(String date, String targetCurrency) {
    final dateQuotes = quotes[date];
    if (dateQuotes == null) return null;

    // The key format is SOURCE + TARGET, e.g., "USDEUR"
    final pairKey = '$source$targetCurrency';
    return dateQuotes[pairKey];
  }

  /// Gets all rates for a specific currency pair as a sorted list.
  ///
  /// Returns a list of [ExchangeRatePoint] sorted by date.
  List<ExchangeRatePoint> getRatesForCurrency(String targetCurrency) {
    final rates = <ExchangeRatePoint>[];
    final pairKey = '$source$targetCurrency';

    for (final entry in quotes.entries) {
      final dateStr = entry.key;
      final rate = entry.value[pairKey];

      if (rate != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          rates.add(ExchangeRatePoint(date: date, rate: rate));
        }
      }
    }

    // Sort by date ascending
    rates.sort((a, b) => a.date.compareTo(b.date));

    return rates;
  }

  @override
  String toString() =>
      'ExchangeHistoryModel('
      'success: $success, '
      'timeframe: $timeframe, '
      'startDate: $startDate, '
      'endDate: $endDate, '
      'source: $source, '
      'quotes: ${quotes.length} entries)';
}

/// Represents a single exchange rate data point.
@immutable
class ExchangeRatePoint {
  const ExchangeRatePoint({required this.date, required this.rate});

  /// The date of this rate.
  final DateTime date;

  /// The exchange rate value.
  final double rate;

  @override
  String toString() => 'ExchangeRatePoint(date: $date, rate: $rate)';
}
