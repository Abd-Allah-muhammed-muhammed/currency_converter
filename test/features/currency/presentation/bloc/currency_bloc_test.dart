import 'package:bloc_test/bloc_test.dart';
import 'package:currency_converter/core/network/api_error_handler.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/currency/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_bloc.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_event.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrencies extends Mock implements GetCurrencies {}

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late CurrencyBloc bloc;
  late MockGetCurrencies mockGetCurrencies;
  late MockCurrencyRepository mockRepository;

  setUp(() {
    mockGetCurrencies = MockGetCurrencies();
    mockRepository = MockCurrencyRepository();
    bloc = CurrencyBloc(
      getCurrencies: mockGetCurrencies,
      repository: mockRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  final tCurrencies = [
    const Currency(
      code: 'USD',
      name: 'US Dollar',
      flagUrl: 'https://flagcdn.com/w40/us.png',
    ),
    const Currency(
      code: 'EUR',
      name: 'Euro',
      flagUrl: 'https://flagcdn.com/w40/eu.png',
    ),
    const Currency(
      code: 'GBP',
      name: 'British Pound',
      flagUrl: 'https://flagcdn.com/w40/gb.png',
    ),
  ];

  test('initial state should be CurrencyInitial', () {
    expect(bloc.state, equals(const CurrencyInitial()));
  });

  group('LoadCurrencies', () {
    blocTest<CurrencyBloc, CurrencyState>(
      'emits [CurrencyLoading, CurrencyLoaded] when LoadCurrencies is added '
      'and getCurrencies returns success',
      build: () {
        when(() => mockGetCurrencies(any()))
            .thenAnswer((_) async => ApiResult.success(tCurrencies));
        when(() => mockRepository.hasCachedCurrencies())
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCurrencies()),
      expect: () => [
        const CurrencyLoading(),
        isA<CurrencyLoaded>()
            .having((s) => s.currencies.length, 'currencies length', 3)
            .having((s) => s.isFromCache, 'isFromCache', true),
      ],
      verify: (_) {
        verify(() => mockGetCurrencies(any())).called(1);
        verify(() => mockRepository.hasCachedCurrencies()).called(1);
      },
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'emits [CurrencyLoading, CurrencyError] when LoadCurrencies fails',
      build: () {
        when(() => mockGetCurrencies(any())).thenAnswer(
          (_) async => ApiResult.failure(
            ErrorHandler.handle(Exception('Test error')),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCurrencies()),
      expect: () => [
        const CurrencyLoading(),
        isA<CurrencyError>(),
      ],
      verify: (_) {
        verify(() => mockGetCurrencies(any())).called(1);
      },
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'extracts popular currencies correctly',
      build: () {
        when(() => mockGetCurrencies(any()))
            .thenAnswer((_) async => ApiResult.success(tCurrencies));
        when(() => mockRepository.hasCachedCurrencies())
            .thenAnswer((_) async => false);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCurrencies()),
      expect: () => [
        const CurrencyLoading(),
        isA<CurrencyLoaded>().having(
          (s) => s.popularCurrencies.any((c) => c.code == 'USD'),
          'contains USD in popular',
          true,
        ),
      ],
    );
  });

  group('RefreshCurrencies', () {
    blocTest<CurrencyBloc, CurrencyState>(
      'emits [CurrencyLoading, CurrencyLoaded] when RefreshCurrencies succeeds',
      build: () {
        when(() => mockRepository.refreshCurrencies())
            .thenAnswer((_) async => ApiResult.success(tCurrencies));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshCurrencies()),
      expect: () => [
        const CurrencyLoading(),
        isA<CurrencyLoaded>()
            .having((s) => s.isFromCache, 'isFromCache', false),
      ],
      verify: (_) {
        verify(() => mockRepository.refreshCurrencies()).called(1);
      },
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'emits CurrencyError when RefreshCurrencies fails',
      build: () {
        when(() => mockRepository.refreshCurrencies()).thenAnswer(
          (_) async => ApiResult.failure(
            ErrorHandler.handle(Exception('Network error')),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshCurrencies()),
      expect: () => [
        const CurrencyLoading(),
        isA<CurrencyError>(),
      ],
    );
  });

  group('SearchCurrencies', () {
    blocTest<CurrencyBloc, CurrencyState>(
      'filters currencies by search query when in CurrencyLoaded state',
      build: () {
        when(() => mockGetCurrencies(any()))
            .thenAnswer((_) async => ApiResult.success(tCurrencies));
        when(() => mockRepository.hasCachedCurrencies())
            .thenAnswer((_) async => true);
        return bloc;
      },
      seed: () => CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('usd')),
      expect: () => [
        isA<CurrencyLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'usd')
            .having(
              (s) => s.filteredCurrencies?.length,
              'filtered length',
              1,
            )
            .having(
              (s) => s.filteredCurrencies?.first.code,
              'filtered code',
              'USD',
            ),
      ],
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'clears filter when search query is empty',
      build: () => bloc,
      seed: () => CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
        searchQuery: 'usd',
        filteredCurrencies: [tCurrencies.first],
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('')),
      expect: () => [
        isA<CurrencyLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', ''),
      ],
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'filters currencies by name',
      build: () => bloc,
      seed: () => CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('euro')),
      expect: () => [
        isA<CurrencyLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'euro')
            .having(
              (s) => s.filteredCurrencies?.first.code,
              'filtered code',
              'EUR',
            ),
      ],
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'does nothing when not in CurrencyLoaded state',
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchCurrencies('usd')),
      expect: () => [],
    );

    blocTest<CurrencyBloc, CurrencyState>(
      'returns empty list when no currencies match',
      build: () => bloc,
      seed: () => CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
      ),
      act: (bloc) => bloc.add(const SearchCurrencies('xyz')),
      expect: () => [
        isA<CurrencyLoaded>()
            .having((s) => s.filteredCurrencies?.length, 'filtered length', 0),
      ],
    );
  });

  group('CurrencyLoaded', () {
    test('displayCurrencies returns all currencies when searchQuery is empty',
        () {
      final state = CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
        searchQuery: '',
      );

      expect(state.displayCurrencies, equals(tCurrencies));
    });

    test(
        'displayCurrencies returns filtered currencies when searchQuery is not empty',
        () {
      final filteredList = [tCurrencies.first];
      final state = CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
        searchQuery: 'usd',
        filteredCurrencies: filteredList,
      );

      expect(state.displayCurrencies, equals(filteredList));
    });

    test('copyWith creates a new instance with updated values', () {
      final original = CurrencyLoaded(
        currencies: tCurrencies,
        popularCurrencies: tCurrencies,
        isFromCache: true,
        searchQuery: '',
      );

      final copied = original.copyWith(
        searchQuery: 'test',
        isFromCache: false,
      );

      expect(copied.searchQuery, equals('test'));
      expect(copied.isFromCache, isFalse);
      expect(copied.currencies, equals(tCurrencies));
    });
  });
}
