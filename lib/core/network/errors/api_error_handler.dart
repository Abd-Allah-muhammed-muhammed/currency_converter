import 'dart:convert';

import 'package:currency_converter/core/network/errors/api_error_model.dart';
import 'package:currency_converter/core/network/errors/enums.dart';
import 'package:currency_converter/core/network/errors/extension.dart';
import 'package:dio/dio.dart';



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
      message:
          firstError?.toString() ??
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

