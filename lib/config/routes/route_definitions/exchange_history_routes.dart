import 'package:currency_converter/config/routes/routes.dart';
import 'package:currency_converter/features/exchange_history/presentation/pages/exchange_history_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Arguments for exchange history page navigation.
class ExchangeHistoryArgs {
  final String fromCurrency;
  final String toCurrency;
  final String fromCurrencyName;
  final String toCurrencyName;

  const ExchangeHistoryArgs({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromCurrencyName,
    required this.toCurrencyName,
  });
}

final List<GoRoute> exchangeHistoryRoutes = [
  GoRoute(
    path: '/exchange-history',
    name: AppRoutes.exchangeHistory.name,
    pageBuilder: (context, state) {
      final args = state.extra as ExchangeHistoryArgs?;
      return CustomTransitionPage(
        child: ExchangeHistoryPage(
          fromCurrency: args?.fromCurrency ?? 'USD',
          toCurrency: args?.toCurrency ?? 'EUR',
          fromCurrencyName: args?.fromCurrencyName ?? 'US Dollar',
          toCurrencyName: args?.toCurrencyName ?? 'Euro',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
    },
  ),
];
