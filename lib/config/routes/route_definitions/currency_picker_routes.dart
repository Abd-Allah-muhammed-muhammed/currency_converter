import 'package:currency_converter/config/routes/routes.dart';
import 'package:currency_converter/features/currency/presentation/pages/currency_picker_page.dart';
 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> currencyPickerRoutes = [
  GoRoute(
    path: '/currency-picker',
    name: AppRoutes.currencyPicker.name,
    pageBuilder: (context, state) {
      final selectedCode = state.extra as String?;
      return CustomTransitionPage(
        child: CurrencyPickerPage(
          selectedCurrencyCode: selectedCode,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
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
