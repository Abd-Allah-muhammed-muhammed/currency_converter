import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';

/// Repository interface for exchange history operations.
///
/// This defines the contract that the data layer must implement.
// ignore: one_member_abstracts
abstract class ExchangeHistoryRepository {
  /// Gets historical exchange rates for a time period.
  ///
  /// [sourceCurrency] - Source currency code (e.g., 'USD')
  /// [targetCurrency] - Target currency code (e.g., 'EUR')
  /// [startDate] - Start date of the period
  /// [endDate] - End date of the period
  ///
  /// Returns [ApiResult] containing [ExchangeHistory] on success,
  /// or an error on failure.
  Future<ApiResult<ExchangeHistory>> getExchangeHistory({
    required String sourceCurrency,
    required String targetCurrency,
    required DateTime startDate,
    required DateTime endDate,
  });
}
