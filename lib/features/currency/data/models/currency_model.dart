import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';

/// Currency model for data layer operations.
///
/// This model handles JSON serialization/deserialization
/// and conversion to/from the domain entity.
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.name,
    this.flagUrl,
  });

  /// Creates a [CurrencyModel] from API JSON response.
  ///
  /// The API returns currencies as a map: {"USD": "United States Dollar", ...}
  factory CurrencyModel.fromApiJson(String code, String name) {
    // Generate flag URL from currency code
    // Currency codes typically start with country code (e.g., USD -> US)
    final countryCode = _getCountryCodeFromCurrency(code);
    final flagUrl = countryCode != null
        ? 'https://flagcdn.com/w40/${countryCode.toLowerCase()}.png'
        : null;

    return CurrencyModel(
      code: code,
      name: name,
      flagUrl: flagUrl,
    );
  }

  /// Creates a [CurrencyModel] from database map.
  factory CurrencyModel.fromDatabase(Map<String, dynamic> map) {
    return CurrencyModel(
      code: map[DatabaseHelper.columnCode] as String,
      name: map[DatabaseHelper.columnName] as String,
      flagUrl: map[DatabaseHelper.columnFlagUrl] as String?,
    );
  }

  /// Creates a [CurrencyModel] from a domain entity.
  factory CurrencyModel.fromEntity(Currency entity) {
    return CurrencyModel(
      code: entity.code,
      name: entity.name,
      flagUrl: entity.flagUrl,
    );
  }

  /// The currency code (e.g., 'USD', 'EUR').
  final String code;

  /// The full name of the currency.
  final String name;

  /// The URL of the country flag image.
  final String? flagUrl;

  /// Converts the model to a database map.
  Map<String, dynamic> toDatabase() {
    return {
      DatabaseHelper.columnCode: code,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnFlagUrl: flagUrl,
    };
  }

  /// Converts the model to a domain entity.
  Currency toEntity() {
    return Currency(
      code: code,
      name: name,
      flagUrl: flagUrl,
    );
  }

  /// Maps currency codes to country codes.
  ///
  /// Most currency codes follow ISO 4217 where the first two letters
  /// represent the country code (ISO 3166-1 alpha-2).
  static String? _getCountryCodeFromCurrency(String currencyCode) {
    // Special cases where currency code doesn't match country code
    const specialMappings = {
      'EUR': 'eu', // European Union
      'XAF': 'cm', // Central African CFA franc
      'XOF': 'sn', // West African CFA franc
      'XCD': 'ag', // East Caribbean dollar
      'XPF': 'pf', // CFP franc
      'ANG': 'cw', // Netherlands Antillean guilder
      'BTC': null, // Bitcoin (no flag)
    };

    if (specialMappings.containsKey(currencyCode)) {
      return specialMappings[currencyCode];
    }

    // For most currencies, first two letters are the country code
    if (currencyCode.length >= 2) {
      return currencyCode.substring(0, 2).toLowerCase();
    }

    return null;
  }

  @override
  String toString() => 'CurrencyModel(code: $code, name: $name)';
}
