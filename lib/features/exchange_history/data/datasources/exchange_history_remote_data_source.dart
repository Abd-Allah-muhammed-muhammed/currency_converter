import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:currency_converter/core/network/api_constants.dart';
import 'package:currency_converter/core/network/api_service.dart';
import 'package:currency_converter/features/exchange_history/data/models/exchange_history_model.dart';
import 'package:dio/dio.dart';

/// Remote data source for exchange history operations.
///
/// This class handles all API calls for exchange rate history.
abstract class ExchangeHistoryRemoteDataSource {
  /// Gets historical exchange rates for a time period.
  ///
  /// [source] - Source currency code (e.g., 'USD')
  /// [target] - Target currency code (e.g., 'EUR')
  /// [startDate] - Start date in YYYY-MM-DD format
  /// [endDate] - End date in YYYY-MM-DD format
  ///
  /// Throws a [DioException] if the request fails.
  Future<ExchangeHistoryModel> getExchangeHistory({
    required String source,
    required String target,
    required String startDate,
    required String endDate,
  });
}

/// Implementation of [ExchangeHistoryRemoteDataSource] using the API service.
@LazySingleton(as: ExchangeHistoryRemoteDataSource)
class ExchangeHistoryRemoteDataSourceImpl
    implements ExchangeHistoryRemoteDataSource {
  ExchangeHistoryRemoteDataSourceImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<ExchangeHistoryModel> getExchangeHistory({
    required String source,
    required String target,
    required String startDate,
    required String endDate,
  }) async {
    try {
      developer.log(
        'Fetching exchange history: $source -> $target, '
        'from $startDate to $endDate',
        name: 'ExchangeHistoryRemoteDataSource',
      );

      final response = await _apiService.getTimeframe(
        ApiConstants.apiKey,
        source,
        target,
        startDate,
        endDate,
      );

      if (response.response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        developer.log(
          'API Response: $data',
          name: 'ExchangeHistoryRemoteDataSource',
        );

        // Check if the API response is successful
        if (data['success'] == true) {
          final result = ExchangeHistoryModel.fromJson(data);

          developer.log(
            'Exchange history result: $result',
            name: 'ExchangeHistoryRemoteDataSource',
          );

          return result;
        } else {
          final errorInfo = data['error'] as Map<String, dynamic>?;
          final errorMessage =
              errorInfo?['info'] as String? ??
              'API returned unsuccessful response';

          throw DioException(
            requestOptions: response.response.requestOptions,
            response: response.response,
            message: errorMessage,
            type: DioExceptionType.badResponse,
          );
        }
      } else {
        throw DioException(
          requestOptions: response.response.requestOptions,
          response: response.response,
          message:
              'Failed to fetch exchange history: ${response.response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching exchange history: $e',
        name: 'ExchangeHistoryRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.timeframe),
        message: 'Unexpected error: $e',
        type: DioExceptionType.unknown,
        error: e,
      );
    }
  }
}
