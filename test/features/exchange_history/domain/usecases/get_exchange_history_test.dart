import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/exchange_history/data/models/get_exchange_history_params.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:currency_converter/features/exchange_history/domain/usecases/get_exchange_history.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ExchangeHistoryRepository for testing.
class MockExchangeHistoryRepository implements ExchangeHistoryRepository {
  MockExchangeHistoryRepository({this.result, this.errorResult});

  ApiResult<ExchangeHistory>? result;
  ApiResult<ExchangeHistory>? errorResult;
  final List<
    ({
      String sourceCurrency,
      String targetCurrency,
      DateTime startDate,
      DateTime endDate,
    })
  >
  calls = [];

  @override
  Future<ApiResult<ExchangeHistory>> getExchangeHistory({
    required String sourceCurrency,
    required String targetCurrency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    calls.add((
      sourceCurrency: sourceCurrency,
      targetCurrency: targetCurrency,
      startDate: startDate,
      endDate: endDate,
    ));

    if (errorResult != null) {
      return errorResult!;
    }

    return result ??
        ApiResult.success(
          ExchangeHistory(
            sourceCurrency: sourceCurrency,
            targetCurrency: targetCurrency,
            rates: [
              RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
              RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.740000),
            ],
            startDate: startDate,
            endDate: endDate,
          ),
        );
  }
}

void main() {
  group('GetExchangeHistory UseCase', () {
    late GetExchangeHistory useCase;
    late MockExchangeHistoryRepository mockRepository;

    setUp(() {
      mockRepository = MockExchangeHistoryRepository();
      useCase = GetExchangeHistory(mockRepository);
    });

    group('successful execution', () {
      test('should call repository with correct parameters', () async {
        // Arrange
        final params = GetExchangeHistoryParams(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Act
        await useCase(params);

        // Assert
        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.sourceCurrency, 'USD');
        expect(mockRepository.calls.first.targetCurrency, 'EUR');
        expect(mockRepository.calls.first.startDate, DateTime(2025, 12, 19));
        expect(mockRepository.calls.first.endDate, DateTime(2025, 12, 25));
      });

      test('should return exchange history from repository', () async {
        // Arrange
        final expectedHistory = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.740000),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.742000),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );
        mockRepository.result = ApiResult.success(expectedHistory);

        final params = GetExchangeHistoryParams(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isSuccess, true);
        result.when(
          success: (data) {
            expect(data.sourceCurrency, 'USD');
            expect(data.targetCurrency, 'EUR');
            expect(data.rates.length, 3);
          },
          failure: (_) => fail('Expected success'),
        );
      });
    });

    group('different currency pairs', () {
      test('should work with USD to GBP', () async {
        // Arrange
        final params = GetExchangeHistoryParams(
          sourceCurrency: 'USD',
          targetCurrency: 'GBP',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Act
        await useCase(params);

        // Assert
        expect(mockRepository.calls.first.sourceCurrency, 'USD');
        expect(mockRepository.calls.first.targetCurrency, 'GBP');
      });

      test('should work with EUR to JPY', () async {
        // Arrange
        final params = GetExchangeHistoryParams(
          sourceCurrency: 'EUR',
          targetCurrency: 'JPY',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        // Act
        await useCase(params);

        // Assert
        expect(mockRepository.calls.first.sourceCurrency, 'EUR');
        expect(mockRepository.calls.first.targetCurrency, 'JPY');
      });
    });
  });

  group('GetExchangeHistoryParams', () {
    group('constructor', () {
      test('should create params with all fields', () {
        final params = GetExchangeHistoryParams(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        expect(params.sourceCurrency, 'USD');
        expect(params.targetCurrency, 'EUR');
        expect(params.startDate, DateTime(2025, 12, 19));
        expect(params.endDate, DateTime(2025, 12, 25));
      });
    });

    group('forDays factory', () {
      test('should create params for 7 days (1 week)', () {
        final params = GetExchangeHistoryParams.forDays(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          days: 7,
        );

        expect(params.sourceCurrency, 'USD');
        expect(params.targetCurrency, 'EUR');
        expect(
          params.endDate.difference(params.startDate).inDays,
          7,
        );
      });

      test('should create params for 30 days (1 month)', () {
        final params = GetExchangeHistoryParams.forDays(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          days: 30,
        );

        expect(
          params.endDate.difference(params.startDate).inDays,
          30,
        );
      });

      test('should create params for 90 days (3 months)', () {
        final params = GetExchangeHistoryParams.forDays(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          days: 90,
        );

        expect(
          params.endDate.difference(params.startDate).inDays,
          90,
        );
      });

      test('should create params for 365 days (1 year)', () {
        final params = GetExchangeHistoryParams.forDays(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          days: 365,
        );

        expect(
          params.endDate.difference(params.startDate).inDays,
          365,
        );
      });
    });

    group('toString', () {
      test('should return readable format', () {
        final params = GetExchangeHistoryParams(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 25),
        );

        final str = params.toString();
        expect(str, contains('GetExchangeHistoryParams'));
        expect(str, contains('USD'));
        expect(str, contains('EUR'));
      });
    });
  });
}
