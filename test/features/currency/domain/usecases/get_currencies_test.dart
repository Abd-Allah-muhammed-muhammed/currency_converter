import 'package:currency_converter/core/network/errors/api_error_handler.dart';
import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/currency/domain/usecases/get_currencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late GetCurrencies useCase;
  late MockCurrencyRepository mockRepository;

  setUp(() {
    mockRepository = MockCurrencyRepository();
    useCase = GetCurrencies(mockRepository);
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
  ];

  group('GetCurrencies', () {
    test('should get list of currencies from repository', () async {
      // Arrange
      when(
        () => mockRepository.getCurrencies(),
      ).thenAnswer((_) async => ApiResult.success(tCurrencies));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tCurrencies));
      verify(() => mockRepository.getCurrencies()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getCurrencies()).thenAnswer(
        (_) async => ApiResult.failure(
          ErrorHandler.handle(Exception('Test error')),
        ),
      );

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.errorHandler, isNotNull);
      verify(() => mockRepository.getCurrencies()).called(1);
    });

    test('should use NoParams as parameter', () async {
      // Arrange
      when(
        () => mockRepository.getCurrencies(),
      ).thenAnswer((_) async => ApiResult.success(tCurrencies));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(const NoParams(), equals(const NoParams()));
    });
  });
}
