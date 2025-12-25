/// Dependency injection container.
///
/// @deprecated Use [injectable_config.dart] instead. This file is kept
/// for backwards compatibility with existing code and tests.
library;

export 'injectable_config.dart';

import 'package:currency_converter/core/di/injectable_config.dart';
import 'package:get_it/get_it.dart';

/// Global service locator instance.
///
/// @deprecated Use [getIt] from injectable_config.dart instead.
final GetIt sl = getIt;

/// Initializes all dependencies.
///
/// @deprecated Use [configureDependencies] from injectable_config.dart instead.
Future<void> initDependencies() async {
  await configureDependencies();
}

/// Resets all dependencies.
///
/// Useful for testing.
Future<void> resetDependencies() async {
  await getIt.reset();
}
