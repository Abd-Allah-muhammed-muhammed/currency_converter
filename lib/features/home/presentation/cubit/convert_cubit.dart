import 'dart:async';
import 'dart:developer' as developer;

import 'package:currency_converter/core/storage/preferences_repository.dart';
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
@injectable
class ConvertCubit extends Cubit<ConvertState> {
  ConvertCubit(
    ConvertCurrency convertCurrency,
    PreferencesRepository preferencesRepository,
  )   : _convertCurrency = convertCurrency,
        _preferencesRepository = preferencesRepository,
        super(const ConvertInitial()) {
    _initializeFromPreferences();
  }

  final ConvertCurrency _convertCurrency;
  final PreferencesRepository _preferencesRepository;

  /// Debounce timer for user input.
  Timer? _debounceTimer;

  /// Debounce duration in milliseconds.
  static const int _debounceDuration = 1000;

  /// Current currencies for tracking.
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _currentAmount = 0;

  /// Initializes currencies from saved preferences.
  void _initializeFromPreferences() {
    final savedCurrencies = _preferencesRepository.getLastCurrencies();
    if (savedCurrencies != null) {
      _fromCurrency = savedCurrencies.from;
      _toCurrency = savedCurrencies.to;
      developer.log(
        'Restored currencies: $_fromCurrency -> $_toCurrency',
        name: 'ConvertCubit',
      );
    }

    final savedAmount = _preferencesRepository.getLastAmount();
    if (savedAmount != null) {
      _currentAmount = savedAmount;
      developer.log(
        'Restored amount: $_currentAmount',
        name: 'ConvertCubit',
      );
    }
  }

  /// Gets the current from currency.
  String get fromCurrency => _fromCurrency;

  /// Gets the current to currency.
  String get toCurrency => _toCurrency;

  /// Gets the current amount.
  double get currentAmount => _currentAmount;

  /// Sets the from currency and saves to preferences.
  void setFromCurrency(String currency) {
    _fromCurrency = currency;
    _preferencesRepository.saveLastCurrencies(
      from: _fromCurrency,
      to: _toCurrency,
    );
  }

  /// Sets the to currency and saves to preferences.
  void setToCurrency(String currency) {
    _toCurrency = currency;
    _preferencesRepository.saveLastCurrencies(
      from: _fromCurrency,
      to: _toCurrency,
    );
  }

  /// Converts currency with debounce.
  ///
  /// This method waits for 1 second after the user stops typing
  /// before making the API call.
  void convertWithDebounce({
    required String from,
    required String to,
    required double amount,
  }) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update tracking
    _fromCurrency = from;
    _toCurrency = to;
    _currentAmount = amount;

    // Save to preferences
    _preferencesRepository.saveLastCurrencies(from: from, to: to);
    _preferencesRepository.saveLastAmount(amount);

    // Validate input - don't call API for invalid amounts
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

    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: _debounceDuration), () {
      _performConversion(from: from, to: to, amount: amount);
    });
  }

  /// Converts currency immediately without debounce.
  ///
  /// Use this for quick select buttons and currency swap.
  Future<void> convertImmediately({
    required String from,
    required String to,
    required double amount,
  }) async {
    // Cancel any pending debounce
    _debounceTimer?.cancel();

    // Update tracking
    _fromCurrency = from;
    _toCurrency = to;
    _currentAmount = amount;

    // Validate input
    if (amount <= 0) {
      developer.log(
        'Skipping conversion: amount is zero or negative',
        name: 'ConvertCubit',
      );
      return;
    }

    await _performConversion(from: from, to: to, amount: amount);
  }

  /// Performs the actual conversion API call.
  Future<void> _performConversion({
    required String from,
    required String to,
    required double amount,
  }) async {
    developer.log(
      'Performing conversion: $amount $from to $to',
      name: 'ConvertCubit',
    );

    emit(ConvertLoading(fromCurrency: from, toCurrency: to, amount: amount));

    final result = await _convertCurrency(
      ConvertCurrencyParams(from: from, to: to, amount: amount),
    );

    result.when(
      success: (conversionResult) {
        developer.log(
          'Conversion successful: ${conversionResult.result} $to',
          name: 'ConvertCubit',
        );
        emit(ConvertSuccess(result: conversionResult));
      },
      failure: (error) {
        final errorMessage =
            error.failure.message ?? 'Failed to convert currency';
        developer.log('Conversion failed: $errorMessage', name: 'ConvertCubit');
        emit(
          ConvertError(
            message: errorMessage,
            fromCurrency: from,
            toCurrency: to,
            amount: amount,
          ),
        );
      },
    );
  }

  /// Swaps the from and to currencies and converts.
  Future<void> swapCurrencies() async {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;

    if (_currentAmount > 0) {
      await convertImmediately(
        from: _fromCurrency,
        to: _toCurrency,
        amount: _currentAmount,
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
