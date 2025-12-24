import 'package:currency_converter/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

/// API service for making HTTP requests using Retrofit.
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  /// Gets the list of supported currencies.
  @GET(ApiConstants.currenciesList)
  Future<HttpResponse<dynamic>> getCurrencies();

  /// Converts an amount from one currency to another.
  @GET(ApiConstants.convert)
  Future<HttpResponse<dynamic>> convert(
    @Query('from') String from,
    @Query('to') String to,
    @Query('amount') double amount,
  );

  /// Gets historical exchange rates for a time period.
  @GET(ApiConstants.timeframe)
  Future<HttpResponse<dynamic>> getTimeframe(
    @Query('start_date') String startDate,
    @Query('end_date') String endDate,
    @Query('base') String base,
    @Query('symbols') String symbols,
  );

  /// Gets live exchange rates.
  @GET(ApiConstants.liveRates)
  Future<HttpResponse<dynamic>> getLiveRates(
    @Query('source') String source,
    @Query('currencies') String currencies,
  );
}


