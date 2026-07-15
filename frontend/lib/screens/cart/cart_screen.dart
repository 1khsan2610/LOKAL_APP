// ═══════════════════════════════════════════════════════════════════
//  CartScreen  —  lib/screens/cart/cart_screen.dart
//  Prinsip desain (sinkron dengan Beranda / LOKAL Admin Dashboard):
//   • AppCard untuk membungkus setiap item → konsisten dgn kartu produk
//   • Sticky footer (tombol Checkout) dgn SafeArea utk gesture nav
//   • Semua teks dibungkus Flexible/Expanded → tidak ada RenderFlex overflow
//   • Palet: bg #F8FAFC, aksen utama Navy #151B26 (AppTheme.primary)
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/app_card.dart';
import '../../widgets/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    // Jarak aman dari bawah utk perangkat gesture-nav (tanpa tombol fisik).
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Kosongkan Keranjang?'),
                  content: const Text('Semua produk di keranjang akan dihapus.'),
                  actions: [
                    TextButton(onPressed: () => context.pop(), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                      onPressed: () { context.pop(); cart.clearCart(); },
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.white),
              label: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyState(
              emoji: '🛒',
              title: 'Keranjang Kosong',
              subtitle: 'Temukan produk UMKM lokal favoritmu!',
              buttonLabel: 'Mulai Belanja',
              onButton: () => context.go('/main'),
            )
          // ── Body scrollable + footer sticky di luar area scroll ─────
          // Column biasa (bukan Stack) supaya list TIDAK pernah
          // tertutup footer: footer punya slot ruang sendiri di bawah.
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return _CartItemCard(
                        item: item,
                        onDecrement: item.quantity > 1
                            ? () => cart.updateQuantity(item.id, item.quantity - 1)
                            : null,
                        onIncrement: () => cart.updateQuantity(item.id, item.quantity + 1),
                        onRemove: () => cart.removeItem(item.id),
                      );
                    },
                  ),
                ),
                _CartStickyFooter(cart: cart, bottomSafe: bottomSafe),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Kartu item keranjang — dibungkus AppCard agar konsisten dgn
//  ProductCard di Beranda (radius, border, elevation seragam).
// ─────────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.product.primaryImage != null
                  ? Image.network(resolveImageUrl(item.product.primaryImage), fit: BoxFit.cover)
                  : Container(
                      color: AppTheme.surface2,
                      child: const Icon(Icons.image_outlined, size: 30, color: AppTheme.textHint),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded WAJIB di sini: nama barang panjang tidak akan
          // mendorong layout keluar batas layar (mencegah overflow).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hierarki 1: nama barang (paling menonjol setelah harga)
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                // ── Hierarki 3: metadata sekunder (nama toko)
                Text(
                  item.product.umkm?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                ),
                const SizedBox(height: 6),
                // ── Hierarki 2: harga per item (jelas, warna aksen)
                PriceText(item.product.displayPrice, fontSize: 14),
                const SizedBox(height: 8),
                // Row aksi: stepper qty (kiri) + hapus (kanan), pakai
                // Spacer supaya tetap rapi di lebar layar sekecil apa pun.
                Row(
                  children: [
                    _QtyStepper(
                      quantity: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  const _QtyStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            color: AppTheme.primary,
            disabledColor: AppTheme.textHint,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 16),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Footer sticky: ringkasan harga + tombol Checkout.
//  Selalu menempel di dasar layar & TIDAK pernah tertutup oleh list,
//  karena berada di luar Expanded (bukan overlay di atas konten).
//  Padding bawah memakai `bottomSafe` (MediaQuery.viewPadding.bottom)
//  supaya tombol tidak terpotong gesture-bar HP tanpa tombol fisik.
// ─────────────────────────────────────────────────────────────────
class _CartStickyFooter extends StatelessWidget {
  final CartProvider cart;
  final double bottomSafe;
  const _CartStickyFooter({required this.cart, required this.bottomSafe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomSafe),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Flexible(child: PriceText(cart.subtotal, fontSize: 13, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Estimasi Ongkir', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('Rp 10.000', style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                // ── Hierarki tertinggi: total pembayaran ── warna aksen,
                // ukuran terbesar di seluruh footer, Flexible cegah overflow.
                Flexible(child: PriceText(cart.total, fontSize: 19, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Checkout (${cart.totalItems} item)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
