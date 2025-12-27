import 'dart:developer' as developer;

import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/core/utils/retry_policy.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Implementation of [CurrencyRepository].
///
/// This repository follows an offline-first approach:
/// 1. Check if currencies exist in local database.
/// 2. If yes, return from local database.
/// 3. If no, fetch from remote API, save to database, then return.
@LazySingleton(as: CurrencyRepository)
class CurrencyRepositoryImpl implements CurrencyRepository {
  CurrencyRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final CurrencyLocalDataSource localDataSource;
  final CurrencyRemoteDataSource remoteDataSource;

  @override
  Future<ApiResult<List<Currency>>> getCurrencies() async {
    try {
      // Check if we have cached currencies
      final hasCached = await localDataSource.hasCurrencies();

      if (hasCached) {
        developer.log(
          'Loading currencies from local database',
          name: 'CurrencyRepository',
        );

        // Return from local database
        final localCurrencies = await localDataSource.getCurrencies();

        final entities = localCurrencies.map((m) => m.toEntity()).toList();

        return ApiResult.success(entities);
      } else {
        developer.log(
          'No cached currencies, fetching from API',
          name: 'CurrencyRepository',
        );

        // Fetch from remote and cache
        return await _fetchAndCacheCurrencies();
      }
    } on DioException catch (e) {
      developer.log(
        'DioException in getCurrencies: ${e.message}',
        name: 'CurrencyRepository',
        error: e,
      );
      return ApiResult.failure(ErrorHandler.handle(e));
    } on Object catch (e, stackTrace) {
      developer.log(
        'Unexpected error in getCurrencies: $e',
        name: 'CurrencyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Currency?> getCurrencyByCode(String code) async {
    try {
      final model = await localDataSource.getCurrencyByCode(code);
      return model?.toEntity();
    } on Object catch (e) {
      developer.log(
        'Error getting currency by code: $e',
        name: 'CurrencyRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> hasCachedCurrencies() async {
    try {
      return await localDataSource.hasCurrencies();
    } on Object {
      return false;
    }
  }

  @override
  Future<ApiResult<List<Currency>>> refreshCurrencies() async {
    try {
      developer.log(
        'Force refreshing currencies from API',
        name: 'CurrencyRepository',
      );

      // Clear existing cache
      await localDataSource.clearCurrencies();

      // Fetch fresh data
      return await _fetchAndCacheCurrencies();
    } on DioException catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    } on Object catch (e, stackTrace) {
      developer.log(
        'Error refreshing currencies: $e',
        name: 'CurrencyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  /// Fetches currencies from remote API and caches them locally.
  Future<ApiResult<List<Currency>>> _fetchAndCacheCurrencies() async {
    try {
      // Fetch from remote
      final remoteCurrencies = await retry(remoteDataSource.getCurrencies);

      developer.log(
        'Fetched ${remoteCurrencies.length} currencies from API',
        name: 'CurrencyRepository',
      );

      // Save to local database
      await localDataSource.saveCurrencies(remoteCurrencies);

      developer.log(
        'Saved ${remoteCurrencies.length} currencies to local database',
        name: 'CurrencyRepository',
      );

      // Convert to entities and return
      final entities = remoteCurrencies.map((m) => m.toEntity()).toList();
      return ApiResult.success(entities);
    } on DioException catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    } on Object catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
