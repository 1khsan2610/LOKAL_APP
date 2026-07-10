import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper untuk navigasi dengan GoRouter yang kompatibel dengan panggilan Navigator lama
extension GoRouterHelper on BuildContext {
  /// Navigasi ke path, replace history
  void goNamed(String path, {Object? arguments}) {
    go(_buildPath(path, arguments));
  }

  /// Push rute baru
  void pushNamed(String path, {Object? arguments}) {
    push(_buildPath(path, arguments));
  }

  /// Replace rute saat ini
  void pushReplacementNamed(String path, {Object? arguments}) {
    goNamed(path, arguments: arguments);
  }

  /// Build path dengan query params dari arguments
  static String _buildPath(String path, Object? arguments) {
    if (arguments == null) return path;

    // Jika arguments adalah Map, gunakan sebagai query params
    if (arguments is Map<String, dynamic>) {
      final params = arguments.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return params.isNotEmpty ? '$path?$params' : path;
    }

    // Jika arguments adalah String (untuk product/order ID, dll)
    // Handle khusus untuk rute yang butuh ID
    if (path.contains('product') && arguments is String) {
      return '/product/detail/$arguments';
    }
    if (path.contains('order') && arguments is String) {
      return '/orders/detail/$arguments';
    }

    return path;
  }
}
