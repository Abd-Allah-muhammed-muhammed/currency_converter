import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/core/network/api_service.dart';
import 'package:currency_converter/core/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Module for registering external dependencies that cannot be annotated
/// directly.
@module
abstract class RegisterModule {
  /// Provides the DatabaseHelper singleton.
  @lazySingleton
  DatabaseHelper get databaseHelper => DatabaseHelper.instance;

  /// Provides the Dio HTTP client.
  @lazySingleton
  Dio get dio => DioFactory.getDio();

  /// Provides the API service.
  @lazySingleton
  ApiService apiService(Dio dio) => ApiService(dio);

  /// Provides SharedPreferences instance.
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
