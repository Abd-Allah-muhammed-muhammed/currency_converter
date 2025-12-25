import 'package:currency_converter/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigateToHome();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.pushReplacement('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundLight,AppColors.chartBackground],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Container
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Center(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/icons/logo.png',
                                    fit: BoxFit.cover,
                                    width: 50.w,
                                    height: 50.w,
                                  ),
                                ),
                              ),
                          ),
                          ),

                          SizedBox(height: 8.h),
                          // Title
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Currency ~ Converter',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.dp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Subtitle
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Fast & Reliable Exchange Rates',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.dp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
