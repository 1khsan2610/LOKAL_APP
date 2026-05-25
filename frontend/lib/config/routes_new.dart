import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/orders/order_detail_screen.dart';

class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';

  // Main navigation
  static const String main = '/main';

  // Market & Products
  static const String marketMap = '/market-map';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String productForm = '/product-form';

  // Shopping
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';

  // Orders & Transactions
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';

  // Wallet
  static const String wallet = '/wallet';

  // Profile
  static const String profile = '/profile';

  // UMKM specific
  static const String analyticsDashboard = '/analytics-dashboard';

  // Notifications
  static const String notifications = '/notifications';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return CustomPageRoute(
          page: const LoginScreen(),
          name: settings.name,
        );

      case AppRoutes.otpVerification:
        return CustomPageRoute(
          page: const OtpVerificationScreen(),
          name: settings.name,
        );

      case AppRoutes.main:
        return CustomPageRoute(
          page: const MainNavigationScreen(),
          name: settings.name,
        );

      case AppRoutes.productList:
        return CustomPageRoute(
          page: const ProductListScreen(),
          name: settings.name,
        );

      case AppRoutes.productDetail:
        final productId = settings.arguments as String;
        return CustomPageRoute(
          page: ProductDetailScreen(productId: productId),
          name: settings.name,
        );

      case AppRoutes.checkout:
        return CustomPageRoute(
          page: const CheckoutScreen(),
          name: settings.name,
        );

      case AppRoutes.orderDetail:
        final orderId = settings.arguments as String;
        return CustomPageRoute(
          page: OrderDetailScreen(orderId: orderId),
          name: settings.name,
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Text('Route tidak ditemukan'),
          ),
        );
      },
    );
  }
}

// Custom Page Route with Fade Transition
class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final String? name;

  CustomPageRoute({
    required this.page,
    this.name,
  }) : super(
          settings: RouteSettings(name: name),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// Custom Page Route with Slide Transition
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final String? name;

  SlidePageRoute({
    required this.page,
    this.name,
  }) : super(
          settings: RouteSettings(name: name),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
