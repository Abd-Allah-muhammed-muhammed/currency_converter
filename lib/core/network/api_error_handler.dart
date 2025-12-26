import 'dart:convert';

import 'package:currency_converter/core/network/api_error_model.dart';
import 'package:dio/dio.dart';


/// Enum representing different data source error states.
enum DataSource {
  noContent,
  badRequest,
  forbidden,
  unauthorized,
  notFound,
  internalServerError,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  defaultError,
}

/// HTTP response status codes.
class ResponseCode {
  ResponseCode._();

  static const int success = 200;
  static const int noContent = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int apiLogicError = 422;
  static const int internalServerError = 500;

  // Local status codes
  static const int connectTimeout = -1;
  static const int cancel = -2;
  static const int receiveTimeout = -3;
  static const int sendTimeout = -4;
  static const int cacheError = -5;
  static const int noInternetConnection = -6;
  static const int defaultError = -7;
}

/// Response error messages.
class ResponseMessage {
  ResponseMessage._();

  static const String noContent = ApiErrors.noContent;
  static const String badRequest = ApiErrors.badRequestError;
  static const String unauthorized = ApiErrors.unauthorizedError;
  static const String forbidden = ApiErrors.forbiddenError;
  static const String notFound = ApiErrors.notFoundError;
  static const String internalServerError = ApiErrors.internalServerError;
  static const String connectTimeout = ApiErrors.timeoutError;
  static const String cancel = ApiErrors.defaultError;
  static const String receiveTimeout = ApiErrors.timeoutError;
  static const String sendTimeout = ApiErrors.timeoutError;
  static const String cacheError = ApiErrors.cacheError;
  static const String noInternetConnection = ApiErrors.noInternetError;
  static const String defaultError = ApiErrors.defaultError;
}

/// Extension to convert DataSource to ApiErrorModel.
extension DataSourceExtension on DataSource {
  ApiErrorModel getFailure() {
    switch (this) {
      case DataSource.noContent:
        return const ApiErrorModel(
          code: ResponseCode.noContent,
          message: ResponseMessage.noContent,
        );
      case DataSource.badRequest:
        return const ApiErrorModel(
          code: ResponseCode.badRequest,
          message: ResponseMessage.badRequest,
        );
      case DataSource.forbidden:
        return const ApiErrorModel(
          code: ResponseCode.forbidden,
          message: ResponseMessage.forbidden,
        );
      case DataSource.unauthorized:
        return const ApiErrorModel(
          code: ResponseCode.unauthorized,
          message: ResponseMessage.unauthorized,
        );
      case DataSource.notFound:
        return const ApiErrorModel(
          code: ResponseCode.notFound,
          message: ResponseMessage.notFound,
        );
      case DataSource.internalServerError:
        return const ApiErrorModel(
          code: ResponseCode.internalServerError,
          message: ResponseMessage.internalServerError,
        );
      case DataSource.connectTimeout:
        return const ApiErrorModel(
          code: ResponseCode.connectTimeout,
          message: ResponseMessage.connectTimeout,
        );
      case DataSource.cancel:
        return const ApiErrorModel(
          code: ResponseCode.cancel,
          message: ResponseMessage.cancel,
        );
      case DataSource.receiveTimeout:
        return const ApiErrorModel(
          code: ResponseCode.receiveTimeout,
          message: ResponseMessage.receiveTimeout,
        );
      case DataSource.sendTimeout:
        return const ApiErrorModel(
          code: ResponseCode.sendTimeout,
          message: ResponseMessage.sendTimeout,
        );
      case DataSource.cacheError:
        return const ApiErrorModel(
          code: ResponseCode.cacheError,
          message: ResponseMessage.cacheError,
        );
      case DataSource.noInternetConnection:
        return const ApiErrorModel(
          code: ResponseCode.noInternetConnection,
          message: ResponseMessage.noInternetConnection,
        );
      case DataSource.defaultError:
        return const ApiErrorModel(
          code: ResponseCode.defaultError,
          message: ResponseMessage.defaultError,
        );
    }
  }
}

/// Error handler for API errors.
///
/// Converts various error types to a standardized [ApiErrorModel].
class ErrorHandler implements Exception {

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      failure = _handleDioError(error);
    } else {
      failure = DataSource.defaultError.getFailure();
    }
  }

  ErrorHandler.fromMessage(this.failure);
  late ApiErrorModel failure;
}

/// Handles DioException and returns appropriate ApiErrorModel.
ApiErrorModel _handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.connectTimeout.getFailure();
    case DioExceptionType.sendTimeout:
      return DataSource.sendTimeout.getFailure();
    case DioExceptionType.receiveTimeout:
      return DataSource.receiveTimeout.getFailure();
    case DioExceptionType.badResponse:
      return _handleBadResponse(error);
    case DioExceptionType.cancel:
      return DataSource.cancel.getFailure();
    case DioExceptionType.connectionError:
      return DataSource.noInternetConnection.getFailure();
    case DioExceptionType.badCertificate:
      return DataSource.defaultError.getFailure();
    case DioExceptionType.unknown:
      if (error.response?.statusCode != null &&
          error.response?.statusMessage != null) {
        final respData = error.response!.data;

          if (respData is Map<String, dynamic>) {
            return ApiErrorModel.fromJson(respData);
          } else if (respData is String) {
            final decoded = json.decode(respData);
            if (decoded is Map<String, dynamic>) {
              return ApiErrorModel.fromJson(decoded);
            }
          }
        return DataSource.defaultError.getFailure();
      }
      return DataSource.defaultError.getFailure();
  }
}

/// Handles bad response errors.
ApiErrorModel _handleBadResponse(DioException error) {
  if (error.response?.data == null) {
    return DataSource.defaultError.getFailure();
  }

  final data = error.response?.data;

  // Handle "Unauthenticated" responses
  if (data is Map && data['message'] == 'Unauthenticated.') {
    return ApiErrorModel(
      code: error.response?.statusCode,
      message: data['message'].toString(),
    );
  }

  // Handle errors array
  if (data is Map &&
      data['errors'] is List &&
      (data['errors'] as List).isNotEmpty) {
 final errors = data['errors'] as List<dynamic>;
 final firstError = errors.isNotEmpty ? errors.first : null;
 return ApiErrorModel(
   code: error.response?.statusCode,
   message: firstError?.toString() ??
       DataSource.defaultError.getFailure().message,
 );
  }

  // Handle standard error response
  if (error.response?.statusCode != null &&
      error.response?.statusMessage != null) {
    final respData = error.response!.data;

      if (respData is Map<String, dynamic>) {
        return ApiErrorModel.fromJson(respData);
      } else if (respData is String) {
        final decoded = json.decode(respData);
        if (decoded is Map<String, dynamic>) {
          return ApiErrorModel.fromJson(decoded);
        }
      }

    return DataSource.defaultError.getFailure();
  }

  return DataSource.defaultError.getFailure();
}

/// API internal status codes.
class ApiInternalStatus {
  ApiInternalStatus._();

  static const int success = 0;
  static const int failure = 1;
}

/// Predefined API error messages.
class ApiErrors {
  ApiErrors._();

  static const String badRequestError = 'badRequestError';
  static const String noContent = 'noContent';
  static const String forbiddenError = 'forbiddenError';
  static const String unauthorizedError = 'unauthorizedError';
  static const String notFoundError = 'notFoundError';
  static const String conflictError = 'conflictError';
  static const String internalServerError = 'internalServerError';
  static const String unknownError = 'unknownError';
  static const String timeoutError = 'timeoutError';
  static const String defaultError = 'Try again later';
  static const String cacheError = 'cacheError';
  static const String noInternetError = 'noInternetError';
  static const String loadingMessage = 'loading_message';
  static const String retryAgainMessage = 'retry_again_message';
  static const String ok = 'Ok';
}
