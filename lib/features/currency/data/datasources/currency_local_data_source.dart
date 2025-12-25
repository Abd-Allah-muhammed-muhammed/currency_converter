import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/features/currency/data/models/currency_model.dart';
import 'package:injectable/injectable.dart';

/// Local data source for currency operations.
///
/// This class handles all SQLite database operations for currencies.
abstract class CurrencyLocalDataSource {
  /// Gets all currencies from the local database.
  Future<List<CurrencyModel>> getCurrencies();

  /// Gets a single currency by code.
  Future<CurrencyModel?> getCurrencyByCode(String code);

  /// Saves currencies to the local database.
  Future<void> saveCurrencies(List<CurrencyModel> currencies);

  /// Checks if currencies exist in the local database.
  Future<bool> hasCurrencies();

  /// Clears all currencies from the local database.
  Future<void> clearCurrencies();
}

/// Implementation of [CurrencyLocalDataSource] using SQLite.
@LazySingleton(as: CurrencyLocalDataSource)
class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  CurrencyLocalDataSourceImpl(this.databaseHelper);

  final DatabaseHelper databaseHelper;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    final maps = await databaseHelper.getCurrencies();
    return maps.map((map) => CurrencyModel.fromDatabase(map)).toList();
  }

  @override
  Future<CurrencyModel?> getCurrencyByCode(String code) async {
    final map = await databaseHelper.getCurrencyByCode(code);
    if (map == null) return null;
    return CurrencyModel.fromDatabase(map);
  }

  @override
  Future<void> saveCurrencies(List<CurrencyModel> currencies) async {
    final maps = currencies.map((c) => c.toDatabase()).toList();
    await databaseHelper.insertCurrencies(maps);
  }

  @override
  Future<bool> hasCurrencies() async {
    return await databaseHelper.hasCurrencies();
  }

  @override
  Future<void> clearCurrencies() async {
    await databaseHelper.deleteAllCurrencies();
  }
}
