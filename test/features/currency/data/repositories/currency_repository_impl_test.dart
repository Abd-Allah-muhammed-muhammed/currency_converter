import 'package:currency_converter/core/network/api_error_handler.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:currency_converter/features/currency/data/models/currency_model.dart';
import 'package:currency_converter/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyLocalDataSource extends Mock
    implements CurrencyLocalDataSource {}

class MockCurrencyRemoteDataSource extends Mock
    implements CurrencyRemoteDataSource {}

void main() {
  late CurrencyRepositoryImpl repository;
  late MockCurrencyLocalDataSource mockLocalDataSource;
  late MockCurrencyRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockCurrencyLocalDataSource();
    mockRemoteDataSource = MockCurrencyRemoteDataSource();
    repository = CurrencyRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(<CurrencyModel>[]);
  });

  final tCurrencyModels = [
    const CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      flagUrl: 'https://flagcdn.com/w40/us.png',
    ),
    const CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      flagUrl: 'https://flagcdn.com/w40/eu.png',
    ),
  ];

  final tCurrencyEntities = tCurrencyModels.map((m) => m.toEntity()).toList();

  group('getCurrencies', () {
    test(
        'should return currencies from local data source when cache is available',
        () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getCurrencies())
          .thenAnswer((_) async => tCurrencyModels);

      // Act
      final result = await repository.getCurrencies();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, equals(2));
      expect(result.data![0].code, equals('USD'));
      verify(() => mockLocalDataSource.hasCurrencies()).called(1);
      verify(() => mockLocalDataSource.getCurrencies()).called(1);
      verifyNever(() => mockRemoteDataSource.getCurrencies());
    });

    test(
        'should fetch from remote and cache when local data source is empty',
        () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenAnswer((_) async => false);
      when(() => mockRemoteDataSource.getCurrencies())
          .thenAnswer((_) async => tCurrencyModels);
      when(() => mockLocalDataSource.saveCurrencies(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getCurrencies();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, equals(2));
      verify(() => mockLocalDataSource.hasCurrencies()).called(1);
      verify(() => mockRemoteDataSource.getCurrencies()).called(1);
      verify(() => mockLocalDataSource.saveCurrencies(any())).called(1);
    });

    test('should return failure when remote fetch fails and no cache',
        () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenAnswer((_) async => false);
      when(() => mockRemoteDataSource.getCurrencies()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/list'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act
      final result = await repository.getCurrencies();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorHandler, isNotNull);
      verify(() => mockLocalDataSource.hasCurrencies()).called(1);
      verify(() => mockRemoteDataSource.getCurrencies()).called(1);
    });

    test('should return failure when unexpected exception occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getCurrencies();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorHandler, isNotNull);
    });
  });

  group('getCurrencyByCode', () {
    test('should return currency when it exists in local data source',
        () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrencyByCode('USD'))
          .thenAnswer((_) async => tCurrencyModels[0]);

      // Act
      final result = await repository.getCurrencyByCode('USD');

      // Assert
      expect(result, isNotNull);
      expect(result!.code, equals('USD'));
      expect(result.name, equals('US Dollar'));
      verify(() => mockLocalDataSource.getCurrencyByCode('USD')).called(1);
    });

    test('should return null when currency does not exist', () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrencyByCode('XYZ'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrencyByCode('XYZ');

      // Assert
      expect(result, isNull);
      verify(() => mockLocalDataSource.getCurrencyByCode('XYZ')).called(1);
    });

    test('should return null when exception occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrencyByCode('USD'))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getCurrencyByCode('USD');

      // Assert
      expect(result, isNull);
    });
  });

  group('hasCachedCurrencies', () {
    test('should return true when currencies exist in cache', () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.hasCachedCurrencies();

      // Assert
      expect(result, isTrue);
      verify(() => mockLocalDataSource.hasCurrencies()).called(1);
    });

    test('should return false when no currencies in cache', () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.hasCachedCurrencies();

      // Assert
      expect(result, isFalse);
      verify(() => mockLocalDataSource.hasCurrencies()).called(1);
    });

    test('should return false when exception occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.hasCurrencies())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.hasCachedCurrencies();

      // Assert
      expect(result, isFalse);
    });
  });

  group('refreshCurrencies', () {
    test('should clear cache and fetch fresh data from remote', () async {
      // Arrange
      when(() => mockLocalDataSource.clearCurrencies())
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.getCurrencies())
          .thenAnswer((_) async => tCurrencyModels);
      when(() => mockLocalDataSource.saveCurrencies(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.refreshCurrencies();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, equals(2));
      verify(() => mockLocalDataSource.clearCurrencies()).called(1);
      verify(() => mockRemoteDataSource.getCurrencies()).called(1);
      verify(() => mockLocalDataSource.saveCurrencies(any())).called(1);
    });

    test('should return failure when remote fetch fails during refresh',
        () async {
      // Arrange
      when(() => mockLocalDataSource.clearCurrencies())
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.getCurrencies()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/list'),
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );

      // Act
      final result = await repository.refreshCurrencies();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorHandler, isNotNull);
      verify(() => mockLocalDataSource.clearCurrencies()).called(1);
      verify(() => mockRemoteDataSource.getCurrencies()).called(1);
    });

    test('should return failure when clear cache fails', () async {
      // Arrange
      when(() => mockLocalDataSource.clearCurrencies())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.refreshCurrencies();

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorHandler, isNotNull);
    });
  });
}
