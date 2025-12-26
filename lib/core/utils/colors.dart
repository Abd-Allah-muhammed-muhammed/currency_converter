import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base colors that don't change
  static const Color primaryColor = Color(0xFF00B8AD);

  // Currency Converter Theme Colors
  static const Color cyan = Color(0xFF00D4C8);
  static const Color cyanLight = Color(0xFF00E5D9);
  static const Color cyanDark = Color(0xFF00B8AD);
  static const Color turquoise = Color(0xFF2DD4BF);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color chartBackground = Color(0xFFE8F7F6);

  // Text colors
  static const Color textPrimary = Color(0xFF00D4C8);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Chart colors
  static const Color chartLine = Color(0xFF00D4C8);
  static const Color chartGradientStart = Color(0x4000D4C8);
  static const Color chartGradientEnd = Color(0x0000D4C8);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
