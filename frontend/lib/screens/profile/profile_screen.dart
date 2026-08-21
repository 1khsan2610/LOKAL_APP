// ═══════════════════════════════════════════════════════════════════
//  ProfileScreen  —  lib/screens/profile/profile_screen.dart
//  Redesigned: Clean white header card, camera overlay on avatar,
//  modern ListTile menu with chevron, pastel role badges.
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked != null) {
      try {
        final api = ApiService();
        await api.uploadAvatar(picked);
        // Reload user data
        await auth.init();
        if (context.mounted) {
          AppSnackBar.show(context, '✓ Foto profil berhasil diperbarui');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.show(context, 'Gagal memperbarui foto profil', isError: true);
        }
      }
    }
  }

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

    final roleLabel = user.isAdmin ? 'Administrator' : user.isUmkm ? 'Pemilik UMKM' : 'Konsumen';
    final roleBadgeColor = user.isAdmin ? const Color(0xFFFEE2E2) : user.isUmkm ? const Color(0xFFEDE9FE) : const Color(0xFFDCFCE7);
    final roleBadgeTextColor = user.isAdmin ? const Color(0xFFB91C1C) : user.isUmkm ? const Color(0xFF6D28D9) : const Color(0xFF15803D);
    final roleIcon = user.isAdmin ? Icons.admin_panel_settings : user.isUmkm ? Icons.store_rounded : Icons.person_rounded;
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
            // ── Clean White Header Card ─────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with camera overlay
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryLight,
                        backgroundImage: user.avatar != null
                            ? NetworkImage(resolveImageUrl(user.avatar))
                            : null,
                        child: user.avatar == null
                            ? Text(
                                user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                              )
                            : null,
                      ),
                      // Camera icon overlay
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(context, auth),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 14, color: roleBadgeTextColor),
                              const SizedBox(width: 4),
                              Text(
                                roleLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: roleBadgeTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── UMKM Info Card ──────────────────────────────────────
            if (user.isUmkm && user.umkm != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_rounded, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text('Informasi Toko', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A2540), Color(0xFF1966D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('🪙', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lokal Coin Kamu', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${user.wallet?.coinBalance ?? 0} Coin',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Detail', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Menu Items ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Column(
                    children: [
                      if (user.isKonsumen) ...[
                        _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Pesanan Saya', onTap: () => context.push('/orders')),
                        _MenuItem(icon: Icons.chat_outlined, label: 'Pesan', onTap: () => context.push('/chats')),
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
                      _MenuItem(icon: Icons.smart_toy_outlined, label: 'LOKAL AI Assistant', onTap: () => context.push('/ai-chat')),
                      _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Dompet & Lokal Coin', onTap: () => context.push('/wallet')),
                      _MenuItem(icon: Icons.notifications_outlined, label: 'Notifikasi', onTap: () => context.push('/notifications')),
                      _MenuItem(icon: Icons.lock_outlined, label: 'Keamanan Akun', onTap: () => context.push('/profile/change-password')),
                      _MenuItem(icon: Icons.lock_reset, label: 'Reset Password', onTap: () => context.push('/forgot-password')),
                      const Divider(height: 1, indent: 16, endIndent: 16),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (color ?? AppTheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color ?? AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
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