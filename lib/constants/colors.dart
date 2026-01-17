import 'package:flutter/material.dart';

/// RUTAPUMA - UNAH Color Scheme
/// Based on the official UNAH branding (Yellow and Dark Blue)
class AppColors {
  // Primary Colors - UNAH Official Branding
  static const Color primaryYellow = Color(0xFFFDB71A); // UNAH Yellow
  static const Color primaryBlue = Color(0xFF1E3A5F); // UNAH Dark Blue
  static const Color secondaryBlue = Color(0xFF2B4C7E); // Medium Blue

  // Accent Colors
  static const Color lightYellow = Color(0xFFFFD54F);
  static const Color darkBlue = Color(0xFF0D1F3C);
  static const Color accentBlue = Color(0xFF3D5A80);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [primaryYellow, lightYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowBlueGradient = LinearGradient(
    colors: [primaryYellow, primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
