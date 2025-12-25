import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';
import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_cubit.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ConversionRepository for testing.
class MockConversionRepository implements ConversionRepository {
  MockConversionRepository({
    this.result,
    this.exception,
    this.delay = Duration.zero,
  });

  /// The result to return when called.
  ConversionResult? result;

  /// The exception to throw when called.
  Exception? exception;

  /// Delay before returning result (for testing async behavior).
  Duration delay;

  /// Track call parameters.
  final List<({String from, String to, double amount})> calls = [];

  @override
  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    calls.add((from: from, to: to, amount: amount));

    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    if (exception != null) {
      throw exception!;
    }

    return result ?? _defaultResult(from, to, amount);
  }

  ConversionResult _defaultResult(String from, String to, double amount) {
    return ConversionResult(
      fromCurrency: from,
      toCurrency: to,
      amount: amount,
      quote: 0.92,
      result: amount * 0.92,
      timestamp: DateTime.utc(2025, 12, 25, 12, 0),
    );
  }
}

void main() {
  group('ConvertCubit', () {
    late ConvertCubit cubit;
    late MockConversionRepository mockRepository;
    late ConvertCurrency convertCurrency;

    setUp(() {
      mockRepository = MockConversionRepository();
      convertCurrency = ConvertCurrency(mockRepository);
      cubit = ConvertCubit(convertCurrency: convertCurrency);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be ConvertInitial', () {
      expect(cubit.state, isA<ConvertInitial>());
    });

    group('convertImmediately', () {
      test(
        'should emit Loading then Success when conversion succeeds',
        () async {
          // Arrange
          final expectedResult = ConversionResult(
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            amount: 100,
            quote: 0.92,
            result: 92.0,
            timestamp: DateTime.utc(2025, 12, 25, 12, 0),
          );
          mockRepository.result = expectedResult;

          // Act
          final states = <ConvertState>[];
          cubit.stream.listen(states.add);

          await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

          // Wait for stream to process
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert
          expect(states.length, 2);
          expect(states[0], isA<ConvertLoading>());
          expect(states[1], isA<ConvertSuccess>());

          final successState = states[1] as ConvertSuccess;
          expect(successState.result.fromCurrency, 'USD');
          expect(successState.result.toCurrency, 'EUR');
          expect(successState.result.amount, 100);
          expect(successState.rate, 0.92);
          expect(successState.convertedAmount, 92.0);
        },
      );

      test('should emit Loading then Error when conversion fails', () async {
        // Arrange
        mockRepository.exception = Exception('API Error');

        // Act
        final states = <ConvertState>[];
        cubit.stream.listen(states.add);

        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        // Wait for stream to process
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(states.length, 2);
        expect(states[0], isA<ConvertLoading>());
        expect(states[1], isA<ConvertError>());

        final errorState = states[1] as ConvertError;
        expect(errorState.message, 'An unexpected error occurred');
      });

      test('should not call API when amount is zero', () async {
        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 0);

        // Assert
        expect(mockRepository.calls, isEmpty);
        expect(cubit.state, isA<ConvertInitial>());
      });

      test('should not call API when amount is negative', () async {
        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: -100);

        // Assert
        expect(mockRepository.calls, isEmpty);
        expect(cubit.state, isA<ConvertInitial>());
      });
    });

    group('convertWithDebounce', () {
      test('should debounce multiple rapid calls', () async {
        // Act - simulate rapid typing
        cubit.convertWithDebounce(from: 'USD', to: 'EUR', amount: 1);
        cubit.convertWithDebounce(from: 'USD', to: 'EUR', amount: 10);
        cubit.convertWithDebounce(from: 'USD', to: 'EUR', amount: 100);

        // Wait less than debounce duration
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert - no calls yet
        expect(mockRepository.calls, isEmpty);

        // Wait for debounce to complete
        await Future.delayed(const Duration(milliseconds: 600));

        // Assert - only last call should be made
        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.amount, 100);
      });

      test('should not call API when amount is zero', () async {
        // Act
        cubit.convertWithDebounce(from: 'USD', to: 'EUR', amount: 0);

        // Wait for potential debounce
        await Future.delayed(const Duration(milliseconds: 1200));

        // Assert
        expect(mockRepository.calls, isEmpty);
      });
    });

    group('swapCurrencies', () {
      test('should swap from and to currencies', () async {
        // Arrange
        cubit.setFromCurrency('USD');
        cubit.setToCurrency('EUR');

        // Set amount by doing an immediate conversion first
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        mockRepository.calls.clear();

        // Act
        await cubit.swapCurrencies();

        // Assert
        expect(cubit.fromCurrency, 'EUR');
        expect(cubit.toCurrency, 'USD');

        // Should call API with swapped currencies
        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.from, 'EUR');
        expect(mockRepository.calls.first.to, 'USD');
      });
    });

    group('ConvertSuccess state', () {
      test('should provide correct formatted timestamp', () async {
        // Arrange
        final expectedResult = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 14, 30),
        );
        mockRepository.result = expectedResult;

        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        // Assert
        final state = cubit.state as ConvertSuccess;
        expect(state.formattedTimestamp, '14:30 UTC');
      });
    });
  });
}
