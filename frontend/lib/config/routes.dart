import 'package:flutter/material.dart';
import '../screens/auth/phone_entry_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/signup_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String phoneEntry = '/phone-entry';
  static const String otpVerification = '/otp-verification';
  static const String signup = '/signup';
  static const String otpSignup = '/otp-signup';
  static const String roleSelection = '/role-selection';
  
  // Main Routes
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String marketMap = '/market-map';
  static const String cart = '/cart';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  
  // Product Routes
  static const String productDetail = '/product-detail';
  static const String productForm = '/product-form';
  static const String productList = '/products';
  
  // Cart Routes
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  
  // UMKM Routes
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String umkmProfile = '/umkm-profile';
  
  // Notification Routes
  static const String notifications = '/notifications';
  
  // Other Routes
  static const String splash = '/';
  static const String notFound = '/404';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(settings, const SizedBox());
      case AppRoutes.phoneEntry:
        return _buildRoute(settings, const PhoneEntryScreen());
      case AppRoutes.otpVerification:
        final phone = settings.arguments as String?;
        return _buildRoute(
          settings,
          OtpScreen(
            phone: phone ?? '',
            role: 'consumer',
          ),
        );
      case AppRoutes.signup:
        return _buildRoute(settings, const SignupScreen());
      case AppRoutes.otpSignup:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings,
          OtpScreen(
            phone: args?['phone'] ?? '',
            name: args?['name'],
            role: (args?['role']?.toString() ?? 'consumer'),
          ),
        );
      case AppRoutes.mainNavigation:
        return _buildRoute(settings, const SizedBox());
      default:
        return _buildRoute(settings, const SizedBox());
    }
  }

  static PageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget widget,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => widget,
    );
  }
}

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class SlidePageRoute<T> extends MaterialPageRoute<T> {
  SlidePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
