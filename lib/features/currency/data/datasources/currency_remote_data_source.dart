import 'dart:developer' as developer;
import 'package:currency_converter/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:currency_converter/core/network/api_constants.dart';
import 'package:currency_converter/features/currency/data/models/currency_model.dart';
import 'package:injectable/injectable.dart';

/// Remote data source for currency operations.
///
/// This class handles all API calls for currencies.
abstract class CurrencyRemoteDataSource {
  /// Fetches all supported currencies from the API.
  ///
  /// Throws a [DioException] if the request fails.
  Future<List<CurrencyModel>> getCurrencies();
}

/// Implementation of [CurrencyRemoteDataSource] using Dio.
@LazySingleton(as: CurrencyRemoteDataSource)
class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  CurrencyRemoteDataSourceImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await _apiService.getCurrencies();

      if (response.response.statusCode == 200) {
        final data = response.data;



        // Check if the API response is successful
        if (data['success'] == true && data['currencies'] != null) {
          final currenciesMap = data['currencies'] as Map<String, dynamic>;

          final currencies = currenciesMap.entries.map((entry) {
            return CurrencyModel.fromApiJson(
              entry.key,
              entry.value as String,
            );
          }).toList();

          // Sort currencies by name
          currencies.sort((a, b) => a.name.compareTo(b.name));

          developer.log(
            'Fetched ${currencies.length} currencies from API',
            name: 'CurrencyRemoteDataSource',
          );

          return currencies;
        } else {
          throw DioException(
            requestOptions: response.response.requestOptions,
            message: 'API returned unsuccessful response',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.response.requestOptions,
          message: 'Failed to fetch currencies: ${response.response.statusCode}'
        );
      }
    } on DioException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching currencies: $e',
        name: 'CurrencyRemoteDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.currenciesList),
        message: 'Unexpected error: $e',
      );
    }
  }
}
