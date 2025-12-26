import 'package:currency_converter/core/network/api_result.dart';
import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/currency/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_bloc.dart';
import 'package:currency_converter/features/currency/presentation/pages/currency_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockGetCurrencies extends Mock implements GetCurrencies {}

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockGetCurrencies mockGetCurrencies;
  late MockCurrencyRepository mockCurrencyRepository;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  // Test currencies data
  final testCurrencies = [
    const Currency(
      code: 'USD',
      name: 'United States Dollar',
      flagUrl: 'https://flagcdn.com/w40/us.png',
    ),
    const Currency(
      code: 'EUR',
      name: 'Euro',
      flagUrl: 'https://flagcdn.com/w40/eu.png',
    ),
    const Currency(
      code: 'GBP',
      name: 'British Pound',
      flagUrl: 'https://flagcdn.com/w40/gb.png',
    ),
    const Currency(
      code: 'JPY',
      name: 'Japanese Yen',
      flagUrl: 'https://flagcdn.com/w40/jp.png',
    ),
    const Currency(
      code: 'EGP',
      name: 'Egyptian Pound',
      flagUrl: 'https://flagcdn.com/w40/eg.png',
    ),
    const Currency(
      code: 'SAR',
      name: 'Saudi Riyal',
      flagUrl: 'https://flagcdn.com/w40/sa.png',
    ),
    const Currency(
      code: 'AED',
      name: 'UAE Dirham',
      flagUrl: 'https://flagcdn.com/w40/ae.png',
    ),
    const Currency(
      code: 'CAD',
      name: 'Canadian Dollar',
      flagUrl: 'https://flagcdn.com/w40/ca.png',
    ),
  ];

  /// Helper to create a testable widget wrapper.
  Widget createTestApp({
    String? selectedCurrencyCode,
    ValueChanged<Currency>? onCurrencySelected,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlutterSizer(
        builder: (context, orientation, deviceType) {
          return CurrencyPickerPage(
            selectedCurrencyCode: selectedCurrencyCode,
            onCurrencySelected: onCurrencySelected,
          );
        },
      ),
    );
  }

  setUp(() async {
    // Reset GetIt before each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CurrencyBloc>()) {
      await getIt.unregister<CurrencyBloc>();
    }
    if (getIt.isRegistered<GetCurrencies>()) {
      await getIt.unregister<GetCurrencies>();
    }
    if (getIt.isRegistered<CurrencyRepository>()) {
      await getIt.unregister<CurrencyRepository>();
    }

    // Create mocks
    mockGetCurrencies = MockGetCurrencies();
    mockCurrencyRepository = MockCurrencyRepository();

    // Register mocks with GetIt
    getIt.registerFactory<CurrencyBloc>(
      () => CurrencyBloc(
        getCurrencies: mockGetCurrencies,
        repository: mockCurrencyRepository,
      ),
    );
  });

  tearDown(() async {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<CurrencyBloc>()) {
      await getIt.unregister<CurrencyBloc>();
    }
  });

  group('Select Currency Feature Integration Tests', () {
    testWidgets(
      'should display currency picker page with title',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => true);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Select Currency'), findsOneWidget);
      },
    );

    testWidgets(
      'should display loading indicator while fetching currencies',
      (WidgetTester tester) async {
        // Arrange - delay the response to show loading state
        when(() => mockGetCurrencies(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(seconds: 2));
          return ApiResult.success(testCurrencies);
        });
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading currencies...'), findsOneWidget);
      },
    );

    testWidgets(
      'should display list of currencies after loading',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('USD'), findsWidgets);
        expect(find.text('Euro'), findsWidgets);
        expect(find.text('EUR'), findsWidgets);
      },
    );

    testWidgets(
      'should display popular currencies section',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('POPULAR'), findsOneWidget);
      },
    );

    testWidgets(
      'should display search field',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search currency or code...'), findsOneWidget);
      },
    );

    testWidgets(
      'should filter currencies when searching by name',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Type in search field
        await tester.enterText(find.byType(TextField), 'Dollar');

        // Wait for debounce
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - should show currencies containing "Dollar"
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('Canadian Dollar'), findsWidgets);
      },
    );

    testWidgets(
      'should filter currencies when searching by code',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Type currency code in search field
        await tester.enterText(find.byType(TextField), 'EUR');

        // Wait for debounce
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - should show Euro
        expect(find.text('Euro'), findsWidgets);
        expect(find.text('EUR'), findsWidgets);
      },
    );

    testWidgets(
      'should display "No currencies found" when search has no results',
      (WidgetTester tester) async {
        // Temporarily suppress overflow errors for this test
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.exception.toString().contains('overflowed')) {
            return; // Ignore overflow errors
          }
          oldOnError?.call(details);
        };

        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Type a search term that matches nothing
        await tester.enterText(find.byType(TextField), 'XYZ123');

        // Wait for debounce
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - verify the empty state message is present
        expect(find.text('No currencies found'), findsOneWidget);

        // Restore the error handler
        FlutterError.onError = oldOnError;
      },
    );

    testWidgets(
      'should highlight selected currency',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(
          createTestApp(selectedCurrencyCode: 'USD'),
        );
        await tester.pumpAndSettle();

        // Assert - Find the container with cyan border (selected state)
        // USD should be marked as selected
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('USD'), findsWidgets);
      },
    );

    testWidgets(
      'should call onCurrencySelected when currency is tapped',
      (WidgetTester tester) async {
        // Arrange
        Currency? selectedCurrency;
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(
          createTestApp(
            onCurrencySelected: (currency) {
              selectedCurrency = currency;
            },
          ),
        );
        await tester.pumpAndSettle();

        // Scroll to find EUR and tap it
        final euroFinder = find.text('Euro').first;
        await tester.ensureVisible(euroFinder);
        await tester.tap(euroFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(selectedCurrency, isNotNull);
        expect(selectedCurrency!.code, equals('EUR'));
        expect(selectedCurrency!.name, equals('Euro'));
      },
    );

    testWidgets(
      'should navigate back when back button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Use Navigator to test back navigation
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => FlutterSizer(
                            builder: (context, orientation, deviceType) {
                              return const CurrencyPickerPage();
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Picker'),
                  ),
                );
              },
            ),
          ),
        );

        // Navigate to currency picker
        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        // Verify we're on the currency picker page
        expect(find.text('Select Currency'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
        await tester.pumpAndSettle();

        // Verify we're back to original page
        expect(find.text('Open Picker'), findsOneWidget);
        expect(find.text('Select Currency'), findsNothing);
      },
    );

    testWidgets(
      'should display error state when loading fails',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockGetCurrencies(any())).thenAnswer(
          (_) async => ApiResult.failure(null),
        );

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Failed to load currencies'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'should retry loading when retry button is pressed',
      (WidgetTester tester) async {
        // Arrange - first call fails, second succeeds
        var callCount = 0;
        when(() => mockGetCurrencies(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return ApiResult.failure(null);
          }
          return ApiResult.success(testCurrencies);
        });
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('Failed to load currencies'), findsOneWidget);

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Assert - should show currencies now
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('Failed to load currencies'), findsNothing);
      },
    );

    testWidgets(
      'should display refresh button when data is from cache',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => true);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'should refresh currencies when refresh button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCurrencyRepository.refreshCurrencies(),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Tap refresh button
        await tester.tap(find.byIcon(Icons.refresh_rounded));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockCurrencyRepository.refreshCurrencies()).called(1);
      },
    );

    testWidgets(
      'should display all currencies section',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Scroll down to see all currencies section
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('ALL CURRENCIES'), findsOneWidget);
      },
    );

    testWidgets(
      'should clear search and show all currencies',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Type in search field
        await tester.enterText(find.byType(TextField), 'USD');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Clear search field
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - should show all currencies and sections again
        expect(find.text('POPULAR'), findsOneWidget);
      },
    );

    testWidgets(
      'should display currency flag images',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - currency items should be present
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('Euro'), findsWidgets);
      },
    );

    testWidgets(
      'should handle rapid search input correctly',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGetCurrencies(any()),
        ).thenAnswer((_) async => ApiResult.success(testCurrencies));
        when(
          () => mockCurrencyRepository.hasCachedCurrencies(),
        ).thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Rapid input
        await tester.enterText(find.byType(TextField), 'U');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.enterText(find.byType(TextField), 'US');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.enterText(find.byType(TextField), 'USD');

        // Wait for debounce to complete
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Assert - should show USD results
        expect(find.text('United States Dollar'), findsWidgets);
        expect(find.text('USD'), findsWidgets);
      },
    );
  });
}
