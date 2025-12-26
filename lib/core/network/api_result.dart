import 'package:currency_converter/core/network/errors/api_error_handler.dart';

class ApiResult<T> {
  ApiResult.success(this.data) : errorHandler = null, isSuccess = true;

  ApiResult.failure(this.errorHandler) : data = null, isSuccess = false;
  final T? data;
  final ErrorHandler? errorHandler;
  final bool isSuccess;

  // Manually implementing the `when` method
  TResult when<TResult>({
    required TResult Function(T data) success,
    required TResult Function(ErrorHandler errorHandler) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else if (!isSuccess && errorHandler != null) {
      return failure(errorHandler!);
    } else {
      throw Exception('Invalid ApiResult state');
    }
  }
}
