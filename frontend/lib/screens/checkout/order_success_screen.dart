// ═══════════════════════════════════════════════════════════════════
//  OrderSuccessScreen  —  lib/screens/checkout/order_success_screen.dart
//  Prinsip desain (sinkron dgn Cart & Checkout):
//   • AppCard utk kartu ringkasan pesanan
//   • SingleChildScrollView + SafeArea → aman di layar pendek & gesture nav
//   • Nomor pesanan panjang dibungkus Flexible → tidak overflow
//   • Palet: bg #F8FAFC, aksen utama Navy #151B26 (AppTheme.primary)
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      // SafeArea membungkus seluruh body: tombol paling bawah tidak
      // pernah terpotong gesture-nav bar di HP tanpa tombol fisik.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                // ── Hierarki 1: judul konfirmasi ──
                const Text(
                  'Pembayaran Berhasil! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ── Kartu ringkasan pesanan — AppCard, konsisten dgn
                // Cart/Checkout & kartu produk di Beranda ──
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('No. Pesanan', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          // Flexible: nomor pesanan bisa panjang tanpa
                          // memaksa Row keluar dari batas layar.
                          Flexible(
                            child: Text(
                              '#${order.orderNumber}',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Flexible(
                            child: Text(
                              order.statusLabel,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.info),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Hierarki 2 & 3: pesan sekunder & info coin ──
                Text(
                  'Pesanan #${order.orderNumber} sedang diproses oleh penjual.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                const Text(
                  '🪙 Lokal Coin kamu akan bertambah setelah pesanan diterima!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textHint),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/orders'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text('Lihat Status Pesanan →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/main'),
                  child: const Text('Lanjut Belanja', style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
