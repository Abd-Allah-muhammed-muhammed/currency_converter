import 'package:flutter/foundation.dart';

/// Entity representing exchange rate history data in the domain layer.
///
/// This is a pure domain object with no dependencies on external
/// frameworks or data sources.
@immutable
class ExchangeHistory {
  /// Creates a new [ExchangeHistory] instance.
  const ExchangeHistory({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.rates,
    required this.startDate,
    required this.endDate,
  });

  /// The source (base) currency code (e.g., 'USD').
  final String sourceCurrency;

  /// The target currency code (e.g., 'EUR').
  final String targetCurrency;

  /// List of rate data points sorted by date.
  final List<RateDataPoint> rates;

  /// The start date of the period.
  final DateTime startDate;

  /// The end date of the period.
  final DateTime endDate;

  /// Gets the latest (most recent) rate.
  double? get latestRate {
    if (rates.isEmpty) return null;
    return rates.last.rate;
  }

  /// Gets the earliest rate in the period.
  double? get firstRate {
    if (rates.isEmpty) return null;
    return rates.first.rate;
  }

  /// Gets the highest rate in the period.
  double? get highRate {
    if (rates.isEmpty) return null;
    return rates.map((r) => r.rate).reduce((a, b) => a > b ? a : b);
  }

  /// Gets the lowest rate in the period.
  double? get lowRate {
    if (rates.isEmpty) return null;
    return rates.map((r) => r.rate).reduce((a, b) => a < b ? a : b);
  }

  /// Gets the average rate in the period.
  double? get averageRate {
    if (rates.isEmpty) return null;
    final sum = rates.map((r) => r.rate).reduce((a, b) => a + b);
    return sum / rates.length;
  }

  /// Calculates the percentage change from start to end.
  ///
  /// Returns positive if rate increased, negative if decreased.
  double? get changePercentage {
    final first = firstRate;
    final latest = latestRate;
    if (first == null || latest == null || first == 0) return null;
    return ((latest - first) / first) * 100;
  }

  /// Whether the rate has increased over the period.
  bool get isPositiveChange {
    final change = changePercentage;
    return change != null && change >= 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeHistory &&
          runtimeType == other.runtimeType &&
          sourceCurrency == other.sourceCurrency &&
          targetCurrency == other.targetCurrency &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      sourceCurrency.hashCode ^
      targetCurrency.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;

  @override
  String toString() =>
      'ExchangeHistory('
      'source: $sourceCurrency, '
      'target: $targetCurrency, '
      'rates: ${rates.length} points, '
      'start: $startDate, '
      'end: $endDate)';
}

/// Represents a single rate data point.
@immutable
class RateDataPoint {
  const RateDataPoint({required this.date, required this.rate});

  /// The date of this data point.
  final DateTime date;

  /// The exchange rate value.
  final double rate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateDataPoint &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          rate == other.rate;

  @override
  int get hashCode => date.hashCode ^ rate.hashCode;

  @override
  String toString() => 'RateDataPoint(date: $date, rate: $rate)';
}
