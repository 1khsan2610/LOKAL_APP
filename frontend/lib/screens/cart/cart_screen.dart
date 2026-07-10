import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
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
              )),
              child: const Text('Hapus Semua', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyState(
              emoji: '🛒', title: 'Keranjang Kosong',
              subtitle: 'Temukan produk UMKM lokal favoritmu!',
              buttonLabel: 'Mulai Belanja',
              onButton: () => context.go('/main'),
            )
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 70, height: 70,
                            child: item.product.primaryImage != null
                                ? Image.network(resolveImageUrl(item.product.primaryImage), fit: BoxFit.cover)
                                : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined, size: 32)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(item.product.umkm?.name ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          const SizedBox(height: 6),
                          PriceText(item.product.displayPrice, fontSize: 14),
                          const SizedBox(height: 8),
                          Row(children: [
                            Container(
                              decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(
                                  onPressed: item.quantity > 1 ? () => cart.updateQuantity(item.id, item.quantity - 1) : null,
                                  icon: const Icon(Icons.remove, size: 16),
                                  padding: const EdgeInsets.all(6), constraints: const BoxConstraints(),
                                  color: AppTheme.primary,
                                ),
                                SizedBox(width: 28, child: Text('${item.quantity}', textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                                IconButton(
                                  onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                                  icon: const Icon(Icons.add, size: 16),
                                  padding: const EdgeInsets.all(6), constraints: const BoxConstraints(),
                                  color: AppTheme.primary,
                                ),
                              ]),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => cart.removeItem(item.id),
                              icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            ),
                          ]),
                        ])),
                      ]),
                    );
                  },
                ),
              ),
              // Bottom summary
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    PriceText(cart.subtotal, fontSize: 13),
                  ]),
                  const SizedBox(height: 4),
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Estimasi Ongkir', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    Text('Rp 10.000', style: TextStyle(fontSize: 13)),
                  ]),
                  const Divider(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    PriceText(cart.total, fontSize: 18, fontWeight: FontWeight.w800),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/checkout'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text('Checkout (${cart.totalItems} item)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }
}
