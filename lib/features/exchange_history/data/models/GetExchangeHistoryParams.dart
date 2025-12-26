

import 'package:flutter/cupertino.dart';

/// Parameters for [GetExchangeHistory] use case.
@immutable
class GetExchangeHistoryParams {
  const GetExchangeHistoryParams({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.startDate,
    required this.endDate,
  });

  /// Creates params for the last N days.
  factory GetExchangeHistoryParams.forDays({
    required String sourceCurrency,
    required String targetCurrency,
    required int days,
  }) {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(Duration(days: days));

    return GetExchangeHistoryParams(
      sourceCurrency: sourceCurrency,
      targetCurrency: targetCurrency,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// The source currency code (e.g., 'USD').
  final String sourceCurrency;

  /// The target currency code (e.g., 'EUR').
  final String targetCurrency;

  /// The start date of the period.
  final DateTime startDate;

  /// The end date of the period.
  final DateTime endDate;

  @override
  String toString() =>
      'GetExchangeHistoryParams('
          'source: $sourceCurrency, '
          'target: $targetCurrency, '
          'start: $startDate, '
          'end: $endDate)';
}
