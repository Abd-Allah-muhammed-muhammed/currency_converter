import 'package:currency_converter/features/exchange_history/domain/entities/exchange_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeHistory', () {
    group('latestRate', () {
      test('should return last rate when rates exist', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.736145),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.740000),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.latestRate, 0.740000);
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.latestRate, isNull);
      });
    });

    group('firstRate', () {
      test('should return first rate when rates exist', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.736145),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.740000),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.firstRate, 0.738541);
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.firstRate, isNull);
      });
    });

    group('highRate', () {
      test('should return highest rate', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.750000), // Highest
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.740000),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.highRate, 0.750000);
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.highRate, isNull);
      });

      test('should work with single rate', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 19),
        );

        expect(history.highRate, 0.738541);
      });
    });

    group('lowRate', () {
      test('should return lowest rate', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.720000), // Lowest
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.740000),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.lowRate, 0.720000);
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.lowRate, isNull);
      });
    });

    group('averageRate', () {
      test('should return correct average', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.70),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.80),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.90),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        // Use closeTo matcher for floating point comparison
        expect(history.averageRate, closeTo(0.80, 0.0001)); // (0.70 + 0.80 + 0.90) / 3
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.averageRate, isNull);
      });

      test('should work with single rate', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 19),
        );

        expect(history.averageRate, 0.738541);
      });
    });

    group('changePercentage', () {
      test('should calculate positive change correctly', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 1.05),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 1.10),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        // ((1.10 - 1.0) / 1.0) * 100 = 10%
        expect(history.changePercentage, closeTo(10.0, 0.001));
      });

      test('should calculate negative change correctly', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 20), rate: 0.95),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.90),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        // ((0.90 - 1.0) / 1.0) * 100 = -10%
        expect(history.changePercentage, closeTo(-10.0, 0.001));
      });

      test('should return null when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.changePercentage, isNull);
      });

      test('should return null when first rate is zero', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.0),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 1.0),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.changePercentage, isNull);
      });

      test('should return zero when no change', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 1.0),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.changePercentage, 0.0);
      });
    });

    group('isPositiveChange', () {
      test('should return true for positive change', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 1.10),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.isPositiveChange, true);
      });

      test('should return false for negative change', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 0.90),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.isPositiveChange, false);
      });

      test('should return true for zero change', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 1.0),
            RateDataPoint(date: DateTime(2025, 12, 21), rate: 1.0),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.isPositiveChange, true);
      });

      test('should return false when rates are empty', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history.isPositiveChange, false);
      });
    });

    group('equality', () {
      test('should be equal for same currency pair and dates', () {
        final history1 = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.9)],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        final history2 = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.8)],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history1, equals(history2));
      });

      test('should not be equal for different currency pairs', () {
        final history1 = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        final history2 = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'GBP',
          rates: [],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        expect(history1, isNot(equals(history2)));
      });
    });

    group('toString', () {
      test('should return readable format', () {
        final history = ExchangeHistory(
          sourceCurrency: 'USD',
          targetCurrency: 'EUR',
          rates: [
            RateDataPoint(date: DateTime(2025, 12, 19), rate: 0.738541),
          ],
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2025, 12, 21),
        );

        final str = history.toString();
        expect(str, contains('ExchangeHistory'));
        expect(str, contains('USD'));
        expect(str, contains('EUR'));
        expect(str, contains('1 points'));
      });
    });
  });

  group('RateDataPoint', () {
    test('should create with correct values', () {
      final point = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      expect(point.date, DateTime(2025, 12, 19));
      expect(point.rate, 0.738541);
    });

    test('should be equal for same date and rate', () {
      final point1 = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      final point2 = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      expect(point1, equals(point2));
    });

    test('should not be equal for different dates', () {
      final point1 = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      final point2 = RateDataPoint(
        date: DateTime(2025, 12, 20),
        rate: 0.738541,
      );

      expect(point1, isNot(equals(point2)));
    });

    test('should not be equal for different rates', () {
      final point1 = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      final point2 = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.740000,
      );

      expect(point1, isNot(equals(point2)));
    });

    test('toString should return readable format', () {
      final point = RateDataPoint(
        date: DateTime(2025, 12, 19),
        rate: 0.738541,
      );

      expect(point.toString(), contains('RateDataPoint'));
      expect(point.toString(), contains('0.738541'));
    });
  });
}
