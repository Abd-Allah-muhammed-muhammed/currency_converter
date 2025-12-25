import 'package:currency_converter/core/network/api_service.dart';
import 'package:currency_converter/features/home/data/datasources/conversion_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

/// Mock implementation of ApiService for testing.
class MockApiService implements ApiService {
  MockApiService({this.responseData, this.statusCode = 200, this.exception});

  Map<String, dynamic>? responseData;
  int statusCode;
  Exception? exception;
  final List<({String from, String to, double amount, String accessKey})>
  convertCalls = [];

  @override
  Future<HttpResponse<dynamic>> convert(
    String from,
    String to,
    double amount,
    String accessKey,
  ) async {
    convertCalls.add((
      from: from,
      to: to,
      amount: amount,
      accessKey: accessKey,
    ));

    if (exception != null) {
      throw exception!;
    }

    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/convert'),
      statusCode: statusCode,
      data: responseData,
    );

    return HttpResponse(responseData, response);
  }

  @override
  Future<HttpResponse<dynamic>> getCurrencies() async {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse<dynamic>> getLiveRates(
    String source,
    String currencies,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse<dynamic>> getTimeframe(
    String accessKey,
    String source,
    String currencies,
    String startDate,
    String endDate,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  group('ConversionRemoteDataSourceImpl', () {
    late ConversionRemoteDataSourceImpl dataSource;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      dataSource = ConversionRemoteDataSourceImpl(mockApiService);
    });

    group('convert', () {
      test('should call API service with correct parameters', () async {
        // Arrange
        mockApiService.responseData = {
          'success': true,
          'query': {'from': 'USD', 'to': 'EUR', 'amount': 100},
          'info': {'timestamp': 1735128000, 'quote': 0.92},
          'result': 92.0,
        };

        // Act
        await dataSource.convert(from: 'USD', to: 'EUR', amount: 100);

        // Assert
        expect(mockApiService.convertCalls.length, 1);
        expect(mockApiService.convertCalls.first.from, 'USD');
        expect(mockApiService.convertCalls.first.to, 'EUR');
        expect(mockApiService.convertCalls.first.amount, 100);
        expect(mockApiService.convertCalls.first.accessKey, isNotEmpty);
      });

      test(
        'should return ConversionResultModel on successful response',
        () async {
          // Arrange
          mockApiService.responseData = {
            'success': true,
            'query': {'from': 'CAD', 'to': 'EUR', 'amount': 1000},
            'info': {'timestamp': 1766664244, 'quote': 0.620998},
            'result': 620.998,
          };

          // Act
          final result = await dataSource.convert(
            from: 'CAD',
            to: 'EUR',
            amount: 1000,
          );

          // Assert
          expect(result.success, true);
          expect(result.fromCurrency, 'CAD');
          expect(result.toCurrency, 'EUR');
          expect(result.amount, 1000);
          expect(result.quote, 0.620998);
          expect(result.result, 620.998);
          expect(result.timestamp, 1766664244);
        },
      );

      test(
        'should throw DioException when API returns success: false',
        () async {
          // Arrange
          mockApiService.responseData = {
            'success': false,
            'error': {
              'code': 104,
              'info': 'Your monthly usage limit has been reached.',
            },
          };

          // Act & Assert
          expect(
            () => dataSource.convert(from: 'USD', to: 'EUR', amount: 100),
            throwsA(
              isA<DioException>().having(
                (e) => e.message,
                'message',
                'Your monthly usage limit has been reached.',
              ),
            ),
          );
        },
      );

      test(
        'should throw DioException with default message when error info is missing',
        () async {
          // Arrange
          mockApiService.responseData = {'success': false};

          // Act & Assert
          expect(
            () => dataSource.convert(from: 'USD', to: 'EUR', amount: 100),
            throwsA(
              isA<DioException>().having(
                (e) => e.message,
                'message',
                'API returned unsuccessful response',
              ),
            ),
          );
        },
      );

      test('should throw DioException when status code is not 200', () async {
        // Arrange
        mockApiService.statusCode = 500;
        mockApiService.responseData = {'error': 'Internal server error'};

        // Act & Assert
        expect(
          () => dataSource.convert(from: 'USD', to: 'EUR', amount: 100),
          throwsA(
            isA<DioException>().having(
              (e) => e.message,
              'message',
              contains('Failed to convert currency: 500'),
            ),
          ),
        );
      });

      test('should rethrow DioException from API service', () async {
        // Arrange
        mockApiService.exception = DioException(
          requestOptions: RequestOptions(path: '/convert'),
          message: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        );

        // Act & Assert
        expect(
          () => dataSource.convert(from: 'USD', to: 'EUR', amount: 100),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.connectionTimeout,
            ),
          ),
        );
      });

      test('should wrap unexpected exceptions in DioException', () async {
        // Arrange
        mockApiService.exception = FormatException('Invalid JSON');

        // Act & Assert
        expect(
          () => dataSource.convert(from: 'USD', to: 'EUR', amount: 100),
          throwsA(
            isA<DioException>().having(
              (e) => e.message,
              'message',
              contains('Unexpected error'),
            ),
          ),
        );
      });

      test('should handle various currency pairs', () async {
        // Arrange
        mockApiService.responseData = {
          'success': true,
          'query': {'from': 'GBP', 'to': 'JPY', 'amount': 500},
          'info': {'timestamp': 1735128000, 'quote': 189.5},
          'result': 94750.0,
        };

        // Act
        final result = await dataSource.convert(
          from: 'GBP',
          to: 'JPY',
          amount: 500,
        );

        // Assert
        expect(result.fromCurrency, 'GBP');
        expect(result.toCurrency, 'JPY');
        expect(result.quote, 189.5);
        expect(result.result, 94750.0);
      });

      test('should handle decimal amounts correctly', () async {
        // Arrange
        mockApiService.responseData = {
          'success': true,
          'query': {'from': 'EUR', 'to': 'USD', 'amount': 123.45},
          'info': {'timestamp': 1735128000, 'quote': 1.08},
          'result': 133.326,
        };

        // Act
        final result = await dataSource.convert(
          from: 'EUR',
          to: 'USD',
          amount: 123.45,
        );

        // Assert
        expect(result.amount, 123.45);
        expect(result.result, 133.326);
      });
    });
  });
}
