import 'package:injectable/injectable.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:flutter/foundation.dart';

/// Use case for getting exchange rate history.
///
/// This use case fetches historical exchange rates for a currency pair
/// over a specified time period.
@lazySingleton
class GetExchangeHistory
    implements UseCase<ExchangeHistory, GetExchangeHistoryParams> {
  GetExchangeHistory(this.repository);

  final ExchangeHistoryRepository repository;

  @override
  Future<ApiResult<ExchangeHistory>> call(GetExchangeHistoryParams params) {
    return repository.getExchangeHistory(
      sourceCurrency: params.sourceCurrency,
      targetCurrency: params.targetCurrency,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Parameters for [GetExchangeHistory] use case.
@immutable
class GetExchangeHistoryParams {
  const GetExchangeHistoryParams({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.startDate,
    required this.endDate,
  });

  /// The source currency code (e.g., 'USD').
  final String sourceCurrency;

  /// The target currency code (e.g., 'EUR').
  final String targetCurrency;

  /// The start date of the period.
  final DateTime startDate;

  /// The end date of the period.
  final DateTime endDate;

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

  @override
  String toString() =>
      'GetExchangeHistoryParams('
      'source: $sourceCurrency, '
      'target: $targetCurrency, '
      'start: $startDate, '
      'end: $endDate)';
}
