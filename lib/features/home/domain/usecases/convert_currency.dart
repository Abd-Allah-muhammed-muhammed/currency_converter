import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';

/// Parameters for the convert currency use case.
class ConvertCurrencyParams {
  const ConvertCurrencyParams({
    required this.from,
    required this.to,
    required this.amount,
  });

  /// Source currency code (e.g., 'CAD').
  final String from;

  /// Target currency code (e.g., 'EUR').
  final String to;

  /// Amount to convert.
  final double amount;
}

/// Use case for converting currency.
///
/// This use case encapsulates the business logic for currency conversion.
class ConvertCurrency {
  const ConvertCurrency(this._repository);

  final ConversionRepository _repository;

  /// Executes the use case.
  ///
  /// Returns a [ConversionResult] on success.
  /// Throws an exception on failure.
  Future<ConversionResult> call(ConvertCurrencyParams params) async {
    // Validate input
    if (params.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (params.from.isEmpty || params.to.isEmpty) {
      throw ArgumentError('Currency codes cannot be empty');
    }

    if (params.from == params.to) {
      // Return identity conversion without API call
      final now = DateTime.now().toUtc();
      return ConversionResult(
        fromCurrency: params.from,
        toCurrency: params.to,
        amount: params.amount,
        quote: 1.0,
        result: params.amount,
        timestamp: now,
      );
    }

    return _repository.convert(
      from: params.from,
      to: params.to,
      amount: params.amount,
    );
  }
}
