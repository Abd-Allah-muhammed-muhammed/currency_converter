import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';

/// Abstract repository for currency operations.
///
/// This defines the contract for currency data operations
/// that must be implemented by the data layer.
abstract class CurrencyRepository {
  /// Gets all available currencies.
  ///
  /// This follows an offline-first approach:
  /// 1. First, check if currencies exist in local database.
  /// 2. If yes, return from local database.
  /// 3. If no, fetch from remote API, save to database, then return.
  ///
  /// Returns [ApiResult] with [List] of [Currency] on success.
  Future<ApiResult<List<Currency>>> getCurrencies();

  /// Gets a single currency by its code.
  ///
  /// Returns the [Currency] if found, null otherwise.
  Future<Currency?> getCurrencyByCode(String code);

  /// Checks if currencies are available locally.
  Future<bool> hasCachedCurrencies();

  /// Forces a refresh of currencies from the remote API.
  ///
  /// This will fetch fresh data from the API and update the local database.
  Future<ApiResult<List<Currency>>> refreshCurrencies();
}
