import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/colors.dart';

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
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
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
                              child: Container(
                                width: 100.w,
                                height: 30.h,
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D4AA),
                                      borderRadius: BorderRadius.circular(16.w),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Dollar symbol
                                        Center(
                                          child: Text(
                                            '\$',
                                            style: TextStyle(
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        // Circular arrows
                                        Positioned(
                                          top: 8.w,
                                          right: 8.w,
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8.w,
                                          left: 8.w,
                                          child: Transform.rotate(
                                            angle: 3.14159, // 180 degrees
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 16.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                              'Currency\nConverter',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading indicator at bottom
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00D4AA),
                          ),
                          strokeWidth: 3,
                        ),
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
