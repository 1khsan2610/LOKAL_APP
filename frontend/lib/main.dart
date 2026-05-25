import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/auth/phone_entry_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/consumer/consumer_home_screen.dart';
import 'screens/profile/producer_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/products/product_upload_screen.dart';
import 'screens/cart/cart_screen.dart';
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
        '/phone-entry': (context) => const PhoneEntryScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/otp-verification': (context) {
          final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return OtpScreen(phone: phone, role: 'consumer');
        },
        '/otp-signup': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return OtpScreen(
            phone: args['phone'] ?? '',
            name: args['name'],
            role: args['role'] ?? 'consumer',
          );
        },
        // Consumer routes
        '/consumer-home': (context) => const ConsumerHomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        
        // Producer/UMKM routes
        '/producer-home': (context) => const ProducerHomeScreen(),
        '/product-upload': (context) => const UmkmProductUploadScreen(),
        '/umkm-profile-edit': (context) => const ProducerHomeScreen(),
        
        // Admin routes
        '/admin-dashboard': (context) => const AdminDashboard(),
        
        // Legacy routes for backward compatibility
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}