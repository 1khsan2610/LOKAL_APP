import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

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
import '../screens/umkm/umkm_layout.dart';
import '../screens/umkm/umkm_dashboard_screen.dart';
import '../screens/umkm/umkm_analytics_screen.dart';
import '../screens/umkm/umkm_chat_screen.dart';
import '../screens/umkm/manage_product_screen.dart';
import '../screens/umkm/store_settings_screen.dart';
import '../screens/umkm/umkm_order_list_screen.dart';
import '../screens/umkm/bank_account_screen.dart';
import '../screens/umkm/umkm_notification_screen.dart';
import '../screens/umkm/umkm_ai_assistant_screen.dart';
import '../screens/umkm/lokal_coin_screen.dart';
import '../screens/wallet/coin_history_screen.dart';
import '../screens/wallet/withdrawal_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/wishlist_screen.dart';
import '../screens/profile/my_reviews_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/customer_chat_screen.dart';
import '../screens/checkout/payment_success_screen.dart';
import '../widgets/mobile_frame.dart';


class AppRouterGo {
  static final GoRouter router = GoRouter(
    initialLocation: Uri.base.fragment.isNotEmpty
        ? (Uri.base.fragment.startsWith('/') ? Uri.base.fragment : '/${Uri.base.fragment}')
        : (Uri.base.path.isNotEmpty && Uri.base.path != '/' ? Uri.base.path : '/login'),
    routes: [
      GoRoute(path: '/', redirect: (ctx, state) => '/login'),
      GoRoute(path: '/login', builder: (ctx, state) => const MobileFrame(child: LoginScreen())),
      GoRoute(path: '/register', builder: (ctx, state) => const MobileFrame(child: RegisterScreen())),
      GoRoute(path: '/forgot-password', builder: (ctx, state) => const MobileFrame(child: ForgotPasswordScreen())),
      GoRoute(path: '/main', builder: (ctx, state) => const MainNavScreen()),
      GoRoute(path: '/home', builder: (ctx, state) => const MobileFrame(child: HomeScreen())),
      GoRoute(
        path: '/product/detail/:id',
        builder: (ctx, state) {
          final idStr = state.pathParameters['id']!;
          final id = int.tryParse(idStr) ?? 0;
          return MobileFrame(child: ProductDetailLoader(productId: id));
        },
      ),
      GoRoute(path: '/search', builder: (ctx, state) => MobileFrame(child: SearchScreen(initialQuery: state.uri.queryParameters['q'] ?? ''))),
      GoRoute(path: '/cart', builder: (ctx, state) => const MobileFrame(child: CartScreen())),
      GoRoute(path: '/checkout', builder: (ctx, state) => const MobileFrame(child: CheckoutScreen())),
      GoRoute(
        path: '/payment',
        builder: (ctx, state) => MobileFrame(child: PaymentScreen(
          snapToken: state.uri.queryParameters['snap_token'] ?? '',
          snapUrl: state.uri.queryParameters['snap_url'],
          orderId: int.tryParse(state.uri.queryParameters['order_id'] ?? '') ?? 0,
          total: int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0,
        )),
      ),
      GoRoute(
        path: '/order/success/:id',
        builder: (ctx, state) => MobileFrame(child: OrderSuccessLoader(orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0)),
      ),
      GoRoute(path: '/orders', builder: (ctx, state) => const MobileFrame(child: OrderListScreen())),
      GoRoute(path: '/orders/detail/:id', builder: (ctx, state) => MobileFrame(child: OrderDetailLoader(orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0))),
      GoRoute(path: '/profile', builder: (ctx, state) => const MobileFrame(child: ProfileScreen())),
      GoRoute(path: '/profile/edit', builder: (ctx, state) => const MobileFrame(child: EditProfileScreen())),
      GoRoute(path: '/profile/addresses', builder: (ctx, state) => const MobileFrame(child: AddressListScreen())),
      GoRoute(path: '/profile/addresses/form', builder: (ctx, state) => MobileFrame(child: AddressFormLoader(addressId: state.uri.queryParameters['id'] != null ? int.tryParse(state.uri.queryParameters['id']!) : null))),
      GoRoute(path: '/wallet', builder: (ctx, state) => const MobileFrame(child: WalletScreen())),
      GoRoute(path: '/notifications', builder: (ctx, state) => const MobileFrame(child: NotificationScreen())),
      GoRoute(path: '/map', builder: (ctx, state) => const MobileFrame(child: MapScreen())),
      // ── UMKM Merchant Center (wrapped with UmkmLayout) ─────────
      GoRoute(
        path: '/umkm/dashboard',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/dashboard',
          child: const UmkmDashboardScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/chat',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/chat',
          child: const UmkmChatScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/orders',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/orders',
          child: const UmkmOrderListScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/products',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/products',
          child: const ManageProductScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/analytics',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/analytics',
          child: const UmkmAnalyticsScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/store-settings',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/store-settings',
          child: const StoreSettingsScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/products/form',
        builder: (ctx, state) => MobileFrame(child: AddEditProductLoader(
          productId: state.uri.queryParameters['id'] != null ? int.tryParse(state.uri.queryParameters['id']!) : null,
        )),
      ),
      // ── NEW UMKM ROUTES ─────────────────────────────────────────
      GoRoute(
        path: '/umkm/notifications',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/notifications',
          child: const UmkmNotificationScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/ai-assistant',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/ai-assistant',
          child: const UmkmAiAssistantScreen(),
        )),
      ),
      GoRoute(
        path: '/umkm/lokal-coin',
        builder: (ctx, state) => MobileFrame(child: UmkmLayout(
          currentRoute: '/umkm/lokal-coin',
          child: const LokalCoinScreen(),
        )),
      ),
      GoRoute(path: '/umkm/bank-account', builder: (ctx, state) => const MobileFrame(child: BankAccountScreen())),
      GoRoute(path: '/profile/change-password', builder: (ctx, state) => const MobileFrame(child: ChangePasswordScreen())),
      GoRoute(path: '/profile/wishlist', builder: (ctx, state) => const MobileFrame(child: WishlistScreen())),
      GoRoute(path: '/profile/reviews', builder: (ctx, state) => const MobileFrame(child: MyReviewsScreen())),
      GoRoute(path: '/reset-password', builder: (ctx, state) => MobileFrame(child: ResetPasswordScreen(email: state.uri.queryParameters['email'] ?? ''))),
      GoRoute(path: '/ai-chat', builder: (ctx, state) => const MobileFrame(child: AiChatScreen())),
      GoRoute(path: '/wallet/coin-history', builder: (ctx, state) => const MobileFrame(child: CoinHistoryScreen())),
      GoRoute(path: '/wallet/withdrawal', builder: (ctx, state) => const MobileFrame(child: WithdrawalScreen())),
      // ── Customer Chat (Konsumen) ────────────────────────────────
      GoRoute(
        path: '/customer-chat',
        builder: (ctx, state) {
          final chatId = state.uri.queryParameters['chat_id'] != null
              ? int.tryParse(state.uri.queryParameters['chat_id']!)
              : null;
          final receiverId = state.uri.queryParameters['receiver_id'] != null
              ? int.tryParse(state.uri.queryParameters['receiver_id']!)
              : null;
          return MobileFrame(child: CustomerChatScreen(
            initialChatId: chatId,
            receiverId: receiverId,
            receiverName: state.uri.queryParameters['store_name'],
            storeName: state.uri.queryParameters['store_name'],
            storeLogo: state.uri.queryParameters['store_logo'],
            productId: state.uri.queryParameters['product_id'] != null
                ? int.tryParse(state.uri.queryParameters['product_id']!)
                : null,
          ));
        },
      ),
      // ── Payment Success ─────────────────────────────────────────
      GoRoute(
        path: '/payment/success',
        builder: (ctx, state) => MobileFrame(child: PaymentSuccessScreen(
          orderId: state.uri.queryParameters['order_id'] ?? '',
          orderNumber: state.uri.queryParameters['order_number'] ?? '#ELWZDOORXZ',
          paymentMethod: state.uri.queryParameters['payment_method'] ?? 'Lokal Wallet',
          total: int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 45000,
          coinReward: int.tryParse(state.uri.queryParameters['coin_reward'] ?? '') ?? 150,
        )),
      ),
      // ── Chat ─────────────────────────────────────────────────────
      GoRoute(path: '/chats', builder: (ctx, state) => const MobileFrame(child: ChatListScreen())),
      GoRoute(
        path: '/chat/:id',
        builder: (ctx, state) {
          final chatId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MobileFrame(child: ChatScreen(initialChatId: chatId));
        },
      ),
    ],
    errorBuilder: (ctx, state) => MobileFrame(child: Scaffold(body: Center(child: Text('Route ${state.uri.toString()} not found')))),
  );
}