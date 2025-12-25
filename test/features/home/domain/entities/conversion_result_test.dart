import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversionResult', () {
    group('formattedRate', () {
      test('should format rate with 6 decimal places', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 1000,
          quote: 0.620998,
          result: 620.998,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedRate, '1 CAD ≈ 0.620998 EUR');
      });

      test('should handle integer quote values', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'JPY',
          amount: 100,
          quote: 150.0,
          result: 15000.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedRate, '1 USD ≈ 150.000000 JPY');
      });

      test('should handle very small quote values', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'JPY',
          toCurrency: 'USD',
          amount: 10000,
          quote: 0.006667,
          result: 66.67,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedRate, '1 JPY ≈ 0.006667 USD');
      });
    });

    group('formattedResult', () {
      test('should format result with 2 decimal places and currency', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 1000,
          quote: 0.620998,
          result: 620.998,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedResult, '621.00 EUR');
      });

      test('should round correctly', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.924567,
          result: 92.4567,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedResult, '92.46 EUR');
      });

      test('should handle large amounts', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 1000000,
          quote: 0.92,
          result: 920000.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedResult, '920000.00 EUR');
      });
    });

    group('formattedAmount', () {
      test('should format amount with 2 decimal places and currency', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 1000,
          quote: 0.62,
          result: 620.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedAmount, '1000.00 CAD');
      });

      test('should handle decimal amounts', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 123.456,
          quote: 0.92,
          result: 113.58,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result.formattedAmount, '123.46 USD');
      });
    });

    group('formattedTimestamp', () {
      test('should format timestamp as HH:mm UTC', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 14, 30),
        );

        // Act & Assert
        expect(result.formattedTimestamp, '14:30 UTC');
      });

      test('should pad single digit hours and minutes with zero', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 9, 5),
        );

        // Act & Assert
        expect(result.formattedTimestamp, '09:05 UTC');
      });

      test('should handle midnight correctly', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 0, 0),
        );

        // Act & Assert
        expect(result.formattedTimestamp, '00:00 UTC');
      });

      test('should handle end of day correctly', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 23, 59),
        );

        // Act & Assert
        expect(result.formattedTimestamp, '23:59 UTC');
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final result1 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        final result2 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal when fromCurrency differs', () {
        // Arrange
        final result1 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        final result2 = ConversionResult(
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal when amount differs', () {
        // Arrange
        final result1 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        final result2 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 200,
          quote: 0.92,
          result: 184.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal when timestamp differs', () {
        // Arrange
        final result1 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        final result2 = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 14, 0),
        );

        // Act & Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('should return a readable string representation', () {
        // Arrange
        final result = ConversionResult(
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92.0,
          timestamp: DateTime.utc(2025, 12, 25, 12, 0),
        );

        // Act
        final str = result.toString();

        // Assert
        expect(str, contains('from: USD'));
        expect(str, contains('to: EUR'));
        expect(str, contains('amount: 100'));
        expect(str, contains('quote: 0.92'));
        expect(str, contains('result: 92.0'));
      });
    });
  });
}
