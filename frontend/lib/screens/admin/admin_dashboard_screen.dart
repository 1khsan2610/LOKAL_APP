import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.person_outlined), onPressed: () => context.push('/profile')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Platform health
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3))),
            child: const Row(children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 20),
              SizedBox(width: 8),
              Text('Semua sistem berjalan normal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
            ]),
          ),
          const SizedBox(height: 16),

          // Stats
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
            children: const [
              _StatCard(icon: '💰', label: 'Pendapatan Bulan Ini', value: 'Rp 8.4M', trend: '↑ 12%', isUp: true),
              _StatCard(icon: '📦', label: 'Total Pesanan', value: '1,847', trend: '↑ 8%', isUp: true),
              _StatCard(icon: '🏪', label: 'UMKM Aktif', value: '324', trend: '+15 baru', isUp: true),
              _StatCard(icon: '👥', label: 'Pengguna Aktif', value: '12.4K', trend: '↑ 23%', isUp: true),
              _StatCard(icon: '📦', label: 'Produk Terdaftar', value: '8,920', trend: '↑ 5%', isUp: true),
              _StatCard(icon: '🪙', label: 'Coin Beredar', value: '2.1M', trend: '↓ 3%', isUp: false),
            ],
          ),
          const SizedBox(height: 20),

          // Category distribution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(item.$1, style: const TextStyle(fontSize: 12)),
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
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2, crossAxisSpacing: 10, mainAxisSpacing: 10,
            children: [
              _ActionCard(icon: '🏪', label: 'Kelola UMKM',   onTap: () => context.push('/admin/umkm')),
              _ActionCard(icon: '👥', label: 'Pengguna',      onTap: () => context.push('/admin/users')),
              _ActionCard(icon: '📦', label: 'Pesanan',       onTap: () => context.push('/admin/orders')),
              _ActionCard(icon: '📊', label: 'Laporan',       onTap: () => AppSnackBar.show(context, '📊 Laporan platform')),
              _ActionCard(icon: '🔔', label: 'Broadcast',     onTap: () => AppSnackBar.show(context, '🔔 Kirim notifikasi')),
              _ActionCard(icon: '⚙️', label: 'Pengaturan',   onTap: () => AppSnackBar.show(context, '⚙️ Pengaturan sistem')),
            ],
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String icon, label, value, trend;
  final bool isUp;
  const _StatCard({required this.icon, required this.label, required this.value, required this.trend, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(trend, style: TextStyle(fontSize: 11, color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
