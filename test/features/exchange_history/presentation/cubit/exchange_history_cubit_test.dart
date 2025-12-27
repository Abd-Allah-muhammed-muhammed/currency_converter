import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/core/network/errors/api_error_model.dart';
import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:currency_converter/features/exchange_history/domain/usecases/get_exchange_history.dart';
import 'package:currency_converter/features/exchange_history/presentation/cubit/exchange_history_cubit.dart';
import 'package:currency_converter/features/exchange_history/presentation/cubit/exchange_history_state.dart';
import 'package:currency_converter/features/exchange_history/presentation/widgets/time_period_selector.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of ExchangeHistoryRepository for testing.
class MockExchangeHistoryRepository implements ExchangeHistoryRepository {
  MockExchangeHistoryRepository({this.result, this.errorHandler});

  ApiResult<ExchangeHistory>? result;
  ErrorHandler? errorHandler;
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

    if (errorHandler != null) {
      return ApiResult.failure(errorHandler);
    }

    return result ??
        ApiResult.success(
          ExchangeHistory(
            sourceCurrency: sourceCurrency,
            targetCurrency: targetCurrency,
            rates: [
              RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
              RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.740000),
              RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.750000),
            ],
            startDate: startDate,
            endDate: endDate,
          ),
        );
  }
}

void main() {
  group('ExchangeHistoryCubit', () {
    late ExchangeHistoryCubit cubit;
    late MockExchangeHistoryRepository mockRepository;
    late GetExchangeHistory getExchangeHistory;

    setUp(() {
      mockRepository = MockExchangeHistoryRepository();
      getExchangeHistory = GetExchangeHistory(mockRepository);
      cubit = ExchangeHistoryCubit(getExchangeHistory: getExchangeHistory);
    });

    tearDown(() {
      unawaited(cubit.close());
    });

    test('initial state should be ExchangeHistoryInitial', () {
      expect(cubit.state, isA<ExchangeHistoryInitial>());
    });

    group('loadHistory', () {
      blocTest<ExchangeHistoryCubit, ExchangeHistoryState>(
        'emits [Loading, Loaded] when loadHistory succeeds',
        build: () => cubit,
        act: (cubit) => cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        ),
        expect: () => [
          isA<ExchangeHistoryLoading>()
              .having((s) => s.sourceCurrency, 'sourceCurrency', 'USD')
              .having((s) => s.targetCurrency, 'targetCurrency', 'EUR'),
          isA<ExchangeHistoryLoaded>()
              .having((s) => s.sourceCurrency, 'sourceCurrency', 'USD')
              .having((s) => s.targetCurrency, 'targetCurrency', 'EUR')
              .having((s) => s.chartData.length, 'chartData.length', 3),
        ],
      );

      blocTest<ExchangeHistoryCubit, ExchangeHistoryState>(
        'emits [Loading, Error] when loadHistory fails',
        build: () {
          mockRepository.errorHandler = ErrorHandler.fromMessage(
            const ApiErrorModel(message: 'Network error', code: 500),
          );
          return ExchangeHistoryCubit(
            getExchangeHistory: GetExchangeHistory(mockRepository),
          );
        },
        act: (cubit) => cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        ),
        expect: () => [
          isA<ExchangeHistoryLoading>(),
          isA<ExchangeHistoryError>().having(
            (s) => s.message,
            'message',
            'Network error',
          ),
        ],
      );

      blocTest<ExchangeHistoryCubit, ExchangeHistoryState>(
        'emits [Loading, Error] when rates are empty',
        build: () {
          mockRepository.result = ApiResult.success(
            ExchangeHistory(
              sourceCurrency: 'USD',
              targetCurrency: 'EUR',
              rates: const [],
              startDate: DateTime(2025, 12, 19),
              endDate: DateTime(2025, 12, 25),
            ),
          );
          return ExchangeHistoryCubit(
            getExchangeHistory: GetExchangeHistory(mockRepository),
          );
        },
        act: (cubit) => cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        ),
        expect: () => [
          isA<ExchangeHistoryLoading>(),
          isA<ExchangeHistoryError>().having(
            (s) => s.message,
            'message',
            'No exchange rate data available for this period',
          ),
        ],
      );

      test('should call repository with correct parameters', () async {
        await cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        );

        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.sourceCurrency, 'USD');
        expect(mockRepository.calls.first.targetCurrency, 'EUR');
      });

      test('should calculate statistics correctly when loaded', () async {
        mockRepository.result = ApiResult.success(
          ExchangeHistory(
            sourceCurrency: 'USD',
            targetCurrency: 'EUR',
            rates: [
              RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.70),
              RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.80),
              RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.90),
            ],
            startDate: DateTime(2025, 12, 19),
            endDate: DateTime(2025, 12, 21),
          ),
        );

        await cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        );

        final state = cubit.state as ExchangeHistoryLoaded;
        expect(state.currentRate, 0.90); // Latest rate
        expect(state.highRate, 0.90);
        expect(state.lowRate, 0.70);
        expect(state.averageRate, closeTo(0.80, 0.001));
        expect(state.isPositiveChange, true); // 0.90 > 0.70
      });
    });

    group('changePeriod', () {
      blocTest<ExchangeHistoryCubit, ExchangeHistoryState>(
        'reloads data with new period',
        build: () => cubit,
        seed: () => ExchangeHistoryLoaded(
          history: ExchangeHistory(
            sourceCurrency: 'USD',
            targetCurrency: 'EUR',
            rates: [RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.9)],
            startDate: DateTime(2025, 12, 19),
            endDate: DateTime(2025, 12, 25),
          ),
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
          currentRate: 0.9,
          changePercentage: 0,
          isPositiveChange: true,
          highRate: 0.9,
          lowRate: 0.9,
          averageRate: 0.9,
          chartData: [RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.9)],
          periodDays: 7,
          selectedPeriod: TimePeriod.oneWeek,
        ),
        act: (cubit) {
          // Set internal currency names
          unawaited(
            cubit.loadHistory(
              sourceCurrency: 'USD',
              targetCurrency: 'EUR',
              sourceCurrencyName: 'US Dollar',
              targetCurrencyName: 'Euro',
            ),
          );
          return cubit.changePeriod(TimePeriod.oneMonth);
        },
        verify: (_) {
          // Should have made 2 calls - initial and changePeriod
          expect(mockRepository.calls.length, 2);
        },
      );
    });

    group('swapCurrencies', () {
      test('should swap source and target currencies', () async {
        await cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        );

        mockRepository.calls.clear();

        await cubit.swapCurrencies();

        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.sourceCurrency, 'EUR');
        expect(mockRepository.calls.first.targetCurrency, 'USD');
      });
    });

    group('retry', () {
      test('should reload with same parameters', () async {
        await cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        );

        mockRepository.calls.clear();

        await cubit.retry();

        expect(mockRepository.calls.length, 1);
        expect(mockRepository.calls.first.sourceCurrency, 'USD');
        expect(mockRepository.calls.first.targetCurrency, 'EUR');
      });
    });

    group('getters', () {
      test('should return current currency values', () async {
        await cubit.loadHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
        );

        expect(cubit.sourceCurrency, 'USD');
        expect(cubit.targetCurrency, 'EUR');
        expect(cubit.sourceCurrencyName, 'US Dollar');
        expect(cubit.targetCurrencyName, 'Euro');
        expect(cubit.currentPeriodDays, 7);
      });
    });
  });

  group('ExchangeHistoryState', () {
    group('ExchangeHistoryLoaded', () {
      test('copyWith should update specified fields', () {
        final original = ExchangeHistoryLoaded(
          history: ExchangeHistory(
            sourceCurrency: 'USD',
            targetCurrency: 'EUR',
            rates: const [],
            startDate: DateTime(2025, 12, 19),
            endDate: DateTime(2025, 12, 25),
          ),
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          sourceCurrencyName: 'US Dollar',
          targetCurrencyName: 'Euro',
          currentRate: 0.9,
          changePercentage: 1,
          isPositiveChange: true,
          highRate: 0.95,
          lowRate: 0.85,
          averageRate: 0.9,
          chartData: const [],
          periodDays: 7,
          selectedPeriod: TimePeriod.oneWeek,
        );

        final updated = original.copyWith(
          currentRate: 0.92,
          periodDays: 30,
          selectedPeriod: TimePeriod.oneMonth,
        );

        expect(updated.currentRate, 0.92);
        expect(updated.periodDays, 30);
        expect(updated.selectedPeriod, TimePeriod.oneMonth);
        // Unchanged fields
        expect(updated.sourceCurrency, 'USD');
        expect(updated.targetCurrency, 'EUR');
        expect(updated.highRate, 0.95);
      });
    });
  });
}
