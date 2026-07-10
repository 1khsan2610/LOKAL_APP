import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../utils/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('✅', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('Pembayaran Berhasil! 🎉',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Pesanan #${order.orderNumber} sedang diproses oleh penjual.',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('🪙 Lokal Coin kamu akan bertambah setelah pesanan diterima!',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/orders'),
              child: const Text('Lihat Status Pesanan →'),
            )),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/main'),
            child: const Text('Lanjut Belanja', style: TextStyle(color: AppTheme.primary)),
          ),
        ]),
      ),
    ),
  );
}
