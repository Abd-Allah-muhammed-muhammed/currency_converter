import 'package:currency_converter/config/routes/route_definitions/currency_picker_routes.dart';
import 'package:currency_converter/config/routes/route_definitions/exchange_history_routes.dart';
import 'package:currency_converter/config/routes/route_definitions/home_routes.dart';
import 'package:currency_converter/config/routes/route_definitions/splash_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    ...splashRoutes,
    ...homeRoutes,
    ...currencyPickerRoutes,
    ...exchangeHistoryRoutes,
  ],
);
