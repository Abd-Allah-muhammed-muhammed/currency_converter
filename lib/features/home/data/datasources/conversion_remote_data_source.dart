import 'dart:developer' as developer;

import 'package:currency_converter/core/network/api_constants.dart';
import 'package:currency_converter/core/network/api_service.dart';
import 'package:currency_converter/features/home/data/models/conversion_result_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for currency conversion operations.
///
/// This class handles all API calls for currency conversion.
// ignore: one_member_abstracts
abstract class ConversionRemoteDataSource {
  /// Converts an amount from one currency to another.
  ///
  /// [from] - Source currency code (e.g., 'CAD')
  /// [to] - Target currency code (e.g., 'EUR')
  /// [amount] - Amount to convert
  ///
  /// Throws a [DioException] if the request fails.
  Future<ConversionResultModel> convert({
    required String from,
    required String to,
    required double amount,
  });
}

/// Implementation of [ConversionRemoteDataSource] using the API service.
@LazySingleton(as: ConversionRemoteDataSource)
class ConversionRemoteDataSourceImpl implements ConversionRemoteDataSource {
  ConversionRemoteDataSourceImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<ConversionResultModel> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      developer.log(
        'Converting $amount $from to $to',
        name: 'ConversionRemoteDataSource',
      );

      final response = await _apiService.convert(
        from,
        to,
        amount,
        ApiConstants.apiKey,
      );

      if (response.response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        developer.log(
          'API Response: $data',
          name: 'ConversionRemoteDataSource',
        );

        // Check if the API response is successful
        if (data['success'] == true) {
          final result = ConversionResultModel.fromJson(data);

          developer.log(
            'Conversion result: $result',
            name: 'ConversionRemoteDataSource',
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
              'Failed to convert currency: ${response.response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Error converting currency: $e',
        name: 'ConversionRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.convert),
        message: 'Unexpected error: $e',
      );
    }
  }
}
