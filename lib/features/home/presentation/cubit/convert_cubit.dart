import 'dart:async';
import 'dart:developer' as developer;

import 'package:currency_converter/features/home/domain/usecases/convert_currency.dart';
import 'package:currency_converter/features/home/presentation/cubit/convert_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for handling currency conversion with debounce.
///
/// Handles:
/// - Debounced conversion when user types (1 second delay)
/// - Immediate conversion for quick select and swap
/// - Error handling for API failures
/// - Input validation
class ConvertCubit extends Cubit<ConvertState> {
  ConvertCubit({required ConvertCurrency convertCurrency})
    : _convertCurrency = convertCurrency,
      super(const ConvertInitial());

  final ConvertCurrency _convertCurrency;

  /// Debounce timer for user input.
  Timer? _debounceTimer;

  /// Debounce duration in milliseconds.
  static const int _debounceDuration = 1000;

  /// Current currencies for tracking.
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _currentAmount = 0;

  /// Gets the current from currency.
  String get fromCurrency => _fromCurrency;

  /// Gets the current to currency.
  String get toCurrency => _toCurrency;

  /// Gets the current amount.
  double get currentAmount => _currentAmount;

  /// Sets the from currency.
  void setFromCurrency(String currency) {
    _fromCurrency = currency;
  }

  /// Sets the to currency.
  void setToCurrency(String currency) {
    _toCurrency = currency;
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

    try {
      final result = await _convertCurrency(
        ConvertCurrencyParams(from: from, to: to, amount: amount),
      );

      developer.log(
        'Conversion successful: ${result.result} $to',
        name: 'ConvertCubit',
      );

      emit(ConvertSuccess(result: result));
    } on DioException catch (e) {
      developer.log(
        'Conversion failed: ${e.message}',
        name: 'ConvertCubit',
        error: e,
      );

      String errorMessage = 'Failed to convert currency';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }

      emit(
        ConvertError(
          message: errorMessage,
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
        ),
      );
    } on ArgumentError catch (e) {
      developer.log(
        'Validation error: ${e.message}',
        name: 'ConvertCubit',
        error: e,
      );

      emit(
        ConvertError(
          message: e.message.toString(),
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
        ),
      );
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'ConvertCubit', error: e);

      emit(
        ConvertError(
          message: 'An unexpected error occurred',
          fromCurrency: from,
          toCurrency: to,
          amount: amount,
        ),
      );
    }
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
