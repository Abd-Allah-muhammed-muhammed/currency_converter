import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';

/// Repository interface for currency conversion operations.
///
/// This abstraction allows the domain layer to be independent
/// of the data layer implementation.
abstract class ConversionRepository {
  /// Converts an amount from one currency to another.
  ///
  /// [from] - Source currency code (e.g., 'CAD')
  /// [to] - Target currency code (e.g., 'EUR')
  /// [amount] - Amount to convert
  ///
  /// Returns [ApiResult] containing [ConversionResult] on success,
  /// or an error on failure.
  Future<ApiResult<ConversionResult>> convert({
    required String from,
    required String to,
    required double amount,
  });
}
