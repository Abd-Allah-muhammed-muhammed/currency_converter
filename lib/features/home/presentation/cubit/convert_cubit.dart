import 'dart:async';
import 'dart:developer' as developer;

import 'package:currency_converter/core/storage/preferences_repository.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit for handling currency conversion with debounce.
///
/// Handles:
/// - Debounced conversion when user types (1 second delay)
/// - Immediate conversion for quick select and swap
/// - Error handling for API failures
/// - Input validation
/// - Saving and restoring last selected currencies
/// - UI state management (currencies, amounts, quick select)
@injectable
class ConvertCubit extends Cubit<ConvertState> {
  ConvertCubit(
    ConvertCurrency convertCurrency,
    PreferencesRepository preferencesRepository,
  ) : _convertCurrency = convertCurrency,
      _preferencesRepository = preferencesRepository,
      super(const ConvertInitial(uiState: ConvertUiState())) {
    _initializeFromPreferences();
  }

  final ConvertCurrency _convertCurrency;
  final PreferencesRepository _preferencesRepository;

  /// Debounce timer for user input.
  Timer? _debounceTimer;

  /// Debounce duration in milliseconds.
  static const int _debounceDuration = 1000;

  /// Currency name mappings.
  static const _currencyNames = {
    'USD': 'United States Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'EGP': 'Egyptian Pound',
    'SAR': 'Saudi Riyal',
    'AED': 'UAE Dirham',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
  };

  /// Gets the currency name from the currency code.
  String _getCurrencyName(String code) => _currencyNames[code] ?? code;

  /// Gets the current UI state.
  ConvertUiState get uiState => state.uiState;

  /// Gets the current from currency.
  String get fromCurrency => state.uiState.fromCurrency;

  /// Gets the current to currency.
  String get toCurrency => state.uiState.toCurrency;

  /// Gets the current amount.
  double get currentAmount => state.uiState.amount;

  /// Initializes currencies from saved preferences.
  void _initializeFromPreferences() {
    var newUiState = state.uiState;

    final savedCurrencies = _preferencesRepository.getLastCurrencies();
    if (savedCurrencies != null) {
      newUiState = newUiState.copyWith(
        fromCurrency: savedCurrencies.from,
        toCurrency: savedCurrencies.to,
        fromCurrencyName: _getCurrencyName(savedCurrencies.from),
        toCurrencyName: _getCurrencyName(savedCurrencies.to),
      );
      developer.log(
        'Restored currencies: ${savedCurrencies.from} -> ${savedCurrencies.to}',
        name: 'ConvertCubit',
      );
    }

    final savedAmount = _preferencesRepository.getLastAmount();
    if (savedAmount != null && savedAmount > 0) {
      newUiState = newUiState.copyWith(amount: savedAmount);
      developer.log('Restored amount: $savedAmount', name: 'ConvertCubit');
    }

    emit(ConvertInitial(uiState: newUiState));
  }

  /// Updates the amount and triggers debounced conversion.
  void updateAmount(String value) {
    final amount = double.tryParse(value) ?? 0;

    // Clear quick select when user types
    final newUiState = state.uiState.copyWith(
      amount: amount,
      clearQuickAmount: true,
    );

    if (amount > 0) {
      _debounceTimer?.cancel();

      // Save to preferences
      unawaited(_preferencesRepository.saveLastAmount(amount));

      developer.log(
        'Debouncing conversion: $amount ${newUiState.fromCurrency} '
        'to ${newUiState.toCurrency}',
        name: 'ConvertCubit',
      );

      // Emit state with updated amount
      _emitWithUiState(newUiState);

      _debounceTimer = Timer(
        const Duration(milliseconds: _debounceDuration),
        () {
          unawaited(
            _performConversion(
              from: newUiState.fromCurrency,
              to: newUiState.toCurrency,
              amount: amount,
            ),
          );
        },
      );
    } else {
      _emitWithUiState(newUiState);
    }
  }

  /// Selects a quick amount and triggers immediate conversion.
  Future<void> selectQuickAmount(int amount) async {
    final newUiState = state.uiState.copyWith(
      amount: amount.toDouble(),
      selectedQuickAmount: amount,
    );

    // Save to preferences
    unawaited(_preferencesRepository.saveLastAmount(amount.toDouble()));

    await _performConversion(
      from: newUiState.fromCurrency,
      to: newUiState.toCurrency,
      amount: amount.toDouble(),
      uiState: newUiState,
    );
  }

  /// Sets the from currency and triggers immediate conversion.
  Future<void> setFromCurrency(Currency currency) async {
    final newUiState = state.uiState.copyWith(
      fromCurrency: currency.code,
      fromCurrencyName: currency.name,
    );

    // Save to preferences
    unawaited(
      _preferencesRepository.saveLastCurrencies(
        from: currency.code,
        to: newUiState.toCurrency,
      ),
    );

    if (newUiState.amount > 0) {
      await _performConversion(
        from: currency.code,
        to: newUiState.toCurrency,
        amount: newUiState.amount,
        uiState: newUiState,
      );
    } else {
      _emitWithUiState(newUiState);
    }
  }

  /// Sets the to currency and triggers immediate conversion.
  Future<void> setToCurrency(Currency currency) async {
    final newUiState = state.uiState.copyWith(
      toCurrency: currency.code,
      toCurrencyName: currency.name,
    );

    // Save to preferences
    unawaited(
      _preferencesRepository.saveLastCurrencies(
        from: newUiState.fromCurrency,
        to: currency.code,
      ),
    );

    if (newUiState.amount > 0) {
      await _performConversion(
        from: newUiState.fromCurrency,
        to: currency.code,
        amount: newUiState.amount,
        uiState: newUiState,
      );
    } else {
      _emitWithUiState(newUiState);
    }
  }

  /// Swaps the from and to currencies and triggers immediate conversion.
  Future<void> swapCurrencies() async {
    final newUiState = state.uiState.copyWith(
      fromCurrency: state.uiState.toCurrency,
      toCurrency: state.uiState.fromCurrency,
      fromCurrencyName: state.uiState.toCurrencyName,
      toCurrencyName: state.uiState.fromCurrencyName,
    );

    // Save to preferences
    unawaited(
      _preferencesRepository.saveLastCurrencies(
        from: newUiState.fromCurrency,
        to: newUiState.toCurrency,
      ),
    );

    if (newUiState.amount > 0) {
      await _performConversion(
        from: newUiState.fromCurrency,
        to: newUiState.toCurrency,
        amount: newUiState.amount,
        uiState: newUiState,
      );
    } else {
      _emitWithUiState(newUiState);
    }
  }

  /// Triggers an immediate conversion with current state.
  Future<void> triggerConversion() async {
    final ui = state.uiState;
    if (ui.amount > 0) {
      await _performConversion(
        from: ui.fromCurrency,
        to: ui.toCurrency,
        amount: ui.amount,
      );
    }
  }

  /// Emits a state preserving the current state type with updated UI state.
  void _emitWithUiState(ConvertUiState newUiState) {
    final currentState = state;
    if (currentState is ConvertSuccess) {
      emit(ConvertSuccess(uiState: newUiState, result: currentState.result));
    } else if (currentState is ConvertLoading) {
      emit(ConvertLoading(uiState: newUiState));
    } else if (currentState is ConvertError) {
      emit(ConvertError(uiState: newUiState, message: currentState.message));
    } else {
      emit(ConvertInitial(uiState: newUiState));
    }
  }

  /// Converts currency with debounce (legacy method for compatibility).
  void convertWithDebounce({
    required String from,
    required String to,
    required double amount,
  }) {
    _debounceTimer?.cancel();

    final newUiState = state.uiState.copyWith(
      fromCurrency: from,
      toCurrency: to,
      amount: amount,
      fromCurrencyName: _getCurrencyName(from),
      toCurrencyName: _getCurrencyName(to),
    );

    unawaited(_preferencesRepository.saveLastCurrencies(from: from, to: to));
    unawaited(_preferencesRepository.saveLastAmount(amount));

    if (amount <= 0) {
      developer.log(
        'Skipping conversion: amount is zero or negative',
        name: 'ConvertCubit',
      );
      return;
    }

    developer.log(
      'Debouncing conversion: $amount $from to $to',
      name: 'ConvertCubit',
    );

    _debounceTimer = Timer(const Duration(milliseconds: _debounceDuration), () {
      unawaited(
        _performConversion(
          from: from,
          to: to,
          amount: amount,
          uiState: newUiState,
        ),
      );
    });
  }

  /// Converts currency immediately without debounce (legacy method).
  Future<void> convertImmediately({
    required String from,
    required String to,
    required double amount,
  }) async {
    _debounceTimer?.cancel();

    final newUiState = state.uiState.copyWith(
      fromCurrency: from,
      toCurrency: to,
      amount: amount,
      fromCurrencyName: _getCurrencyName(from),
      toCurrencyName: _getCurrencyName(to),
    );

    if (amount <= 0) {
      developer.log(
        'Skipping conversion: amount is zero or negative',
        name: 'ConvertCubit',
      );
      return;
    }

    await _performConversion(
      from: from,
      to: to,
      amount: amount,
      uiState: newUiState,
    );
  }

  /// Performs the actual conversion API call.
  Future<void> _performConversion({
    required String from,
    required String to,
    required double amount,
    ConvertUiState? uiState,
  }) async {
    final effectiveUiState = uiState ?? state.uiState;

    developer.log(
      'Performing conversion: $amount $from to $to',
      name: 'ConvertCubit',
    );

    emit(ConvertLoading(uiState: effectiveUiState));

    final result = await _convertCurrency(
      ConvertCurrencyParams(from: from, to: to, amount: amount),
    );

    result.when(
      success: (conversionResult) {
        developer.log(
          'Conversion successful: ${conversionResult.result} $to',
          name: 'ConvertCubit',
        );
        emit(
          ConvertSuccess(uiState: effectiveUiState, result: conversionResult),
        );
      },
      failure: (error) {
        final errorMessage =
            error.failure.message ?? 'Failed to convert currency';
        developer.log('Conversion failed: $errorMessage', name: 'ConvertCubit');
        emit(ConvertError(uiState: effectiveUiState, message: errorMessage));
      },
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
