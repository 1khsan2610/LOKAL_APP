import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_card.dart';
import 'tracking_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = ApiService();
  OrderModel get order => widget.order;

  Future<void> _openReviewFlow() async {
    final item = order.items.length == 1
        ? order.items.first
        : await showDialog<OrderItemModel>(
            context: context,
            builder: (_) => SimpleDialog(
              title: const Text('Pilih produk untuk diulas'),
              children: order.items.map((it) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, it),
                child: Text(it.product?.name ?? 'Produk #${it.productId}'),
              )).toList(),
            ),
          );
    if (item == null || !mounted) return;

    int rating = 5;
    final controller = TextEditingController();
    final result = await showDialog<(int, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('⭐ Beri Ulasan'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(item.product?.name ?? 'Produk #${item.productId}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
              onPressed: () => setDialogState(() => rating = i + 1),
              icon: Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppTheme.warning, size: 28),
            ))),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Bagaimana pengalamanmu dengan produk ini?',
                border: OutlineInputBorder(),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, (rating, controller.text.trim())),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;

    try {
      final resp = await _api.createReview({
        'product_id': item.productId,
        'order_id': order.id,
        'rating': result.$1,
        'comment': result.$2,
      });
      if (!mounted) return;
      AppSnackBar.show(context, resp.data['message'] ?? '✓ Ulasan berhasil dikirim');
    } catch (e) {
      if (!mounted) return;
      final message = (e as dynamic).response?.data?['message'] ?? 'Gagal mengirim ulasan. Coba lagi.';
      AppSnackBar.show(context, message, isError: true);
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.cancelOrder(order.id);
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Pesanan dibatalkan');
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal membatalkan pesanan', isError: true);
    }
  }

  Future<void> _confirmReceived() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pesanan Diterima'),
        content: const Text('Pastikan barang sudah kamu terima dengan baik. Lokal Coin akan ditambahkan ke akunmu setelah ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Belum')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Sudah Diterima'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.confirmReceived(order.id);
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Pesanan dikonfirmasi diterima. Lokal Coin kamu bertambah! 🪙');
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal mengonfirmasi pesanan', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text('#${order.orderNumber}', maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Status Pesanan', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                const SizedBox(height: 4),
                StatusBadge(status: order.status),
              ]),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Tanggal Pesanan', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                const SizedBox(height: 4),
                Text(order.createdAt.substring(0, 10), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          if (order.address != null) ...[
            _DetailSection(title: '📍 Alamat Pengiriman', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.address!.recipientName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(order.address!.phone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              const SizedBox(height: 2),
              Text(order.address!.fullAddress, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ])),
            const SizedBox(height: 12),
          ],
          _DetailSection(title: '📦 Item Pesanan', child: Column(
            children: order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: SizedBox(width: 50, height: 50,
                    child: item.product?.primaryImage != null
                        ? Image.network(resolveImageUrl(item.product!.primaryImage), fit: BoxFit.cover)
                        : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.product?.name ?? 'Produk #${item.productId}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${item.quantity}x · ${currency.format(item.price)}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                ])),
                PriceText(item.subtotal, fontSize: 13),
              ]),
            )).toList(),
          )),
          const SizedBox(height: 12),
          _DetailSection(title: '💰 Rincian Pembayaran', child: Column(children: [
            _DetailRow('Subtotal',    currency.format(order.subtotal)),
            _DetailRow('Ongkos Kirim', currency.format(order.shippingFee)),
            if (order.coinDiscount > 0) _DetailRow('Diskon Coin', '-${currency.format(order.coinDiscount)}', isGreen: true),
            const Divider(height: 16),
            _DetailRow('Total', currency.format(order.total), isBold: true),
          ])),
          const SizedBox(height: 20),
          // ⚠️ REFUND INFO: Jika status cancelled, tampilkan info refund koin
          if (order.status == 'cancelled') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline, color: AppTheme.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('❌ Pesanan Dibatalkan',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.danger)),
                    const SizedBox(height: 4),
                    Text(
                      order.coinDiscount > 0
                          ? 'Koin yang digunakan sebesar Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(order.coinDiscount)} telah dikembalikan ke saldo Lokal Coin Anda.'
                          : 'Pesanan ini telah dibatalkan.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.danger),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          if (order.status == 'pending' || order.status == 'awaiting_payment') ...[
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _cancelOrder,
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger, side: const BorderSide(color: AppTheme.danger)),
              icon: const Icon(Icons.cancel_outlined), label: const Text('Batalkan Pesanan'),
            )),
            const SizedBox(height: 10),
          ],
          if (order.status == 'shipped') ...[
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(orderId: order.id, orderNumber: order.orderNumber))),
              icon: const Icon(Icons.local_shipping_outlined), label: const Text('Lacak Paket'),
            )),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _confirmReceived,
              icon: const Icon(Icons.check_circle_outline), label: const Text('Konfirmasi Diterima'),
            )),
            const SizedBox(height: 10),
          ],
          if (order.status == 'delivered')
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _openReviewFlow,
              icon: const Icon(Icons.star_outline), label: const Text('Beri Ulasan'),
            )),
          const SizedBox(height: 24),
        ]),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isGreen, isBold;
  const _DetailRow(this.label, this.value, {this.isGreen = false, this.isBold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary)),
      Text(value,  style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
        color: isGreen ? AppTheme.success : isBold ? AppTheme.primary : AppTheme.textPrimary)),
    ]),
  );
}