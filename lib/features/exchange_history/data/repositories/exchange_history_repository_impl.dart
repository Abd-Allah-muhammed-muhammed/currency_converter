import 'dart:developer' as developer;

import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/features/exchange_history/data/datasources/exchange_history_remote_data_source.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Implementation of [ExchangeHistoryRepository].
///
/// This class fetches exchange rate history from the remote data source.
@LazySingleton(as: ExchangeHistoryRepository)
class ExchangeHistoryRepositoryImpl implements ExchangeHistoryRepository {
  ExchangeHistoryRepositoryImpl({required this.remoteDataSource});

  final ExchangeHistoryRemoteDataSource remoteDataSource;

  /// Date formatter for API requests.
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApiResult<ExchangeHistory>> getExchangeHistory({
    required String sourceCurrency,
    required String targetCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      developer.log(
        'Getting exchange history: $sourceCurrency -> $targetCurrency, '
        'from $startDate to $endDate',
        name: 'ExchangeHistoryRepository',
      );

      final model = await remoteDataSource.getExchangeHistory(
        source: sourceCurrency,
        target: targetCurrency,
        startDate: _dateFormat.format(startDate),
        endDate: _dateFormat.format(endDate),
      );

      // Convert model to entity
      final ratePoints = model.getRatesForCurrency(targetCurrency);
      final rates = ratePoints
          .map((p) => RateDataPoint(date: p.date, rate: p.rate))
          .toList();

      final entity = ExchangeHistory(
        sourceCurrency: sourceCurrency,
        targetCurrency: targetCurrency,
        rates: rates,
        startDate: startDate,
        endDate: endDate,
      );

      developer.log(
        'Exchange history loaded: ${entity.rates.length} data points',
        name: 'ExchangeHistoryRepository',
      );

      return ApiResult.success(entity);
    } on Object catch (e, stackTrace) {
      developer.log(
        'Error getting exchange history: $e',
        name: 'ExchangeHistoryRepository',
        error: e,
        stackTrace: stackTrace,
      );

      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
