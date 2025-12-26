import 'package:currency_converter/features/home/data/models/conversion_result_model.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversionResultModel', () {
    group('fromJson', () {
      test('should correctly parse a valid API response', () {
        // Arrange
        final json = {
          'success': true,
          'terms': 'https://currencylayer.com/terms',
          'privacy': 'https://currencylayer.com/privacy',
          'query': {'from': 'CAD', 'to': 'EUR', 'amount': 1000},
          'info': {'timestamp': 1766664244, 'quote': 0.620998},
          'result': 620.998,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.success, true);
        expect(model.fromCurrency, 'CAD');
        expect(model.toCurrency, 'EUR');
        expect(model.amount, 1000.0);
        expect(model.quote, 0.620998);
        expect(model.result, 620.998);
        expect(model.timestamp, 1766664244);
      });

      test('should handle integer amount correctly', () {
        // Arrange
        final json = {
          'success': true,
          'query': {'from': 'USD', 'to': 'GBP', 'amount': 500},
          'info': {'timestamp': 1766664244, 'quote': 0.79},
          'result': 395.0,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.amount, 500.0);
        expect(model.quote, 0.79);
        expect(model.result, 395.0);
      });

      test('should handle decimal amount correctly', () {
        // Arrange
        final json = {
          'success': true,
          'query': {'from': 'EUR', 'to': 'JPY', 'amount': 123.45},
          'info': {'timestamp': 1766664244, 'quote': 162.50},
          'result': 20060.625,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.amount, 123.45);
        expect(model.quote, 162.50);
        expect(model.result, 20060.625);
      });

      test('should default success to false when not present', () {
        // Arrange
        final json = {
          'query': {'from': 'USD', 'to': 'EUR', 'amount': 100},
          'info': {'timestamp': 1766664244, 'quote': 0.92},
          'result': 92.0,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.success, false);
      });

      test('should handle very small quote values', () {
        // Arrange
        final json = {
          'success': true,
          'query': {'from': 'BTC', 'to': 'USD', 'amount': 0.001},
          'info': {'timestamp': 1766664244, 'quote': 42000.0},
          'result': 42.0,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.amount, 0.001);
        expect(model.quote, 42000.0);
        expect(model.result, 42.0);
      });

      test('should handle very large amount values', () {
        // Arrange
        final json = {
          'success': true,
          'query': {'from': 'USD', 'to': 'EUR', 'amount': 1000000000},
          'info': {'timestamp': 1766664244, 'quote': 0.92},
          'result': 920000000.0,
        };

        // Act
        final model = ConversionResultModel.fromJson(json);

        // Assert
        expect(model.amount, 1000000000.0);
        expect(model.result, 920000000.0);
      });
    });

    group('toEntity', () {
      test('should correctly convert to ConversionResult entity', () {
        // Arrange
        const model = ConversionResultModel(
          success: true,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92,
          timestamp: 1735128000, // 2024-12-25 12:00:00 UTC
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ConversionResult>());
        expect(entity.fromCurrency, 'USD');
        expect(entity.toCurrency, 'EUR');
        expect(entity.amount, 100.0);
        expect(entity.quote, 0.92);
        expect(entity.result, 92.0);
        expect(
          entity.timestamp,
          DateTime.fromMillisecondsSinceEpoch(1735128000 * 1000),
        );
      });

      test('should correctly convert Unix timestamp to DateTime', () {
        // Arrange - Unix timestamp for 2025-12-25 14:30:00 UTC
        const timestamp = 1766764200;
        const model = ConversionResultModel(
          success: true,
          fromCurrency: 'CAD',
          toCurrency: 'EUR',
          amount: 1000,
          quote: 0.62,
          result: 620,
          timestamp: timestamp,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        final expectedDateTime = DateTime.fromMillisecondsSinceEpoch(
          timestamp * 1000,
        );
        expect(entity.timestamp, expectedDateTime);
      });
    });

    group('toString', () {
      test('should return a readable string representation', () {
        // Arrange
        const model = ConversionResultModel(
          success: true,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          amount: 100,
          quote: 0.92,
          result: 92,
          timestamp: 1735128000,
        );

        // Act
        final result = model.toString();

        // Assert
        expect(result, contains('success: true'));
        expect(result, contains('from: USD'));
        expect(result, contains('to: EUR'));
        expect(result, contains('amount: 100.0'));
        expect(result, contains('quote: 0.92'));
        expect(result, contains('result: 92.0'));
        expect(result, contains('timestamp: 1735128000'));
      });
    });
  });
}
