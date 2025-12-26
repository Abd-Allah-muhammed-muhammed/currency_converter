import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';
import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ConversionRepository for testing.
class MockConversionRepository implements ConversionRepository {
  MockConversionRepository({this.result});

  ApiResult<ConversionResult>? result;
  final List<({String from, String to, double amount})> calls = [];

  @override
  Future<ApiResult<ConversionResult>> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    calls.add((from: from, to: to, amount: amount));

    return result ??
        ApiResult.success(
          ConversionResult(
            fromCurrency: from,
            toCurrency: to,
            amount: amount,
            quote: 0.92,
            result: amount * 0.92,
            timestamp: DateTime.utc(2025, 12, 25, 12),
          ),
        );
  }
}

void main() {
  group('ConvertCurrency UseCase', () {
    late ConvertCurrency useCase;
    late MockConversionRepository mockRepository;

    setUp(() {
      mockRepository = MockConversionRepository();
      useCase = ConvertCurrency(mockRepository);
    });

    group('successful conversion', () {
      test('should call repository with correct parameters', () async {
        // Arrange
        const params = ConvertCurrencyParams(
          from: 'USD',
          to: 'EUR',
          amount: 100,
        );

        // Act
        await useCase(params);

        // Assert
        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.from, 'USD');
        expect(mockRepository.calls.first.to, 'EUR');
        expect(mockRepository.calls.first.amount, 100);
      });

      test('should return ApiResult.success from repository', () async {
        // Arrange
        final expectedResult = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92,
          timestamp: DateTime.utc(2025, 12, 25, 12),
        );
        mockRepository.result = ApiResult.success(expectedResult);

        const params = ConvertCurrencyParams(
          from: 'USD',
          to: 'EUR',
          amount: 100,
        );

        // Act
        final apiResult = await useCase(params);

        // Assert
        expect(apiResult.isSuccess, true);
        apiResult.when(
          success: (result) {
            expect(result.fromCurrency, 'USD');
            expect(result.toCurrency, 'EUR');
            expect(result.amount, 100);
            expect(result.quote, 0.92);
            expect(result.result, 92.0);
          },
          failure: (_) => fail('Should not be failure'),
        );
      });
    });

    group('input validation', () {
      test('should return ApiResult.failure when amount is zero', () async {
        // Arrange
        const params = ConvertCurrencyParams(from: 'USD', to: 'EUR', amount: 0);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isSuccess, false);
        result.when(
          success: (_) => fail('Should not be success'),
          failure: (error) {
            expect(error.failure.message, 'Amount must be greater than zero');
          },
        );
        expect(mockRepository.calls, isEmpty);
      });

      test('should return ApiResult.failure when amount is negative', () async {
        // Arrange
        const params = ConvertCurrencyParams(
          from: 'USD',
          to: 'EUR',
          amount: -50,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isSuccess, false);
        result.when(
          success: (_) => fail('Should not be success'),
          failure: (error) {
            expect(error.failure.message, 'Amount must be greater than zero');
          },
        );
        expect(mockRepository.calls, isEmpty);
      });

      test(
        'should return ApiResult.failure when from currency is empty',
        () async {
          // Arrange
          const params = ConvertCurrencyParams(
            from: '',
            to: 'EUR',
            amount: 100,
          );

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isSuccess, false);
          result.when(
            success: (_) => fail('Should not be success'),
            failure: (error) {
              expect(error.failure.message, 'Currency codes cannot be empty');
            },
          );
          expect(mockRepository.calls, isEmpty);
        },
      );

      test(
        'should return ApiResult.failure when to currency is empty',
        () async {
          // Arrange
          const params = ConvertCurrencyParams(
            from: 'USD',
            to: '',
            amount: 100,
          );

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isSuccess, false);
          result.when(
            success: (_) => fail('Should not be success'),
            failure: (error) {
              expect(error.failure.message, 'Currency codes cannot be empty');
            },
          );
          expect(mockRepository.calls, isEmpty);
        },
      );

      test(
        'should return ApiResult.failure when both currencies are empty',
        () async {
          // Arrange
          const params = ConvertCurrencyParams(from: '', to: '', amount: 100);

          // Act
          final result = await useCase(params);

          // Assert
          expect(result.isSuccess, false);
          expect(mockRepository.calls, isEmpty);
        },
      );
    });

    group('same currency conversion', () {
      test(
        'should return identity conversion without calling repository',
        () async {
          // Arrange
          const params = ConvertCurrencyParams(
            from: 'USD',
            to: 'USD',
            amount: 100,
          );

          // Act
          final apiResult = await useCase(params);

          // Assert
          expect(mockRepository.calls, isEmpty);
          expect(apiResult.isSuccess, true);
          apiResult.when(
            success: (result) {
              expect(result.fromCurrency, 'USD');
              expect(result.toCurrency, 'USD');
              expect(result.amount, 100);
              expect(result.quote, 1.0);
              expect(result.result, 100);
            },
            failure: (_) => fail('Should not be failure'),
          );
        },
      );

      test('should handle same currency with decimal amount', () async {
        // Arrange
        const params = ConvertCurrencyParams(
          from: 'EUR',
          to: 'EUR',
          amount: 123.45,
        );

        // Act
        final apiResult = await useCase(params);

        // Assert
        expect(mockRepository.calls, isEmpty);
        expect(apiResult.isSuccess, true);
        apiResult.when(
          success: (result) {
            expect(result.amount, 123.45);
            expect(result.result, 123.45);
            expect(result.quote, 1.0);
          },
          failure: (_) => fail('Should not be failure'),
        );
      });
    });
  });

  group('ConvertCurrencyParams', () {
    test('should store all parameters correctly', () {
      // Arrange & Act
      const params = ConvertCurrencyParams(
        from: 'USD',
        to: 'EUR',
        amount: 100.50,
      );

      // Assert
      expect(params.from, 'USD');
      expect(params.to, 'EUR');
      expect(params.amount, 100.50);
    });
  });
}
