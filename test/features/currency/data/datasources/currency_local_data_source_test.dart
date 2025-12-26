import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:currency_converter/features/currency/data/models/currency_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late CurrencyLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    dataSource = CurrencyLocalDataSourceImpl(mockDatabaseHelper);
  });

  final tCurrencyMaps = [
    {
      DatabaseHelper.columnCode: 'USD',
      DatabaseHelper.columnName: 'US Dollar',
      DatabaseHelper.columnFlagUrl: 'https://flagcdn.com/w40/us.png',
    },
    {
      DatabaseHelper.columnCode: 'EUR',
      DatabaseHelper.columnName: 'Euro',
      DatabaseHelper.columnFlagUrl: 'https://flagcdn.com/w40/eu.png',
    },
  ];

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

  group('getCurrencies', () {
    test('should return list of CurrencyModel from database', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.getCurrencies(),
      ).thenAnswer((_) async => tCurrencyMaps);

      // Act
      final result = await dataSource.getCurrencies();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].code, equals('USD'));
      expect(result[1].code, equals('EUR'));
      verify(() => mockDatabaseHelper.getCurrencies()).called(1);
    });

    test('should return empty list when database is empty', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.getCurrencies(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await dataSource.getCurrencies();

      // Assert
      expect(result, isEmpty);
      verify(() => mockDatabaseHelper.getCurrencies()).called(1);
    });
  });

  group('getCurrencyByCode', () {
    test('should return CurrencyModel when currency exists', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.getCurrencyByCode('USD'),
      ).thenAnswer((_) async => tCurrencyMaps[0]);

      // Act
      final result = await dataSource.getCurrencyByCode('USD');

      // Assert
      expect(result, isNotNull);
      expect(result!.code, equals('USD'));
      expect(result.name, equals('US Dollar'));
      verify(() => mockDatabaseHelper.getCurrencyByCode('USD')).called(1);
    });

    test('should return null when currency does not exist', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.getCurrencyByCode('XYZ'),
      ).thenAnswer((_) async => null);

      // Act
      final result = await dataSource.getCurrencyByCode('XYZ');

      // Assert
      expect(result, isNull);
      verify(() => mockDatabaseHelper.getCurrencyByCode('XYZ')).called(1);
    });
  });

  group('saveCurrencies', () {
    test('should call insertCurrencies on database helper', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.insertCurrencies(any()),
      ).thenAnswer((_) async {});

      // Act
      await dataSource.saveCurrencies(tCurrencyModels);

      // Assert
      verify(() => mockDatabaseHelper.insertCurrencies(any())).called(1);
    });
  });

  group('hasCurrencies', () {
    test('should return true when currencies exist', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.hasCurrencies(),
      ).thenAnswer((_) async => true);

      // Act
      final result = await dataSource.hasCurrencies();

      // Assert
      expect(result, isTrue);
      verify(() => mockDatabaseHelper.hasCurrencies()).called(1);
    });

    test('should return false when no currencies exist', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.hasCurrencies(),
      ).thenAnswer((_) async => false);

      // Act
      final result = await dataSource.hasCurrencies();

      // Assert
      expect(result, isFalse);
      verify(() => mockDatabaseHelper.hasCurrencies()).called(1);
    });
  });

  group('clearCurrencies', () {
    test('should call deleteAllCurrencies on database helper', () async {
      // Arrange
      when(
        () => mockDatabaseHelper.deleteAllCurrencies(),
      ).thenAnswer((_) async => 0);

      // Act
      await dataSource.clearCurrencies();

      // Assert
      verify(() => mockDatabaseHelper.deleteAllCurrencies()).called(1);
    });
  });
}
