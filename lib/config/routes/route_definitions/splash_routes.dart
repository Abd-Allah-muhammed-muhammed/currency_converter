


import 'package:currency_converter/config/routes/routes.dart';
import 'package:currency_converter/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> splashRoutes = [
  GoRoute(
    path: '/splash',
    name: AppRoutes.splash.name,
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        child:   SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        transitionDuration: const Duration(milliseconds: 500),
      );
    },
  ),

];
