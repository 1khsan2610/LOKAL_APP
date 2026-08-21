import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../order/order_list_screen.dart';
import '../chat/chat_list_screen.dart';
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
    });
  }

  List<Widget> _buildPages(String role) {
    if (role != 'umkm') {
      return const [
        HomeScreen(),
        MapScreen(),
        OrderListScreen(),
        ChatListScreen(),
        ProfileScreen(),
      ];
    }
    return const [
      UmkmDashboardScreen(),
      ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _buildItems(String role) {
    final items = <BottomNavigationBarItem>[];

    if (role != 'umkm') {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Beranda',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map),
        label: 'Peta',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: 'Pesanan',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.chat_outlined),
        activeIcon: Icon(Icons.chat),
        label: 'Pesan',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ));
    } else {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.store_outlined),
        activeIcon: Icon(Icons.store),
        label: 'Toko',
      ));
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final role = (auth.user?.role ?? 'konsumen').toString().toLowerCase();
    final pages = _buildPages(role);

    // Clamp current index if role change removed earlier tabs to avoid OOB.
    if (_currentIndex >= pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = pages.length - 1);
      });
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      // Floating cart button (hanya tampil untuk non-UMKM)
      floatingActionButton: (role != 'umkm' && _currentIndex == 0)
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              onPressed: () => context.push('/cart'),
              child: badges.Badge(
                showBadge: cart.totalItems > 0,
                badgeContent: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
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
          items: _buildItems(role),
        ),
      ),
    );
  }
}