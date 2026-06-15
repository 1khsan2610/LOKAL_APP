import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/auth/login_email_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';

import 'screens/home/home_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/consumer/consumer_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/cart/order_confirmation_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageService().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme(),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginEmailScreen(),
        '/signup': (context) => const SignupScreen(),

        // Onboarding & Register routes
        // Consumer routes
        '/consumer-home': (context) => const ConsumerHomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/products': (context) => const ProductListScreen(),
        '/product-detail': (context) {
          final product = ModalRoute.of(context)?.settings.arguments;
          return ProductDetailScreen(product: product);
        },
        '/checkout': (context) => const CheckoutScreen(),
        '/order-confirmation': (context) => const OrderConfirmationScreen(),
        '/main': (context) => const MainNavigationScreen(),
        // Admin routes
        '/admin-dashboard': (context) => const AdminDashboard(),
        
        // Legacy routes for backward compatibility
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}