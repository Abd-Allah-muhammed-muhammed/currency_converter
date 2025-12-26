import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/exchange_history/data/models/GetExchangeHistoryParams.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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

