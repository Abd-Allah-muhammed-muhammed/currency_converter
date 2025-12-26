import 'dart:developer' as developer;

import 'package:currency_converter/core/usecase/usecase.dart';
import 'package:currency_converter/core/utils/conest.dart';
import 'package:currency_converter/core/utils/transformers.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/domain/repositories/currency_repository.dart';
import 'package:currency_converter/features/currency/domain/usecases/get_currencies.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_event.dart';
import 'package:currency_converter/features/currency/presentation/bloc/currency_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

const _duration = Duration(milliseconds: 300);

/// Bloc for managing currency state.
///
/// This bloc handles loading, searching, and selecting currencies
/// following the offline-first approach.
@injectable
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc({
    required GetCurrencies getCurrencies,
    required CurrencyRepository repository,
  }) : _getCurrencies = getCurrencies,
       _repository = repository,
       super(const CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<RefreshCurrencies>(_onRefreshCurrencies);
    on<SearchCurrencies>(_onSearchCurrencies, transformer: debounce(_duration));
  }

  final GetCurrencies _getCurrencies;
  final CurrencyRepository _repository;

  /// Handles [LoadCurrencies] event.
  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    developer.log('Loading currencies...', name: 'CurrencyBloc');

    final result = await _getCurrencies(const NoParams());

    if (result.isSuccess && result.data != null) {
      final currencies = result.data!;
      final popularCurrencies = _extractPopularCurrencies(currencies);
      final isFromCache = await _repository.hasCachedCurrencies();

      developer.log(
        'Loaded ${currencies.length} currencies (from cache: $isFromCache)',
        name: 'CurrencyBloc',
      );

      emit(
        CurrencyLoaded(
          currencies: currencies,
          popularCurrencies: popularCurrencies,
          isFromCache: isFromCache,
        ),
      );
    } else {
      final errorMessage =
          result.errorHandler?.failure.message ?? 'Unknown error';
      developer.log(
        'Failed to load currencies: $errorMessage',
        name: 'CurrencyBloc',
      );
      emit(CurrencyError(errorMessage));
    }
  }

  /// Handles [RefreshCurrencies] event.
  Future<void> _onRefreshCurrencies(
    RefreshCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    // Keep showing current data while refreshing
    final currentState = state;
    if (currentState is! CurrencyLoaded) {
      emit(const CurrencyLoading());
    }

    developer.log('Refreshing currencies...', name: 'CurrencyBloc');

    final result = await _repository.refreshCurrencies();

    if (result.isSuccess && result.data != null) {
      final currencies = result.data!;
      final popularCurrencies = _extractPopularCurrencies(currencies);

      developer.log(
        'Refreshed ${currencies.length} currencies',
        name: 'CurrencyBloc',
      );

      emit(
        CurrencyLoaded(
          currencies: currencies,
          popularCurrencies: popularCurrencies,
        ),
      );
    } else {
      final errorMessage =
          result.errorHandler?.failure.message ?? 'Unknown error';
      developer.log(
        'Failed to refresh currencies: $errorMessage',
        name: 'CurrencyBloc',
      );
      emit(CurrencyError(errorMessage));
    }
  }

  /// Handles [SearchCurrencies] event.
  void _onSearchCurrencies(
    SearchCurrencies event,
    Emitter<CurrencyState> emit,
  ) {
    final currentState = state;
    if (currentState is! CurrencyLoaded) return;

    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(currentState.copyWith(searchQuery: ''));
      return;
    }

    final filtered = currentState.currencies.where((currency) {
      return currency.code.toLowerCase().contains(query) ||
          currency.name.toLowerCase().contains(query);
    }).toList();

    emit(
      currentState.copyWith(searchQuery: query, filteredCurrencies: filtered),
    );
  }

  /// Extracts popular currencies from the full list.
  List<Currency> _extractPopularCurrencies(List<Currency> currencies) {
    final popularList = <Currency>[];

    for (final code in popularCurrencyCodes) {
      final currency = currencies.firstWhere(
        (c) => c.code == code,
        orElse: () => Currency(code: code, name: code),
      );
      if (currencies.any((c) => c.code == code)) {
        popularList.add(currency);
      }
    }

    return popularList;
  }
}
