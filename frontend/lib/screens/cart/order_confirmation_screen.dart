import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../widgets/common/custom_widgets.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final order = args is Order ? args : null;
    final methodLabel = order?.paymentMethod != null
        ? _formatPaymentMethod(order!.paymentMethod!)
        : 'Belum Dipilih';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pesanan Diterima',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppNumbers.paddingLarge),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha((255 * 0.12).round()),
                borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 96,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppNumbers.paddingLarge),
            Text(
              'Pembayaran Sedang Diproses',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppNumbers.paddingSmall),
            Text(
              'Kami telah menerima pesanan Anda. Lanjutkan ke halaman detail pesanan atau kembali ke beranda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.paddingLarge),
            if (order != null) ...[
              Card(
                elevation: AppNumbers.elevationSmall,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nomor Pesanan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppNumbers.paddingMedium),
                      _InfoRow(label: 'Total Pembayaran', value: 'Rp ${order.totalPrice.toStringAsFixed(0)}'),
                      _InfoRow(label: 'Metode Pembayaran', value: methodLabel),
                      _InfoRow(label: 'Status Pesanan', value: 'Menunggu Pembayaran'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppNumbers.paddingLarge),
            ],
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/orders'),
              child: const Text('Lihat Pesanan Saya'),
            ),
            const SizedBox(height: AppNumbers.paddingSmall),
            OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/consumer-home',
                (route) => false,
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.gopay:
        return 'GoPay';
      case PaymentMethod.ovo:
        return 'OVO';
      case PaymentMethod.dana:
        return 'DANA';
      case PaymentMethod.bank_transfer:
        return 'Transfer Bank';
      case PaymentMethod.qris:
        return 'QRIS';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppNumbers.paddingSmall / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
