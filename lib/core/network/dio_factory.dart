import 'package:currency_converter/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Factory class for creating and configuring Dio HTTP client.
class DioFactory {
  /// Private constructor to prevent instantiation.
  DioFactory._();

  static Dio? _dio;

  /// Gets a configured Dio instance.
  ///
  /// Creates a new instance if one doesn't exist, otherwise returns
  /// the existing instance (singleton pattern).
  static Dio getDio({String? baseUrl}) {
    const timeout = Duration(seconds: 30);

    if (_dio == null) {
      _dio = Dio();
      _dio!
        ..options.connectTimeout = timeout
        ..options.receiveTimeout = timeout
        ..options.baseUrl = baseUrl ?? ApiConstants.apiBaseUrl
        ..options.headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
        ..options.queryParameters = {
          // Add API key to all requests
          'access_key': ApiConstants.apiKey,
        };
      _addDioInterceptor();
      return _dio!;
    } else {
      return _dio!;
    }
  }

  static void _addDioInterceptor() {
    _dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  /// Resets the Dio instance.
  ///
  /// Useful for testing or when the configuration needs to change.
  static void reset() {
    _dio = null;
  }
}
