import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dashboard_components.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.person_outlined), onPressed: () => context.push('/profile')),
        ],
      ),
      // LayoutBuilder di root: jumlah kolom & aspect ratio grid statistik +
      // aksi cepat diturunkan dari lebar layar aktual, sehingga tampilan
      // tetap proporsional dari HP kecil sampai tablet/desktop (Flutter web).
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final statColumns = width < 400 ? 2 : width < 700 ? 3 : 4;
          final statAspect = width < 400 ? 1.15 : width < 700 ? 1.3 : 1.4;
          final actionColumns = width < 400 ? 3 : width < 700 ? 4 : 6;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Platform health
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text('Semua sistem berjalan normal',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Stats — meniru kartu statistik dashboard admin web:
              // chip ikon pastel + badge status + angka besar + label.
              GridView.count(
                crossAxisCount: statColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: statAspect,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StatCard(icon: Icons.payments_outlined, iconColor: const Color(0xFF15803D), iconBg: const Color(0xFFDCFCE7),
                    value: 'Rp 8.4Jt', label: 'Pendapatan Bulan Ini', badge: '↑ 12%', badgeColor: AppTheme.success),
                  StatCard(icon: Icons.shopping_bag_outlined, iconColor: const Color(0xFF1E40AF), iconBg: const Color(0xFFDBEAFE),
                    value: '1.847', label: 'Total Pesanan', badge: '↑ 8%', badgeColor: AppTheme.success),
                  StatCard(icon: Icons.storefront_outlined, iconColor: const Color(0xFFB45309), iconBg: const Color(0xFFFEF3C7),
                    value: '324', label: 'UMKM Aktif', badge: '+15 baru', badgeColor: AppTheme.warning),
                  StatCard(icon: Icons.people_outline, iconColor: const Color(0xFF6D28D9), iconBg: const Color(0xFFEDE9FE),
                    value: '12.4K', label: 'Pengguna Aktif', badge: '↑ 23%', badgeColor: AppTheme.success),
                  StatCard(icon: Icons.inventory_2_outlined, iconColor: const Color(0xFF1E40AF), iconBg: const Color(0xFFDBEAFE),
                    value: '8.920', label: 'Produk Terdaftar', badge: '↑ 5%', badgeColor: AppTheme.success),
                  StatCard(icon: Icons.monetization_on_outlined, iconColor: const Color(0xFFB45309), iconBg: const Color(0xFFFEF3C7),
                    value: '2.1Jt', label: 'Coin Beredar', badge: '↓ 3%', badgeColor: AppTheme.danger),
                ],
              ),
              const SizedBox(height: 20),

              // Category distribution
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('🗂️ Distribusi Kategori Produk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ...[
                    ('Makanan & Minuman', 35, AppTheme.primary),
                    ('Fashion', 25, AppTheme.accent),
                    ('Kerajinan', 20, const Color(0xFF8B5CF6)),
                    ('Bahan Pokok', 12, AppTheme.warning),
                    ('Lainnya', 8, AppTheme.textHint),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        Text('${item.$2}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: item.$3)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.$2 / 100, minHeight: 7,
                          backgroundColor: AppTheme.surface2,
                          valueColor: AlwaysStoppedAnimation<Color>(item.$3),
                        ),
                      ),
                    ]),
                  )),
                ]),
              ),
              const SizedBox(height: 20),

              // Quick admin actions
              const Text('⚡ Aksi Cepat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: actionColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  QuickActionTile(icon: Icons.storefront_outlined, label: 'Kelola UMKM', onTap: () => AppSnackBar.show(context, '🏪 Daftar UMKM')),
                  QuickActionTile(icon: Icons.people_outline, label: 'Pengguna', onTap: () => AppSnackBar.show(context, '👥 Daftar pengguna')),
                  QuickActionTile(icon: Icons.shopping_bag_outlined, label: 'Pesanan', onTap: () => AppSnackBar.show(context, '📦 Semua pesanan')),
                  QuickActionTile(icon: Icons.bar_chart_outlined, label: 'Laporan', onTap: () => AppSnackBar.show(context, '📊 Laporan platform')),
                  QuickActionTile(icon: Icons.campaign_outlined, label: 'Broadcast', onTap: () => AppSnackBar.show(context, '🔔 Kirim notifikasi')),
                  QuickActionTile(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => AppSnackBar.show(context, '⚙️ Pengaturan sistem')),
                ],
              ),
              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }
}
