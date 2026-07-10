import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../order/order_list_screen.dart';
import '../notification/notification_screen.dart' as notif_screen;
import '../profile/profile_screen.dart';
import '../umkm/umkm_dashboard_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      context.read<NotificationProvider>().load();
    });
  }

  List<Widget> _buildPages(String role) => [
    const HomeScreen(),
    const MapScreen(),
    const OrderListScreen(),
    if (role == 'umkm') const UmkmDashboardScreen(),
    const notif_screen.NotificationScreen(),
    const ProfileScreen(),
  ];

  List<BottomNavigationBarItem> _buildItems(String role, int notifCount, int cartCount) => [
    const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
    const BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Peta'),
    const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Pesanan'),
    if (role == 'umkm') const BottomNavigationBarItem(icon: Icon(Icons.store_outlined), activeIcon: Icon(Icons.store), label: 'Toko'),
    BottomNavigationBarItem(
      icon: badges.Badge(
        showBadge: notifCount > 0,
        badgeContent: Text('$notifCount', style: const TextStyle(color: Colors.white, fontSize: 9)),
        child: const Icon(Icons.notifications_outlined),
      ),
      activeIcon: const Icon(Icons.notifications),
      label: 'Notif',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final cart   = context.watch<CartProvider>();
    final notif  = context.watch<NotificationProvider>();
    final role   = auth.user?.role ?? 'konsumen';
    final pages  = _buildPages(role);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      // Floating cart button
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              onPressed: () => context.push('/cart'),
              child: badges.Badge(
                showBadge: cart.totalItems > 0,
                badgeContent: Text('${cart.totalItems}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _buildItems(role, notif.unreadCount, cart.totalItems),
        ),
      ),
    );
  }
}
