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
import 'package:currency_converter/features/exchange_history/data/datasources/exchange_history_remote_data_source.dart';
import 'package:currency_converter/features/exchange_history/data/repositories/exchange_history_repository_impl.dart';
import 'package:currency_converter/features/exchange_history/domain/repositories/exchange_history_repository.dart';
import 'package:currency_converter/features/exchange_history/domain/usecases/get_exchange_history.dart';
import 'package:currency_converter/features/exchange_history/presentation/cubit/exchange_history_cubit.dart';
import 'package:currency_converter/features/home/data/datasources/conversion_remote_data_source.dart';
import 'package:currency_converter/features/home/data/repositories/conversion_repository_impl.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';
import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_cubit.dart';

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

  // ============ Conversion Feature ============
  await _initConversionFeature();

  // ============ Exchange History Feature ============
  await _initExchangeHistoryFeature();
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

/// Initializes conversion feature dependencies.
Future<void> _initConversionFeature() async {
  // Data Sources
  sl.registerLazySingleton<ConversionRemoteDataSource>(
    () => ConversionRemoteDataSourceImpl(sl<ApiService>()),
  );

  // Repository
  sl.registerLazySingleton<ConversionRepository>(
    () => ConversionRepositoryImpl(
      remoteDataSource: sl<ConversionRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<ConvertCurrency>(
    () => ConvertCurrency(sl<ConversionRepository>()),
  );

  // Cubit - Factory so each screen gets its own instance
  sl.registerFactory<ConvertCubit>(
    () => ConvertCubit(convertCurrency: sl<ConvertCurrency>()),
  );
}

/// Initializes exchange history feature dependencies.
Future<void> _initExchangeHistoryFeature() async {
  // Data Sources
  sl.registerLazySingleton<ExchangeHistoryRemoteDataSource>(
    () => ExchangeHistoryRemoteDataSourceImpl(sl<ApiService>()),
  );

  // Repository
  sl.registerLazySingleton<ExchangeHistoryRepository>(
    () => ExchangeHistoryRepositoryImpl(
      remoteDataSource: sl<ExchangeHistoryRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetExchangeHistory>(
    () => GetExchangeHistory(sl<ExchangeHistoryRepository>()),
  );

  // Cubit - Factory so each screen gets its own instance
  sl.registerFactory<ExchangeHistoryCubit>(
    () => ExchangeHistoryCubit(getExchangeHistory: sl<GetExchangeHistory>()),
  );
}

/// Resets all dependencies.
///
/// Useful for testing.
Future<void> resetDependencies() async {
  await sl.reset();
}
