import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/product_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        body: EmptyState(
          emoji: '👤', title: 'Belum Login',
          subtitle: 'Masuk untuk melihat profil dan riwayat pesananmu',
          buttonLabel: 'Masuk Sekarang',
          onButton: () => context.go('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.surface,
            child: Row(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary,
                backgroundImage: user.avatar != null ? NetworkImage(resolveImageUrl(user.avatar)) : null,
                child: user.avatar == null
                    ? Text(user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? const Color(0xFFFEE2E2) : user.isUmkm ? const Color(0xFFEDE9FE) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.isAdmin ? '⚙️ Administrator' : user.isUmkm ? '🏪 Pemilik UMKM' : '🛒 Konsumen',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: user.isAdmin ? const Color(0xFFB91C1C) : user.isUmkm ? const Color(0xFF6D28D9) : const Color(0xFF15803D)),
                  ),
                ),
                const SizedBox(height: 3),
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              ])),
            ]),
          ),

          // Coin balance
          GestureDetector(
            onTap: () => context.push('/wallet'),
            child: Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Text('🪙', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Lokal Coin Kamu', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  Text('${user.wallet?.coinBalance ?? 0} Coin',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                ])),
                const Icon(Icons.chevron_right, color: Colors.white),
              ]),
            ),
          ),

          // Menu items
          Container(
            color: AppTheme.surface,
            child: Column(children: [
              _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Pesanan Saya', badge: '4',
                onTap: () => context.push('/orders')),
              _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Dompet & Lokal Coin',
                onTap: () => context.push('/wallet')),
              _MenuItem(icon: Icons.location_on_outlined, label: 'Alamat Pengiriman',
                onTap: () => context.push('/profile/addresses')),
              _MenuItem(icon: Icons.favorite_border, label: 'Wishlist',
                onTap: () => context.push('/profile/wishlist')),
              _MenuItem(icon: Icons.star_border, label: 'Ulasan Saya',
                onTap: () => context.push('/profile/reviews')),
              _MenuItem(icon: Icons.notifications_outlined, label: 'Notifikasi',
                onTap: () => context.push('/notifications')),
              if (user.isUmkm)
                _MenuItem(icon: Icons.store_outlined, label: 'Kelola Toko',
                  onTap: () => context.push('/umkm/dashboard')),
              if (user.isAdmin)
                _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel',
                  onTap: () => context.push('/admin')),
              _MenuItem(icon: Icons.lock_outlined, label: 'Keamanan Akun',
                onTap: () => context.push('/profile/change-password')),
              _MenuItem(icon: Icons.lock_reset, label: 'Reset Password',
                onTap: () => context.push('/forgot-password')),
              const Divider(),
              _MenuItem(icon: Icons.logout, label: 'Keluar', color: AppTheme.danger,
                onTap: () => _confirmLogout(context, auth)),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Keluar'),
      content: const Text('Yakin ingin keluar dari akun ini?'),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () {
            Navigator.pop(context);
            auth.logout();
            context.go('/login');
          },
          child: const Text('Keluar'),
        ),
      ],
    ));
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.badge, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppTheme.primary, size: 22),
    title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppTheme.textPrimary)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      if (badge != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
          child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 6),
      ],
      Icon(Icons.chevron_right, size: 18, color: color?.withValues(alpha: 0.5) ?? AppTheme.textHint),
    ]),
    onTap: onTap,
  );
}
