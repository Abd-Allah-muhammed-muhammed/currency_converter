import 'package:currency_converter/features/home/data/datasources/conversion_remote_data_source.dart';
import 'package:currency_converter/features/home/data/models/conversion_result_model.dart';
import 'package:currency_converter/features/home/data/repositories/conversion_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ConversionRemoteDataSource for testing.
class MockConversionRemoteDataSource implements ConversionRemoteDataSource {
  MockConversionRemoteDataSource({this.result, this.exception});

  ConversionResultModel? result;
  Exception? exception;
  final List<({String from, String to, double amount})> calls = [];

  @override
  Future<ConversionResultModel> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    calls.add((from: from, to: to, amount: amount));

    if (exception != null) {
      throw exception!;
    }

    return result ??
        ConversionResultModel(
          success: true,
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
          quote: 0.92,
          result: amount * 0.92,
          timestamp: 1735128000,
        );
  }
}

void main() {
  group('ConversionRepositoryImpl', () {
    late ConversionRepositoryImpl repository;
    late MockConversionRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockConversionRemoteDataSource();
      repository = ConversionRepositoryImpl(remoteDataSource: mockDataSource);
    });

    group('convert', () {
      test('should call remote data source with correct parameters', () async {
        // Act
        await repository.convert(from: 'USD', to: 'EUR', amount: 100);

        // Assert
        expect(mockDataSource.calls.length, 1);
        expect(mockDataSource.calls.first.from, 'USD');
        expect(mockDataSource.calls.first.to, 'EUR');
        expect(mockDataSource.calls.first.amount, 100);
      });

      test('should return ApiResult.success with ConversionResult entity', () async {
        // Arrange
        mockDataSource.result = const ConversionResultModel(
          success: true,
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 1000,
          quote: 0.620998,
          result: 620.998,
          timestamp: 1766664244,
        );

        // Act
        final apiResult = await repository.convert(
          from: 'CAD',
          to: 'EUR',
          amount: 1000,
        );

        // Assert
        expect(apiResult.isSuccess, true);
        apiResult.when(
          success: (result) {
            expect(result.fromCurrency, 'CAD');
            expect(result.toCurrency, 'EUR');
            expect(result.amount, 1000);
            expect(result.quote, 0.620998);
            expect(result.result, 620.998);
            expect(
              result.timestamp,
              DateTime.fromMillisecondsSinceEpoch(1766664244 * 1000),
            );
          },
          failure: (_) => fail('Should not be failure'),
        );
      });

      test('should return ApiResult.failure on DioException', () async {
        // Arrange
        mockDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/convert'),
          message: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        );

        // Act
        final result = await repository.convert(
          from: 'USD',
          to: 'EUR',
          amount: 100,
        );

        // Assert
        expect(result.isSuccess, false);
        result.when(
          success: (_) => fail('Should not be success'),
          failure: (error) {
            expect(error.failure.message, isNotEmpty);
          },
        );
      });

      test('should return ApiResult.failure on general exceptions', () async {
        // Arrange
        mockDataSource.exception = Exception('Unexpected error');

        // Act
        final result = await repository.convert(
          from: 'USD',
          to: 'EUR',
          amount: 100,
        );

        // Assert
        expect(result.isSuccess, false);
      });

      test('should handle different currency pairs', () async {
        // Act
        await repository.convert(from: 'GBP', to: 'JPY', amount: 500);

        // Assert
        expect(mockDataSource.calls.first.from, 'GBP');
        expect(mockDataSource.calls.first.to, 'JPY');
        expect(mockDataSource.calls.first.amount, 500);
      });

      test('should handle decimal amounts', () async {
        // Act
        await repository.convert(from: 'EUR', to: 'USD', amount: 123.45);

        // Assert
        expect(mockDataSource.calls.first.amount, 123.45);
      });

      test('should handle very large amounts', () async {
        // Arrange
        mockDataSource.result = const ConversionResultModel(
          success: true,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 1000000000,
          quote: 0.92,
          result: 920000000,
          timestamp: 1735128000,
        );

        // Act
        final apiResult = await repository.convert(
          from: 'USD',
          to: 'EUR',
          amount: 1000000000,
        );

        // Assert
        expect(apiResult.isSuccess, true);
        apiResult.when(
          success: (result) {
            expect(result.amount, 1000000000);
            expect(result.result, 920000000);
          },
          failure: (_) => fail('Should not be failure'),
        );
      });

      test('should handle very small amounts', () async {
        // Arrange
        mockDataSource.result = const ConversionResultModel(
          success: true,
          fromCurrency: 'BTC',
          toCurrency: 'USD',
          amount: 0.00001,
          quote: 42000,
          result: 0.42,
          timestamp: 1735128000,
        );

        // Act
        final apiResult = await repository.convert(
          from: 'BTC',
          to: 'USD',
          amount: 0.00001,
        );

        // Assert
        expect(apiResult.isSuccess, true);
        apiResult.when(
          success: (result) {
            expect(result.amount, 0.00001);
            expect(result.result, 0.42);
          },
          failure: (_) => fail('Should not be failure'),
        );
      });
    });
  });
}
