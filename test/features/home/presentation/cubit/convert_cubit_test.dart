import 'dart:async';

import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/core/network/errors/api_error_model.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/ResponseCode.dart';
import 'package:currency_converter/core/storage/preferences_repository.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_cubit.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock implementation of ConvertCurrency for testing.
class MockConvertCurrency implements ConvertCurrency {
  MockConvertCurrency({
    this.result,
    this.delay = Duration.zero,
  });

  /// The result to return when called.
  ApiResult<ConversionResult>? result;

  /// Delay before returning result (for testing async behavior).
  Duration delay;

  /// Track call parameters.
  final List<ConvertCurrencyParams> calls = [];

  @override
  Future<ApiResult<ConversionResult>> call(ConvertCurrencyParams params) async {
    calls.add(params);

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return result ?? ApiResult.success(_defaultResult(params));
  }

  ConversionResult _defaultResult(ConvertCurrencyParams params) {
    return ConversionResult(
      fromCurrency: params.from,
      toCurrency: params.to,
      amount: params.amount,
      quote: 0.92,
      result: params.amount * 0.92,
      timestamp: DateTime.utc(2025, 12, 25, 12),
    );
  }
}

/// Creates a PreferencesRepository with fake SharedPreferences for testing.
Future<PreferencesRepository> createMockPreferencesRepository() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return PreferencesRepository(prefs);
}

void main() {
  group('ConvertCubit', () {
    late ConvertCubit cubit;
    late MockConvertCurrency mockConvertCurrency;
    late PreferencesRepository mockPreferencesRepository;

    setUp(() async {
      mockConvertCurrency = MockConvertCurrency();
      mockPreferencesRepository = await createMockPreferencesRepository();
      cubit = ConvertCubit(mockConvertCurrency, mockPreferencesRepository);
    });

    tearDown(() {
      unawaited(cubit.close());
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
            result: 92,
            timestamp: DateTime.utc(2025, 12, 25, 12),
          );
          mockConvertCurrency.result = ApiResult.success(expectedResult);

          // Act
          final states = <ConvertState>[];
          cubit.stream.listen(states.add);

          await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

          // Wait for stream to process
          await Future<void>.delayed(const Duration(milliseconds: 50));
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
        mockConvertCurrency.result = ApiResult.failure(
          ErrorHandler.fromMessage(
            const ApiErrorModel(
              code: ResponseCode.defaultError,
              message: 'API Error',
            ),
          ),
        );

        // Act
        final states = <ConvertState>[];
        cubit.stream.listen(states.add);

        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        // Wait for stream to process
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(states.length, 2);
        expect(states[0], isA<ConvertLoading>());
        expect(states[1], isA<ConvertError>());

        final errorState = states[1] as ConvertError;
        expect(errorState.message, 'API Error');
      });

      test('should not call API when amount is zero', () async {
        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 0);

        // Assert
        expect(mockConvertCurrency.calls, isEmpty);
        expect(cubit.state, isA<ConvertInitial>());
      });

      test('should not call API when amount is negative', () async {
        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: -100);

        // Assert
        expect(mockConvertCurrency.calls, isEmpty);
        expect(cubit.state, isA<ConvertInitial>());
      });
    });

    group('convertWithDebounce', () {
      test('should debounce multiple rapid calls', () async {
        // Act - simulate rapid typing
        cubit
          ..convertWithDebounce(from: 'USD', to: 'EUR', amount: 1)
          ..convertWithDebounce(from: 'USD', to: 'EUR', amount: 10)
          ..convertWithDebounce(from: 'USD', to: 'EUR', amount: 100);

        // Wait less than debounce duration
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Assert - no calls yet
        expect(mockConvertCurrency.calls, isEmpty);

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 600));

        // Assert - only last call should be made
        expect(mockConvertCurrency.calls.length, 1);
        expect(mockConvertCurrency.calls.first.amount, 100);
      });

      test('should not call API when amount is zero', () async {
        // Act
        cubit.convertWithDebounce(from: 'USD', to: 'EUR', amount: 0);

        // Wait for potential debounce
        await Future<void>.delayed(const Duration(milliseconds: 1200));

        // Assert
        expect(mockConvertCurrency.calls, isEmpty);
      });
    });

    group('swapCurrencies', () {
      test('should swap from and to currencies', () async {
        // Arrange - set currencies by doing conversions
        await cubit.setFromCurrency(
          const Currency(code: 'USD', name: 'United States Dollar'),
        );
        await cubit.setToCurrency(const Currency(code: 'EUR', name: 'Euro'));

        // Set amount by doing an immediate conversion first
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        mockConvertCurrency.calls.clear();

        // Act
        await cubit.swapCurrencies();

        // Assert
        expect(cubit.fromCurrency, 'EUR');
        expect(cubit.toCurrency, 'USD');

        // Should call API with swapped currencies
        expect(mockConvertCurrency.calls.length, 1);
        expect(mockConvertCurrency.calls.first.from, 'EUR');
        expect(mockConvertCurrency.calls.first.to, 'USD');
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
          result: 92,
          timestamp: DateTime.utc(2025, 12, 25, 14, 30),
        );
        mockConvertCurrency.result = ApiResult.success(expectedResult);

        // Act
        await cubit.convertImmediately(from: 'USD', to: 'EUR', amount: 100);

        // Assert
        final state = cubit.state as ConvertSuccess;
        expect(state.formattedTimestamp, '14:30 UTC');
      });
    });
  });
}
