import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Pumabus Blue & Gold)
  static const Color primaryBlue = Color(
    0xFF0056B3,
  ); // Vibrant Royal Blue (Pumabus)
  static const Color primaryYellow = Color(0xFFFFC600); // Bright Gold/Amber
  static const Color secondaryBlue = Color(0xFF003D7A); // Deeper Royal Blue
  static const Color softBlue = Color(
    0xFF4A90E2,
  ); // Softer, pleasant blue for backgrounds

  // Neutral Dark Mode Colors (Material Style)
  static const Color darkBackground = Color(0xFF121212); // Neutral black/grey
  static const Color darkSurface = Color(0xFF1E1E1E); // Darker surface
  static const Color darkAccent = Color(0xFF2C2C2C); // Accent for dark mode
  static const Color darkBorder = Color(0xFF333333); // Subtle border
  static const Color darkHighlight = Color(
    0xFF383838,
  ); // Even lighter for lists/items

  // Softer Dark Mode Colors (Keeping for reference)
  static const Color midnightBlue = Color(0xFF0A192F);
  static const Color oceanBlue = Color(0xFF112240);
  static const Color slateGrey = Color(0xFF233554);

  // Accent Colors
  static const Color lightYellow = Color(0xFFFFD54F);
  static const Color darkBlue = Color(0xFF001B3B); // Almost black navy
  static const Color accentBlue = Color(0xFF1E88E5); // Keep for some highlights
  static const Color red = Color(0xFFD32F2F);
  static const Color green = Color(0xFF388E3C);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5); // Standard light grey
  static const Color darkGrey = Color(0xFF424242);
  static const Color shadowColor = Color(0xFF9CA9B8); // Cool grey shadow

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, accentBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Premium Dark Gradient
  static const LinearGradient darkGradient = LinearGradient(
    colors: [midnightBlue, oceanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [primaryYellow, lightYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
