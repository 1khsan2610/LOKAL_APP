import 'package:flutter/material.dart';

/// Helper untuk responsive design
class ResponsiveHelper {
  /// Get responsive grid columns based on screen width
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;      // Phones: 2 columns
    if (width < 600) return 2;      // Tablets (small): 2 columns
    if (width < 900) return 3;      // Tablets (medium): 3 columns
    return 4;                        // Desktop: 4 columns
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return const EdgeInsets.all(8);
    if (width < 600) return const EdgeInsets.all(12);
    if (width < 900) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.85 : width < 600 ? 0.9 : 1.0;
    return baseSize * scale;
  }

  /// Get responsive child aspect ratio for grid
  static double getResponsiveChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 0.65;   // Phones
    if (width < 600) return 0.68;   // Tablets (small)
    if (width < 900) return 0.75;   // Tablets (medium)
    return 0.8;                      // Desktop
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return baseSpacing * 0.8;
    if (width < 600) return baseSpacing * 0.9;
    return baseSpacing;
  }
}
