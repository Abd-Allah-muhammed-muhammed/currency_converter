import 'package:currency_converter/features/exchange_history/data/datasources/exchange_history_remote_data_source.dart';
import 'package:currency_converter/features/exchange_history/data/models/exchange_history_model.dart';
import 'package:currency_converter/features/exchange_history/data/repositories/exchange_history_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ExchangeHistoryRemoteDataSource for testing.
class MockExchangeHistoryRemoteDataSource
    implements ExchangeHistoryRemoteDataSource {
  MockExchangeHistoryRemoteDataSource({this.result, this.exception});

  ExchangeHistoryModel? result;
  Exception? exception;
  final List<({String source, String target, String startDate, String endDate})>
  calls = [];

  @override
  Future<ExchangeHistoryModel> getExchangeHistory({
    required String source,
    required String target,
    required String startDate,
    required String endDate,
  }) async {
    calls.add((
      source: source,
      target: target,
      startDate: startDate,
      endDate: endDate,
    ));

    if (exception != null) {
      throw exception!;
    }

    return result ??
        ExchangeHistoryModel.fromJson({
          'success': true,
          'timeframe': true,
          'start_date': startDate,
          'end_date': endDate,
          'source': source,
          'quotes': {
            '2025-12-19': {'$source$target': 0.738541},
            '2025-12-20': {'$source$target': 0.740000},
            '2025-12-21': {'$source$target': 0.750000},
          },
        });
  }
}

void main() {
  group('ExchangeHistoryRepositoryImpl', () {
    late ExchangeHistoryRepositoryImpl repository;
    late MockExchangeHistoryRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockExchangeHistoryRemoteDataSource();
      repository = ExchangeHistoryRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getExchangeHistory', () {
      test('should call remote data source with correct parameters', () async {
        // Act
        await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Assert
        expect(mockRemoteDataSource.calls.length, 1);
        expect(mockRemoteDataSource.calls.first.source, 'USD');
        expect(mockRemoteDataSource.calls.first.target, 'EUR');
        expect(mockRemoteDataSource.calls.first.startDate, '2025-12-19');
        expect(mockRemoteDataSource.calls.first.endDate, '2025-12-25');
      });

      test(
        'should return success with ExchangeHistory on successful response',
        () async {
          // Arrange
          mockRemoteDataSource.result = ExchangeHistoryModel.fromJson(const {
            'success': true,
            'timeframe': true,
            'start_date': '2025-12-19',
            'end_date': '2025-12-21',
            'source': 'USD',
            'quotes': {
              '2025-12-19': {'USDEUR': 0.738541},
              '2025-12-20': {'USDEUR': 0.740000},
              '2025-12-21': {'USDEUR': 0.750000},
            },
          });

          // Act
          final result = await repository.getExchangeHistory(
            sourceCurrency: 'USD',
            targetCurrency: 'EUR',
            startDate: DateTime(2025, 12, 19),
            endDate: DateTime(2025, 12, 21),
          );

          // Assert
          expect(result.isSuccess, true);
          result.when(
            success: (history) {
              expect(history.sourceCurrency, 'USD');
              expect(history.targetCurrency, 'EUR');
              expect(history.rates.length, 3);
              expect(history.rates[0].rate, 0.738541);
              expect(history.rates[1].rate, 0.740000);
              expect(history.rates[2].rate, 0.750000);
            },
            failure: (_) => fail('Expected success'),
          );
        },
      );

      test('should return rates sorted by date', () async {
        // Arrange - dates are not in order in the response
        mockRemoteDataSource.result = ExchangeHistoryModel.fromJson(const {
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-21',
          'source': 'USD',
          'quotes': {
            '2025-12-21': {'USDEUR': 0.750000},
            '2025-12-19': {'USDEUR': 0.738541},
            '2025-12-20': {'USDEUR': 0.740000},
          },
        });

        // Act
        final result = await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        // Assert
        result.when(
          success: (history) {
            expect(history.rates[0].date, DateTime(2025, 12, 19));
            expect(history.rates[1].date, DateTime(2025, 12, 20));
            expect(history.rates[2].date, DateTime(2025, 12, 21));
          },
          failure: (_) => fail('Expected success'),
        );
      });

      test('should return failure when DioException occurs', () async {
        // Arrange
        mockRemoteDataSource.exception = DioException(
          requestOptions: RequestOptions(path: '/timeframe'),
          message: 'Network error',
          type: DioExceptionType.connectionTimeout,
        );

        // Act
        final result = await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Assert
        expect(result.isSuccess, false);
      });

      test('should return failure when generic exception occurs', () async {
        // Arrange
        mockRemoteDataSource.exception = Exception('Unknown error');

        // Act
        final result = await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Assert
        expect(result.isSuccess, false);
      });

      test('should handle empty quotes', () async {
        // Arrange
        mockRemoteDataSource.result = ExchangeHistoryModel.fromJson(const {
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-25',
          'source': 'USD',
          'quotes': <String, dynamic>{},
        });

        // Act
        final result = await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Assert
        expect(result.isSuccess, true);
        result.when(
          success: (history) {
            expect(history.rates, isEmpty);
          },
          failure: (_) => fail('Expected success'),
        );
      });

      test('should format dates correctly', () async {
        // Act
        await repository.getExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 1, 5), // Single digit day
          endDate: DateTime(2025, 10, 15),
        );

        // Assert
        expect(mockRemoteDataSource.calls.first.startDate, '2025-01-05');
        expect(mockRemoteDataSource.calls.first.endDate, '2025-10-15');
      });
    });
  });
}
