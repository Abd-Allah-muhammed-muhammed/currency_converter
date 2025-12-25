import 'package:currency_converter/features/exchange_history/data/models/exchange_history_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeHistoryModel', () {
    group('fromJson', () {
      test('should correctly parse a valid API response', () {
        // Arrange
        final json = {
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-25',
          'source': 'USD',
          'quotes': {
            '2025-12-19': {'USDEUR': 0.738541},
            '2025-12-20': {'USDEUR': 0.736145},
            '2025-12-21': {'USDEUR': 0.740000},
          },
        };

        // Act
        final result = ExchangeHistoryModel.fromJson(json);

        // Assert
        expect(result.success, true);
        expect(result.timeframe, true);
        expect(result.startDate, '2025-12-19');
        expect(result.endDate, '2025-12-25');
        expect(result.source, 'USD');
        expect(result.quotes.length, 3);
        expect(result.quotes['2025-12-19']?['USDEUR'], 0.738541);
      });

      test('should handle empty quotes', () {
        // Arrange
        final json = {
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-25',
          'source': 'USD',
          'quotes': <String, dynamic>{},
        };

        // Act
        final result = ExchangeHistoryModel.fromJson(json);

        // Assert
        expect(result.quotes, isEmpty);
      });

      test('should handle missing fields with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = ExchangeHistoryModel.fromJson(json);

        // Assert
        expect(result.success, false);
        expect(result.timeframe, false);
        expect(result.startDate, '');
        expect(result.endDate, '');
        expect(result.source, '');
        expect(result.quotes, isEmpty);
      });

      test('should parse multiple currency pairs', () {
        // Arrange
        final json = {
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-20',
          'source': 'USD',
          'quotes': {
            '2025-12-19': {
              'USDEUR': 0.738541,
              'USDGBP': 0.625000,
            },
            '2025-12-20': {
              'USDEUR': 0.736145,
              'USDGBP': 0.623500,
            },
          },
        };

        // Act
        final result = ExchangeHistoryModel.fromJson(json);

        // Assert
        expect(result.quotes['2025-12-19']?['USDEUR'], 0.738541);
        expect(result.quotes['2025-12-19']?['USDGBP'], 0.625000);
        expect(result.quotes['2025-12-20']?['USDEUR'], 0.736145);
        expect(result.quotes['2025-12-20']?['USDGBP'], 0.623500);
      });
    });

    group('getRateForDate', () {
      late ExchangeHistoryModel model;

      setUp(() {
        model = ExchangeHistoryModel.fromJson({
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-21',
          'source': 'USD',
          'quotes': {
            '2025-12-19': {'USDEUR': 0.738541},
            '2025-12-20': {'USDEUR': 0.736145},
            '2025-12-21': {'USDEUR': 0.740000},
          },
        });
      });

      test('should return correct rate for existing date', () {
        expect(model.getRateForDate('2025-12-19', 'EUR'), 0.738541);
        expect(model.getRateForDate('2025-12-20', 'EUR'), 0.736145);
        expect(model.getRateForDate('2025-12-21', 'EUR'), 0.740000);
      });

      test('should return null for non-existing date', () {
        expect(model.getRateForDate('2025-12-22', 'EUR'), isNull);
      });

      test('should return null for non-existing currency', () {
        expect(model.getRateForDate('2025-12-19', 'GBP'), isNull);
      });
    });

    group('getRatesForCurrency', () {
      test('should return sorted list of rate points', () {
        // Arrange
        final model = ExchangeHistoryModel.fromJson({
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-21',
          'source': 'USD',
          'quotes': {
            '2025-12-21': {'USDEUR': 0.740000},
            '2025-12-19': {'USDEUR': 0.738541},
            '2025-12-20': {'USDEUR': 0.736145},
          },
        });

        // Act
        final rates = model.getRatesForCurrency('EUR');

        // Assert
        expect(rates.length, 3);
        // Should be sorted by date ascending
        expect(rates[0].date, DateTime(2025, 12, 19));
        expect(rates[0].rate, 0.738541);
        expect(rates[1].date, DateTime(2025, 12, 20));
        expect(rates[1].rate, 0.736145);
        expect(rates[2].date, DateTime(2025, 12, 21));
        expect(rates[2].rate, 0.740000);
      });

      test('should return empty list for non-existing currency', () {
        // Arrange
        final model = ExchangeHistoryModel.fromJson({
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-21',
          'source': 'USD',
          'quotes': {
            '2025-12-19': {'USDEUR': 0.738541},
          },
        });

        // Act
        final rates = model.getRatesForCurrency('GBP');

        // Assert
        expect(rates, isEmpty);
      });

      test('should skip invalid dates', () {
        // Arrange
        final model = ExchangeHistoryModel.fromJson({
          'success': true,
          'timeframe': true,
          'start_date': '2025-12-19',
          'end_date': '2025-12-21',
          'source': 'USD',
          'quotes': {
            '2025-12-19': {'USDEUR': 0.738541},
            'invalid-date': {'USDEUR': 0.736145},
            '2025-12-21': {'USDEUR': 0.740000},
          },
        });

        // Act
        final rates = model.getRatesForCurrency('EUR');

        // Assert
        expect(rates.length, 2);
      });
    });
  });

  group('ExchangeRatePoint', () {
    test('should create with correct values', () {
      final point = ExchangeRatePoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      expect(point.date, DateTime(2025, 12, 19));
      expect(point.rate, 0.738541);
    });

    test('toString should return readable format', () {
      final point = ExchangeRatePoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      expect(point.toString(), contains('ExchangeRatePoint'));
      expect(point.toString(), contains('0.738541'));
    });
  });
}
