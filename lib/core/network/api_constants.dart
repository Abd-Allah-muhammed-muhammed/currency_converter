/// API constants for ExchangeRate.host API.
///
/// Documentation: https://exchangerate.host/documentation
class ApiConstants {
  ApiConstants._();

  /// Base URL for ExchangeRate.host API.
  static const String apiBaseUrl = 'https://api.exchangerate.host';

  /// API key for ExchangeRate.host (free tier).
  static const String apiKey = 'efa7058332c03a3c8d3598dad0bbdf17';

  // ============ Endpoints ============

  /// Get list of supported currencies.
  /// Response: {"success": true, "currencies": {"USD": "United States Dollar", ...}}
  static const String currenciesList = '/list';

  /// Convert currency.
  /// Query params: from, to, amount
  /// Example: /convert?from=EUR&to=GBP&amount=100
  static const String convert = '/convert';

  /// Get live exchange rates.
  /// Query params: source, currencies
  /// Example: /live?source=USD&currencies=EUR,GBP
  static const String liveRates = '/live';

  /// Get historical rates for a specific date.
  /// Query params: date (YYYY-MM-DD), base, symbols
  /// Example: /historical?date=2024-01-01
  static const String historical = '/historical';

  /// Get rates for a time period.
  /// Query params: start_date, end_date, base, symbols
  /// Example: /timeframe?start_date=2024-01-01&end_date=2024-01-07&base=USD&symbols=EUR
  static const String timeframe = '/timeframe';
}