import 'package:currency_converter/core/network/api_service.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late CurrencyRemoteDataSourceImpl dataSource;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = CurrencyRemoteDataSourceImpl(mockApiService);
  });

  final tSuccessResponse = {
    'success': true,
    'currencies': {
      'USD': 'United States Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
    },
  };

  final tRequestOptions = RequestOptions(path: '/list');

  group('getCurrencies', () {
    test(
      'should return list of CurrencyModel when API call is successful',
      () async {
        // Arrange
        final response = Response<dynamic>(
          requestOptions: tRequestOptions,
          statusCode: 200,
          data: tSuccessResponse,
        );
        final httpResponse = HttpResponse(tSuccessResponse, response);

        when(
          () => mockApiService.getCurrencies(),
        ).thenAnswer((_) async => httpResponse);

        // Act
        final result = await dataSource.getCurrencies();

        // Assert
        expect(result.length, equals(3));
        expect(result.any((c) => c.code == 'USD'), isTrue);
        expect(result.any((c) => c.code == 'EUR'), isTrue);
        expect(result.any((c) => c.code == 'GBP'), isTrue);
        verify(() => mockApiService.getCurrencies()).called(1);
      },
    );

    test('should sort currencies by name', () async {
      // Arrange
      final response = Response<dynamic>(
        requestOptions: tRequestOptions,
        statusCode: 200,
        data: tSuccessResponse,
      );
      final httpResponse = HttpResponse(tSuccessResponse, response);

      when(
        () => mockApiService.getCurrencies(),
      ).thenAnswer((_) async => httpResponse);

      // Act
      final result = await dataSource.getCurrencies();

      // Assert
      expect(result[0].name, equals('British Pound'));
      expect(result[1].name, equals('Euro'));
      expect(result[2].name, equals('United States Dollar'));
    });

    test('should throw DioException when API returns success=false', () async {
      // Arrange
      final failResponse = {
        'success': false,
        'error': {'code': 101, 'info': 'Invalid API Key'},
      };
      final response = Response<dynamic>(
        requestOptions: tRequestOptions,
        statusCode: 200,
        data: failResponse,
      );
      final httpResponse = HttpResponse(failResponse, response);

      when(
        () => mockApiService.getCurrencies(),
      ).thenAnswer((_) async => httpResponse);

      // Act & Assert
      expect(
        () => dataSource.getCurrencies(),
        throwsA(isA<DioException>()),
      );
    });

    test('should throw DioException when status code is not 200', () async {
      // Arrange
      final response = Response<dynamic>(
        requestOptions: tRequestOptions,
        statusCode: 401,
        data: {'error': 'Unauthorized'},
      );
      final httpResponse = HttpResponse({'error': 'Unauthorized'}, response);

      when(
        () => mockApiService.getCurrencies(),
      ).thenAnswer((_) async => httpResponse);

      // Act & Assert
      expect(
        () => dataSource.getCurrencies(),
        throwsA(isA<DioException>()),
      );
    });

    test('should rethrow DioException from API service', () async {
      // Arrange
      when(() => mockApiService.getCurrencies()).thenThrow(
        DioException(
          requestOptions: tRequestOptions,
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getCurrencies(),
        throwsA(isA<DioException>()),
      );
    });

    test('should generate correct flag URLs for currencies', () async {
      // Arrange
      final response = Response<dynamic>(
        requestOptions: tRequestOptions,
        statusCode: 200,
        data: tSuccessResponse,
      );
      final httpResponse = HttpResponse(tSuccessResponse, response);

      when(
        () => mockApiService.getCurrencies(),
      ).thenAnswer((_) async => httpResponse);

      // Act
      final result = await dataSource.getCurrencies();

      // Assert
      final usd = result.firstWhere((c) => c.code == 'USD');
      final eur = result.firstWhere((c) => c.code == 'EUR');
      final gbp = result.firstWhere((c) => c.code == 'GBP');

      expect(usd.flagUrl, contains('us'));
      expect(eur.flagUrl, contains('eu'));
      expect(gbp.flagUrl, contains('gb'));
    });
  });
}
