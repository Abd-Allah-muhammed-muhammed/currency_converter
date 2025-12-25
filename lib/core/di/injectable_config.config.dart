// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/currency/data/datasources/currency_local_data_source.dart'
    as _i443;
import '../../features/currency/data/datasources/currency_remote_data_source.dart'
    as _i907;
import '../../features/currency/data/repositories/currency_repository_impl.dart'
    as _i751;
import '../../features/currency/domain/repositories/currency_repository.dart'
    as _i87;
import '../../features/currency/domain/usecases/get_currencies.dart' as _i670;
import '../../features/currency/presentation/bloc/currency_bloc.dart' as _i313;
import '../../features/exchange_history/data/datasources/exchange_history_remote_data_source.dart'
    as _i390;
import '../../features/exchange_history/data/repositories/exchange_history_repository_impl.dart'
    as _i798;
import '../../features/exchange_history/domain/repositories/exchange_history_repository.dart'
    as _i43;
import '../../features/exchange_history/domain/usecases/get_exchange_history.dart'
    as _i386;
import '../../features/exchange_history/presentation/cubit/exchange_history_cubit.dart'
    as _i163;
import '../../features/home/data/datasources/conversion_remote_data_source.dart'
    as _i751;
import '../../features/home/data/repositories/conversion_repository_impl.dart'
    as _i891;
import '../../features/home/domain/repositories/conversion_repository.dart'
    as _i302;
import '../../features/home/domain/usecases/convert_currency.dart' as _i1067;
import '../../features/home/presentation/cubit/convert_cubit.dart' as _i986;
import '../database/database_helper.dart' as _i64;
import '../network/api_service.dart' as _i921;
import '../storage/preferences_repository.dart' as _i723;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i64.DatabaseHelper>(() => registerModule.databaseHelper);
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i723.PreferencesRepository>(
      () => _i723.PreferencesRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i921.ApiService>(
      () => registerModule.apiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i390.ExchangeHistoryRemoteDataSource>(
      () => _i390.ExchangeHistoryRemoteDataSourceImpl(gh<_i921.ApiService>()),
    );
    gh.lazySingleton<_i751.ConversionRemoteDataSource>(
      () => _i751.ConversionRemoteDataSourceImpl(gh<_i921.ApiService>()),
    );
    gh.lazySingleton<_i907.CurrencyRemoteDataSource>(
      () => _i907.CurrencyRemoteDataSourceImpl(gh<_i921.ApiService>()),
    );
    gh.lazySingleton<_i43.ExchangeHistoryRepository>(
      () => _i798.ExchangeHistoryRepositoryImpl(
        remoteDataSource: gh<_i390.ExchangeHistoryRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i443.CurrencyLocalDataSource>(
      () => _i443.CurrencyLocalDataSourceImpl(gh<_i64.DatabaseHelper>()),
    );
    gh.lazySingleton<_i302.ConversionRepository>(
      () => _i891.ConversionRepositoryImpl(
        remoteDataSource: gh<_i751.ConversionRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i386.GetExchangeHistory>(
      () => _i386.GetExchangeHistory(gh<_i43.ExchangeHistoryRepository>()),
    );
    gh.lazySingleton<_i1067.ConvertCurrency>(
      () => _i1067.ConvertCurrency(gh<_i302.ConversionRepository>()),
    );
    gh.lazySingleton<_i87.CurrencyRepository>(
      () => _i751.CurrencyRepositoryImpl(
        localDataSource: gh<_i443.CurrencyLocalDataSource>(),
        remoteDataSource: gh<_i907.CurrencyRemoteDataSource>(),
      ),
    );
    gh.factory<_i163.ExchangeHistoryCubit>(
      () => _i163.ExchangeHistoryCubit(
        getExchangeHistory: gh<_i386.GetExchangeHistory>(),
      ),
    );
    gh.factory<_i986.ConvertCubit>(
      () => _i986.ConvertCubit(
        gh<_i1067.ConvertCurrency>(),
        gh<_i723.PreferencesRepository>(),
      ),
    );
    gh.lazySingleton<_i670.GetCurrencies>(
      () => _i670.GetCurrencies(gh<_i87.CurrencyRepository>()),
    );
    gh.factory<_i313.CurrencyBloc>(
      () => _i313.CurrencyBloc(
        getCurrencies: gh<_i670.GetCurrencies>(),
        repository: gh<_i87.CurrencyRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
