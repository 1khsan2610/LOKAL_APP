// ═══════════════════════════════════════════════════════════════════
//  ProfileScreen  —  lib/screens/profile/profile_screen.dart
//  Prinsip desain (sinkron dgn Beranda / Cart / Checkout):
//   • AppCard utk "Informasi Toko" & grup menu → konsisten di seluruh app
//   • Nama/email/label dibungkus Expanded/Flexible → tidak ada overflow
//   • SafeArea/viewPadding.bottom → aman dari gesture nav bar
//   • Palet: bg #F8FAFC, aksen utama Navy #151B26 (AppTheme.primary)
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: EmptyState(
          emoji: '👤',
          title: 'Belum Login',
          subtitle: 'Masuk untuk melihat profil dan riwayat pesananmu',
          buttonLabel: 'Masuk Sekarang',
          onButton: () => context.go('/login'),
        ),
      );
    }

    final roleLabel = user.isAdmin ? '⚙️ Administrator' : user.isUmkm ? '🏪 Pemilik UMKM' : '🛒 Konsumen';
    final roleBadgeColor = user.isAdmin ? const Color(0xFFFEE2E2) : user.isUmkm ? const Color(0xFFEDE9FE) : const Color(0xFFDCFCE7);
    final roleBadgeTextColor = user.isAdmin ? const Color(0xFFB91C1C) : user.isUmkm ? const Color(0xFF6D28D9) : const Color(0xFF15803D);
    // Header navy solid — konsisten dgn AppBar & aksen utama dashboard,
    // menggantikan warna pastel per-role agar identitas brand lebih kuat.
    const headerColor = AppTheme.primary;
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
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
        padding: EdgeInsets.only(bottom: bottomSafe + 24),
        child: Column(
          children: [
            // ── Header profil ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: headerColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: user.avatar != null ? NetworkImage(resolveImageUrl(user.avatar)) : null,
                    child: user.avatar == null
                        ? Text(
                            user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Expanded WAJIB: nama/email panjang tidak akan
                  // mendorong avatar keluar batas layar (no overflow).
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hierarki 1: nama pengguna ──
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: roleBadgeColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            roleLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: roleBadgeTextColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // ── Hierarki 3: email (info sekunder) ──
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (user.isUmkm && user.umkm != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Toko', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 10),
                      Text(
                        user.umkm!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.umkm!.city != null ? '${user.umkm!.city}, ${user.umkm!.province ?? ''}' : '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.umkm!.description ?? 'Belum ada deskripsi toko.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Saldo Lokal Coin ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                onTap: () => context.push('/wallet'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lokal Coin Kamu', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            // ── Hierarki 2: saldo coin — FittedBox cegah
                            // overflow saat saldo jadi angka besar.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${user.wallet?.coinBalance ?? 0} Coin',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            // ── Grup menu — dibungkus AppCard, konsisten dgn kartu
            // section lain di seluruh app ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: AppCard(
                padding: EdgeInsets.zero,
                // ClipRRect: AppCard tidak meng-clip child-nya secara
                // default, jadi efek ripple InkWell pada item pertama
                // bisa "bocor" keluar sudut membulat tanpa ini.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Column(
                  children: [
                    if (user.isKonsumen) ...[
                      _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Pesanan Saya', onTap: () => context.push('/orders')),
                      _MenuItem(icon: Icons.location_on_outlined, label: 'Alamat Pengiriman', onTap: () => context.push('/profile/addresses')),
                      _MenuItem(icon: Icons.favorite_border, label: 'Wishlist', onTap: () => context.push('/profile/wishlist')),
                      _MenuItem(icon: Icons.star_border, label: 'Ulasan Saya', onTap: () => context.push('/profile/reviews')),
                    ],
                    if (user.isUmkm) ...[
                      _MenuItem(icon: Icons.store_outlined, label: 'Dashboard Toko', onTap: () => context.push('/umkm/dashboard')),
                      _MenuItem(icon: Icons.shopping_cart_outlined, label: 'Kelola Produk', onTap: () => context.push('/umkm/products')),
                      _MenuItem(icon: Icons.list_alt_outlined, label: 'Pesanan Toko', onTap: () => context.push('/umkm/orders')),
                      _MenuItem(icon: Icons.settings_outlined, label: 'Pengaturan Toko', onTap: () => context.push('/umkm/store-settings')),
                    ],
                    _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Dompet & Lokal Coin', onTap: () => context.push('/wallet')),
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Notifikasi', onTap: () => context.push('/notifications')),
                    if (user.isAdmin)
                      _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel', onTap: () => context.push('/admin')),
                    _MenuItem(icon: Icons.lock_outlined, label: 'Keamanan Akun', onTap: () => context.push('/profile/change-password')),
                    _MenuItem(icon: Icons.lock_reset, label: 'Reset Password', onTap: () => context.push('/forgot-password')),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.logout,
                      label: 'Keluar',
                      color: AppTheme.danger,
                      isLast: true,
                      onTap: () => _confirmLogout(context, auth),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(AppTheme.cardRadius) : Radius.zero,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            bottom: isLast ? const Radius.circular(AppTheme.cardRadius) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppTheme.primary, size: 22),
                const SizedBox(width: 14),
                // Expanded: label menu panjang tetap satu baris rapi,
                // tidak mendorong ikon chevron keluar layar.
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppTheme.textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: color?.withValues(alpha: 0.5) ?? AppTheme.textHint),
              ],
            ),
          ),
        ),
      );
}
