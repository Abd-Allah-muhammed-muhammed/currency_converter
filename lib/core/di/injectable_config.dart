import 'package:currency_converter/core/di/injectable_config.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures dependency injection using injectable.
///
/// This should be called before running the app.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() => getIt.init();
