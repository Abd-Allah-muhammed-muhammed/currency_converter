import 'package:currency_converter/features/currency/domain/entities/currency.dart';

/// Base class for all currency events.
sealed class CurrencyEvent {
  const CurrencyEvent();
}

/// Event to load all currencies.
final class LoadCurrencies extends CurrencyEvent {
  const LoadCurrencies();
}

/// Event to refresh currencies from the API.
final class RefreshCurrencies extends CurrencyEvent {
  const RefreshCurrencies();
}

/// Event to search/filter currencies.
final class SearchCurrencies extends CurrencyEvent {
  const SearchCurrencies(this.query);

  final String query;
}

/// Event to select a currency.
final class SelectCurrency extends CurrencyEvent {
  const SelectCurrency(this.currency);

  final Currency currency;
}
