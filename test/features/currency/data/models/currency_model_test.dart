import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/features/currency/data/models/currency_model.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyModel', () {
    group('fromApiJson', () {
      test('should create CurrencyModel with correct values', () {
        // Arrange
        const code = 'USD';
        const name = 'United States Dollar';

        // Act
        final model = CurrencyModel.fromApiJson(code, name);

        // Assert
        expect(model.code, equals(code));
        expect(model.name, equals(name));
        expect(model.flagUrl, isNotNull);
        expect(model.flagUrl, contains('us'));
      });

      test('should generate correct flag URL for standard currencies', () {
        // Arrange & Act
        final usdModel = CurrencyModel.fromApiJson('USD', 'US Dollar');
        final gbpModel = CurrencyModel.fromApiJson('GBP', 'British Pound');
        final egpModel = CurrencyModel.fromApiJson('EGP', 'Egyptian Pound');

        // Assert
        expect(usdModel.flagUrl, equals('https://flagcdn.com/w40/us.png'));
        expect(gbpModel.flagUrl, equals('https://flagcdn.com/w40/gb.png'));
        expect(egpModel.flagUrl, equals('https://flagcdn.com/w40/eg.png'));
      });

      test('should handle EUR special case with EU flag', () {
        // Arrange & Act
        final eurModel = CurrencyModel.fromApiJson('EUR', 'Euro');

        // Assert
        expect(eurModel.flagUrl, equals('https://flagcdn.com/w40/eu.png'));
      });

      test('should handle BTC with no flag', () {
        // Arrange & Act
        final btcModel = CurrencyModel.fromApiJson('BTC', 'Bitcoin');

        // Assert
        expect(btcModel.flagUrl, isNull);
      });
    });

    group('fromDatabase', () {
      test('should create CurrencyModel from database map', () {
        // Arrange
        final map = {
          DatabaseHelper.columnCode: 'EUR',
          DatabaseHelper.columnName: 'Euro',
          DatabaseHelper.columnFlagUrl: 'https://flagcdn.com/w40/eu.png',
        };

        // Act
        final model = CurrencyModel.fromDatabase(map);

        // Assert
        expect(model.code, equals('EUR'));
        expect(model.name, equals('Euro'));
        expect(model.flagUrl, equals('https://flagcdn.com/w40/eu.png'));
      });

      test('should handle null flagUrl from database', () {
        // Arrange
        final map = {
          DatabaseHelper.columnCode: 'BTC',
          DatabaseHelper.columnName: 'Bitcoin',
          DatabaseHelper.columnFlagUrl: null,
        };

        // Act
        final model = CurrencyModel.fromDatabase(map);

        // Assert
        expect(model.code, equals('BTC'));
        expect(model.name, equals('Bitcoin'));
        expect(model.flagUrl, isNull);
      });
    });

    group('toDatabase', () {
      test('should convert CurrencyModel to database map', () {
        // Arrange
        const model = CurrencyModel(
          code: 'GBP',
          name: 'British Pound',
          flagUrl: 'https://flagcdn.com/w40/gb.png',
        );

        // Act
        final map = model.toDatabase();

        // Assert
        expect(map[DatabaseHelper.columnCode], equals('GBP'));
        expect(map[DatabaseHelper.columnName], equals('British Pound'));
        expect(
          map[DatabaseHelper.columnFlagUrl],
          equals('https://flagcdn.com/w40/gb.png'),
        );
      });

      test('should handle null flagUrl in toDatabase', () {
        // Arrange
        const model = CurrencyModel(
          code: 'BTC',
          name: 'Bitcoin',
          flagUrl: null,
        );

        // Act
        final map = model.toDatabase();

        // Assert
        expect(map[DatabaseHelper.columnFlagUrl], isNull);
      });
    });

    group('toEntity', () {
      test('should convert CurrencyModel to Currency entity', () {
        // Arrange
        const model = CurrencyModel(
          code: 'JPY',
          name: 'Japanese Yen',
          flagUrl: 'https://flagcdn.com/w40/jp.png',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<Currency>());
        expect(entity.code, equals('JPY'));
        expect(entity.name, equals('Japanese Yen'));
        expect(entity.flagUrl, equals('https://flagcdn.com/w40/jp.png'));
      });
    });

    group('fromEntity', () {
      test('should create CurrencyModel from Currency entity', () {
        // Arrange
        const entity = Currency(
          code: 'CAD',
          name: 'Canadian Dollar',
          flagUrl: 'https://flagcdn.com/w40/ca.png',
        );

        // Act
        final model = CurrencyModel.fromEntity(entity);

        // Assert
        expect(model.code, equals('CAD'));
        expect(model.name, equals('Canadian Dollar'));
        expect(model.flagUrl, equals('https://flagcdn.com/w40/ca.png'));
      });
    });

    group('toString', () {
      test('should return correct string representation', () {
        // Arrange
        const model = CurrencyModel(
          code: 'AUD',
          name: 'Australian Dollar',
        );

        // Act
        final result = model.toString();

        // Assert
        expect(result, equals('CurrencyModel(code: AUD, name: Australian Dollar)'));
      });
    });
  });
}
