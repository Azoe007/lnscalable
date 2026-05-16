import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF1A1D24);
  static const Color surfaceLight = Color(0xFF242830);
  
  // Primary
  static const Color primary = Color(0xFF5B8CFF);
  static const Color primaryLight = Color(0xFF8BAFFF);
  static const Color primaryDark = Color(0xFF2B6CFF);
  
  // Accent
  static const Color accent = Color(0xFF8B5CF6);
  
  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Text
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFA1A8B3);
  static const Color textMuted = Color(0xFF6B7280);
  
  // Borders
  static const Color border = Color(0xFF2D3139);
  static const Color borderLight = Color(0xFF3A3F4B);
  
  // Shadows
  static const Color shadow = Color(0xFF000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Opacity
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color surfaceWithOpacity(double opacity) => surface.withOpacity(opacity);
}