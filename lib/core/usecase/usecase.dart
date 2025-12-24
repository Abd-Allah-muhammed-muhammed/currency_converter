import 'package:currency_converter/core/network/api_result.dart';

/// Base class for all use cases in the application.
///
/// Use cases represent the business logic of the application
/// and are called by the presentation layer (Bloc).
///
/// [T] is the return type of the use case.
/// [Params] is the type of parameters the use case accepts.
abstract class UseCase<T, Params> {
  /// Executes the use case.
  Future<ApiResult<T>> call(Params params);
}

/// Use case that doesn't require any parameters.
class NoParams {
  const NoParams();
}
