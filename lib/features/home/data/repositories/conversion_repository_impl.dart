import 'dart:developer' as developer;

import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/features/home/data/datasources/conversion_remote_data_source.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Implementation of [ConversionRepository].
///
/// This class coordinates between data sources and converts
/// data models to domain entities.
@LazySingleton(as: ConversionRepository)
class ConversionRepositoryImpl implements ConversionRepository {
  ConversionRepositoryImpl({
    required ConversionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ConversionRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<ConversionResult>> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      developer.log(
        'Converting $amount $from to $to',
        name: 'ConversionRepository',
      );

      final result = await _remoteDataSource.convert(
        from: from,
        to: to,
        amount: amount,
      );

      developer.log(
        'Conversion successful: ${result.result} $to',
        name: 'ConversionRepository',
      );

      return ApiResult.success(result.toEntity());
    } on DioException catch (e) {
      developer.log(
        'Conversion failed: ${e.message}',
        name: 'ConversionRepository',
        error: e,
      );

      return ApiResult.failure(ErrorHandler.handle(e));
    } on Object catch (e) {
      developer.log(
        'Unexpected error during conversion: $e',
        name: 'ConversionRepository',
        error: e,
      );

      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
