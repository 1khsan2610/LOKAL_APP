import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/main_nav_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/search_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/payment_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/order/order_list_screen.dart';
import '../screens/order/order_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/address_list_screen.dart';
import '../screens/profile/address_form_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/umkm/umkm_dashboard_screen.dart';
import '../screens/umkm/manage_product_screen.dart';
import '../screens/umkm/add_edit_product_screen.dart';
import '../screens/umkm/store_settings_screen.dart';
import '../screens/umkm/umkm_order_list_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/wishlist_screen.dart';
import '../screens/profile/my_reviews_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../models/product_model.dart';

class AppRouter {
  static const String splash          = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String forgotPassword  = '/forgot-password';
  static const String mainNav         = '/main';
  static const String home            = '/home';
  static const String productDetail   = '/product/detail';
  static const String search          = '/search';
  static const String cart            = '/cart';
  static const String checkout        = '/checkout';
  static const String payment         = '/payment';
  static const String orderSuccess    = '/order/success';
  static const String orderList       = '/orders';
  static const String orderDetail     = '/orders/detail';
  static const String profile         = '/profile';
  static const String editProfile     = '/profile/edit';
  static const String addressList     = '/profile/addresses';
  static const String addressForm     = '/profile/addresses/form';
  static const String wallet          = '/wallet';
  static const String notifications   = '/notifications';
  static const String map             = '/map';
  static const String adminDashboard  = '/admin';
  static const String umkmDashboard   = '/umkm/dashboard';
  static const String manageProducts  = '/umkm/products';
  static const String addEditProduct  = '/umkm/products/form';
  static const String storeSettings   = '/umkm/store-settings';
  static const String umkmOrders      = '/umkm/orders';
  static const String changePassword  = '/profile/change-password';
  static const String wishlist        = '/profile/wishlist';
  static const String myReviews       = '/profile/reviews';
  static const String resetPassword   = '/reset-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _build(const SplashScreen(), settings);
      case login:
        return _build(const LoginScreen(), settings);
      case register:
        return _build(const RegisterScreen(), settings);
      case forgotPassword:
        return _build(const ForgotPasswordScreen(), settings);
      case mainNav:
        return _build(const MainNavScreen(), settings);
      case productDetail:
        final product = settings.arguments as ProductModel;
        return _build(ProductDetailScreen(product: product), settings);
      case search:
        final query = settings.arguments as String? ?? '';
        return _build(SearchScreen(initialQuery: query), settings);
      case cart:
        return _build(const CartScreen(), settings);
      case checkout:
        return _build(const CheckoutScreen(), settings);
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return _build(PaymentScreen(
          snapToken: args['snap_token'],
          snapUrl: args['snap_url'] as String?,
          orderId: args['order_id'],
          total: args['total'],
        ), settings);
      case orderSuccess:
        final order = settings.arguments as OrderModel;
        return _build(OrderSuccessScreen(order: order), settings);
      case orderList:
        return _build(const OrderListScreen(), settings);
      case orderDetail:
        final order = settings.arguments as OrderModel;
        return _build(OrderDetailScreen(order: order), settings);
      case profile:
        return _build(const ProfileScreen(), settings);
      case editProfile:
        return _build(const EditProfileScreen(), settings);
      case addressList:
        return _build(const AddressListScreen(), settings);
      case addressForm:
        final address = settings.arguments as AddressModel?;
        return _build(AddressFormScreen(address: address), settings);
      case wallet:
        return _build(const WalletScreen(), settings);
      case notifications:
        return _build(const NotificationScreen(), settings);
      case map:
        return _build(const MapScreen(), settings);
      case adminDashboard:
        return _build(const AdminDashboardScreen(), settings);
      case umkmDashboard:
        return _build(const UmkmDashboardScreen(), settings);
      case manageProducts:
        return _build(const ManageProductScreen(), settings);
      case addEditProduct:
        final product = settings.arguments as ProductModel?;
        return _build(AddEditProductScreen(product: product), settings);
      case storeSettings:
        return _build(const StoreSettingsScreen(), settings);
      case umkmOrders:
        return _build(const UmkmOrderListScreen(), settings);
      case changePassword:
        return _build(const ChangePasswordScreen(), settings);
      case wishlist:
        return _build(const WishlistScreen(), settings);
      case myReviews:
        return _build(const MyReviewsScreen(), settings);
      case resetPassword:
        final email = settings.arguments as String? ?? '';
        return _build(ResetPasswordScreen(email: email), settings);
      default:
        return _build(
          Scaffold(body: Center(child: Text('Route ${settings.name} not found'))),
          settings,
        );
    }
  }

  static MaterialPageRoute _build(Widget page, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => page, settings: settings);
}
