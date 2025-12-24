import 'package:currency_converter/config/routes/routes.dart';
import 'package:currency_converter/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> homeRoutes = [
  GoRoute(
    path: '/home',
    name: AppRoutes.main.name,
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        child: const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
    },
  ),
];
