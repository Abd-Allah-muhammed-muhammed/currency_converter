import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/core/network/errors/api_error_model.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/ResponseCode.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';
import 'package:injectable/injectable.dart';

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
@lazySingleton
class ConvertCurrency
    implements UseCase<ConversionResult, ConvertCurrencyParams> {
  const ConvertCurrency(this._repository);

  final ConversionRepository _repository;

  /// Executes the use case.
  ///
  /// Returns [ApiResult] containing [ConversionResult] on success,
  /// or an error on failure.
  @override
  Future<ApiResult<ConversionResult>> call(ConvertCurrencyParams params) async {
    // Validate input
    if (params.amount <= 0) {
      return ApiResult.failure(
        ErrorHandler.fromMessage(
          const ApiErrorModel(
            code: ResponseCode.badRequest,
            message: 'Amount must be greater than zero',
          ),
        ),
      );
    }

    if (params.from.isEmpty || params.to.isEmpty) {
      return ApiResult.failure(
        ErrorHandler.fromMessage(
          const ApiErrorModel(
            code: ResponseCode.badRequest,
            message: 'Currency codes cannot be empty',
          ),
        ),
      );
    }

    if (params.from == params.to) {
      // Return identity conversion without API call
      final now = DateTime.now().toUtc();
      return ApiResult.success(
        ConversionResult(
          fromCurrency: params.from,
          toCurrency: params.to,
          amount: params.amount,
          quote: 1,
          result: params.amount,
          timestamp: now,
        ),
      );
    }

    return _repository.convert(
      from: params.from,
      to: params.to,
      amount: params.amount,
    );
  }
}
