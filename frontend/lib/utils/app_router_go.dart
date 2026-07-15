import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/main_nav_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/product_detail_loader.dart';
import '../screens/order/order_detail_loader.dart';
import '../screens/checkout/order_success_loader.dart';
import '../screens/profile/address_form_loader.dart';
import '../screens/umkm/add_edit_product_loader.dart';
import '../screens/product/search_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/payment_screen.dart';
import '../screens/order/order_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/address_list_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/umkm/umkm_dashboard_screen.dart';
import '../screens/umkm/umkm_analytics_screen.dart';
import '../screens/umkm/manage_product_screen.dart';
import '../screens/umkm/store_settings_screen.dart';
import '../screens/umkm/umkm_order_list_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/wishlist_screen.dart';
import '../screens/profile/my_reviews_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/ai_chat_screen.dart';


class AppRouterGo {
  static final GoRouter router = GoRouter(
    initialLocation: Uri.base.fragment.isNotEmpty
        ? (Uri.base.fragment.startsWith('/') ? Uri.base.fragment : '/${Uri.base.fragment}')
        : (Uri.base.path.isNotEmpty && Uri.base.path != '/' ? Uri.base.path : '/'),
    routes: [
      GoRoute(path: '/', builder: (ctx, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (ctx, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/main', builder: (ctx, state) => const MainNavScreen()),
      GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
      GoRoute(
        path: '/product/detail/:id',
        builder: (ctx, state) {
          final idStr = state.pathParameters['id']!;
          final id = int.tryParse(idStr) ?? 0;
          return ProductDetailLoader(productId: id);
        },
      ),
      GoRoute(path: '/search', builder: (ctx, state) => SearchScreen(initialQuery: state.uri.queryParameters['q'] ?? '')),
      GoRoute(path: '/cart', builder: (ctx, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (ctx, state) => const CheckoutScreen()),
      GoRoute(
        path: '/payment',
        builder: (ctx, state) => PaymentScreen(
          snapToken: state.uri.queryParameters['snap_token'] ?? '',
          snapUrl: state.uri.queryParameters['snap_url'],
          orderId: int.tryParse(state.uri.queryParameters['order_id'] ?? '') ?? 0,
          total: int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/order/success/:id',
        builder: (ctx, state) => OrderSuccessLoader(orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(path: '/orders', builder: (ctx, state) => const OrderListScreen()),
      GoRoute(path: '/orders/detail/:id', builder: (ctx, state) => OrderDetailLoader(orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0)),
      GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (ctx, state) => const EditProfileScreen()),
      GoRoute(path: '/profile/addresses', builder: (ctx, state) => const AddressListScreen()),
      GoRoute(path: '/profile/addresses/form', builder: (ctx, state) => AddressFormLoader(addressId: state.uri.queryParameters['id'] != null ? int.tryParse(state.uri.queryParameters['id']!) : null)),
      GoRoute(path: '/wallet', builder: (ctx, state) => const WalletScreen()),
      GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationScreen()),
      GoRoute(path: '/map', builder: (ctx, state) => const MapScreen()),
      GoRoute(path: '/admin', builder: (ctx, state) => const AdminDashboardScreen()),
      GoRoute(path: '/umkm/dashboard', builder: (ctx, state) => const UmkmDashboardScreen()),
      GoRoute(path: '/umkm/analytics', builder: (ctx, state) => const UmkmAnalyticsScreen()),
      GoRoute(path: '/umkm/products', builder: (ctx, state) => const ManageProductScreen()),
      GoRoute(path: '/umkm/products/form', builder: (ctx, state) => AddEditProductLoader(productId: state.uri.queryParameters['id'] != null ? int.tryParse(state.uri.queryParameters['id']!) : null)),
      GoRoute(path: '/umkm/store-settings', builder: (ctx, state) => const StoreSettingsScreen()),
      GoRoute(path: '/umkm/orders', builder: (ctx, state) => const UmkmOrderListScreen()),
      GoRoute(path: '/profile/change-password', builder: (ctx, state) => const ChangePasswordScreen()),
      GoRoute(path: '/profile/wishlist', builder: (ctx, state) => const WishlistScreen()),
      GoRoute(path: '/profile/reviews', builder: (ctx, state) => const MyReviewsScreen()),
      GoRoute(path: '/reset-password', builder: (ctx, state) => ResetPasswordScreen(email: state.uri.queryParameters['email'] ?? '')),
      GoRoute(path: '/ai-chat', builder: (ctx, state) => const AiChatScreen()),
    ],
    errorBuilder: (ctx, state) => Scaffold(body: Center(child: Text('Route ${state.uri.toString()} not found'))),
  );
}
