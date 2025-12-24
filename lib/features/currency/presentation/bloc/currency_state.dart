import 'package:currency_converter/features/currency/domain/entities/currency.dart';

/// Base class for all currency states.
sealed class CurrencyState {
  const CurrencyState();
}

/// Initial state before any action is taken.
final class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

/// State when currencies are being loaded.
final class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

/// State when currencies are successfully loaded.
final class CurrencyLoaded extends CurrencyState {
  const CurrencyLoaded({
    required this.currencies,
    required this.popularCurrencies,
    this.filteredCurrencies,
    this.searchQuery = '',
    this.isFromCache = false,
  });

  /// All available currencies.
  final List<Currency> currencies;

  /// Popular currencies (USD, EUR, GBP, etc.).
  final List<Currency> popularCurrencies;

  /// Filtered currencies based on search query.
  final List<Currency>? filteredCurrencies;

  /// The current search query.
  final String searchQuery;

  /// Whether the data was loaded from cache.
  final bool isFromCache;

  /// Returns the currencies to display (filtered or all).
  List<Currency> get displayCurrencies =>
      searchQuery.isEmpty ? currencies : (filteredCurrencies ?? currencies);

  /// Creates a copy of this state with the given fields replaced.
  CurrencyLoaded copyWith({
    List<Currency>? currencies,
    List<Currency>? popularCurrencies,
    List<Currency>? filteredCurrencies,
    String? searchQuery,
    bool? isFromCache,
  }) {
    return CurrencyLoaded(
      currencies: currencies ?? this.currencies,
      popularCurrencies: popularCurrencies ?? this.popularCurrencies,
      filteredCurrencies: filteredCurrencies ?? this.filteredCurrencies,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// State when there's an error loading currencies.
final class CurrencyError extends CurrencyState {
  const CurrencyError(this.message);

  final String message;
}
