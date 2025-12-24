import 'package:currency_converter/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:currency_converter/core/database/database_helper.dart';
import 'package:currency_converter/core/network/dio_factory.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:currency_converter/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:currency_converter/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/currency/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_bloc.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initializes all dependencies.
///
/// This should be called before running the app.
Future<void> initDependencies() async {
  // ============ Core ============

  // Database
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Network
  sl.registerLazySingleton<Dio>(() => DioFactory.getDio());
  //ApiService
  sl.registerLazySingleton<ApiService>(() => ApiService(sl<Dio>()));


  // ============ Currency Feature ============
  await _initCurrencyFeature();
}

/// Initializes currency feature dependencies.
Future<void> _initCurrencyFeature() async {
  // Data Sources
  sl.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(sl<DatabaseHelper>()),
  );

  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(sl<ApiService>()),
  );

  // Repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      localDataSource: sl<CurrencyLocalDataSource>(),
      remoteDataSource: sl<CurrencyRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetCurrencies>(
    () => GetCurrencies(sl<CurrencyRepository>()),
  );

  // Bloc - Factory so each screen gets its own instance
  sl.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(
      getCurrencies: sl<GetCurrencies>(),
      repository: sl<CurrencyRepository>(),
    ),
  );
}

/// Resets all dependencies.
///
/// Useful for testing.
Future<void> resetDependencies() async {
  await sl.reset();
}
