import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';

/// Use case for getting all currencies.
///
/// This use case fetches currencies following the offline-first approach:
/// - Returns cached currencies if available.
/// - Fetches from API and caches if not available locally.
class GetCurrencies implements UseCase<List<Currency>, NoParams> {
  GetCurrencies(this.repository);

  final CurrencyRepository repository;

  @override
  Future<ApiResult<List<Currency>>> call(NoParams params) {
    return repository.getCurrencies();
  }
}
