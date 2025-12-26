import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing user preferences using SharedPreferences.
///
/// Handles caching of user settings like last selected currencies,
/// preferred theme, and other app preferences.
@lazySingleton
class PreferencesRepository {
  PreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  // Keys for shared preferences
  static const String _keyLastFromCurrency = 'last_from_currency';
  static const String _keyLastToCurrency = 'last_to_currency';
  static const String _keyLastAmount = 'last_amount';
  static const String _keyFirstLaunch = 'first_launch';

  /// Saves the last selected currencies for quick restoration.
  Future<bool> saveLastCurrencies({
    required String from,
    required String to,
  }) async {
    final fromResult = await _prefs.setString(_keyLastFromCurrency, from);
    final toResult = await _prefs.setString(_keyLastToCurrency, to);
    return fromResult && toResult;
  }

  /// Gets the last selected currencies.
  ///
  /// Returns null if no currencies have been saved before.
  ({String from, String to})? getLastCurrencies() {
    final from = _prefs.getString(_keyLastFromCurrency);
    final to = _prefs.getString(_keyLastToCurrency);

    if (from == null || to == null) return null;

    return (from: from, to: to);
  }

  /// Saves the last entered amount.
  Future<bool> saveLastAmount(double amount) async {
    return _prefs.setDouble(_keyLastAmount, amount);
  }

  /// Gets the last entered amount.
  ///
  /// Returns null if no amount has been saved before.
  double? getLastAmount() {
    return _prefs.getDouble(_keyLastAmount);
  }

  /// Checks if this is the first app launch.
  bool isFirstLaunch() {
    return _prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Marks that the app has been launched.
  Future<bool> setFirstLaunchComplete() async {
    return _prefs.setBool(_keyFirstLaunch, false);
  }

  /// Clears all saved preferences.
  Future<bool> clearAll() async {
    return _prefs.clear();
  }

  /// Clears only conversion-related preferences.
  Future<void> clearConversionPreferences() async {
    await _prefs.remove(_keyLastFromCurrency);
    await _prefs.remove(_keyLastToCurrency);
    await _prefs.remove(_keyLastAmount);
  }
}
