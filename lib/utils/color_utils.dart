import 'package:flutter/material.dart';

/// Extension to replace deprecated withOpacity with Color.from
extension ColorExtension on Color {
  /// Creates a new color with the specified opacity (0.0 to 1.0)
  /// This replaces the deprecated withOpacity method
  Color withOpacityValue(double opacity) {
    return Color.from(
      alpha: opacity.clamp(0.0, 1.0),
      red: r,
      green: g,
      blue: b,
    );
  }
}

/// Helper function to create color with opacity from existing color
Color colorWithOpacity(Color color, double opacity) {
  return Color.from(
    alpha: opacity.clamp(0.0, 1.0),
    red: color.r,
    green: color.g,
    blue: color.b,
  );
}

/// Commonly used semi-transparent colors
class OpacityColors {
  // Black with various opacities
  static Color black05 = colorWithOpacity(Colors.black, 0.05);
  static Color black08 = colorWithOpacity(Colors.black, 0.08);
  static Color black10 = colorWithOpacity(Colors.black, 0.10);
  static Color black15 = colorWithOpacity(Colors.black, 0.15);
  static Color black20 = colorWithOpacity(Colors.black, 0.20);
  static Color black50 = colorWithOpacity(Colors.black, 0.50);

  // White with various opacities
  static Color white20 = colorWithOpacity(Colors.white, 0.20);
  static Color white30 = colorWithOpacity(Colors.white, 0.30);
  static Color white50 = colorWithOpacity(Colors.white, 0.50);
  static Color white80 = colorWithOpacity(Colors.white, 0.80);
  static Color white90 = colorWithOpacity(Colors.white, 0.90);
  static Color white95 = colorWithOpacity(Colors.white, 0.95);

  // Primary color opacities - use AppColors.primaryGradient colors
  static Color primary10 = colorWithOpacity(const Color(0xFF667eea), 0.10);
  static Color primary40 = colorWithOpacity(const Color(0xFF667eea), 0.40);

  // Amber/Gold opacities
  static Color amber15 = colorWithOpacity(Colors.amber, 0.15);
  static Color amber20 = colorWithOpacity(Colors.amber, 0.20);
  static Color amber50 = colorWithOpacity(Colors.amber, 0.50);

  // Green opacities
  static Color green15 = colorWithOpacity(Colors.green, 0.15);
  static Color green30 = colorWithOpacity(Colors.green, 0.30);

  // Red opacities
  static Color red30 = colorWithOpacity(Colors.red, 0.30);

  // Orange opacities
  static Color orange40 = colorWithOpacity(Colors.orange, 0.40);

  // Purple opacities
  static Color purple20 = colorWithOpacity(Colors.purple, 0.20);
  static Color purple30 = colorWithOpacity(const Color(0xFF6C5CE7), 0.30);

  // Blue opacities
  static Color blue10 = colorWithOpacity(Colors.blue, 0.10);
}
