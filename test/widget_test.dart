// This is a basic Flutter widget test for the Currency Converter app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:currency_converter/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SplashPage Widget Tests', () {
    // Create a test router to handle navigation
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
        ],
      );
    }

    Widget buildTestableWidget(GoRouter router) {
      return FlutterSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp.router(
            routerConfig: router,
          );
        },
      );
    }

    testWidgets('SplashPage displays app title', (WidgetTester tester) async {
      final router = createTestRouter();

      // Build the SplashPage widget with FlutterSizer wrapper
      await tester.pumpWidget(buildTestableWidget(router));

      // Allow animations to start
      await tester.pump();

      // Verify that the app title is displayed
      expect(find.text('Currency ~ Converter'), findsOneWidget);

      // Advance past the timer to complete navigation
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('SplashPage displays subtitle', (WidgetTester tester) async {
      final router = createTestRouter();

      // Build the SplashPage widget with FlutterSizer wrapper
      await tester.pumpWidget(buildTestableWidget(router));

      // Allow animations to start
      await tester.pump();

      // Verify that the subtitle is displayed
      expect(find.text('Fast & Reliable Exchange Rates'), findsOneWidget);

      // Advance past the timer to complete navigation
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('SplashPage has correct background color', (
      WidgetTester tester,
    ) async {
      final router = createTestRouter();

      // Build the SplashPage widget with FlutterSizer wrapper
      await tester.pumpWidget(buildTestableWidget(router));

      // Find the Scaffold - may find more than one due to test router setup
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);

      // Verify the first Scaffold has correct background
      final scaffolds = tester.widgetList<Scaffold>(scaffoldFinder).toList();
      final splashScaffold = scaffolds.firstWhere(
        (s) => s.backgroundColor == const Color(0xFFF8F9FA),
        orElse: () => scaffolds.first,
      );
      expect(splashScaffold.backgroundColor, equals(const Color(0xFFF8F9FA)));

      // Advance past the timer to complete navigation
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
