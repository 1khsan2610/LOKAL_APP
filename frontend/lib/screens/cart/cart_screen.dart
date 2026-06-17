import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  double _coinDiscount = 0.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    if (cartState.items.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: AppStrings.navCart),
        body: EmptyStateWidget(
          icon: '🛒',
          title: 'Keranjang Kosong',
          message: 'Tambahkan produk dari peta pasar atau halaman produk',
          actionLabel: 'Mulai Belanja',
          onAction: () => Navigator.pushNamed(context, '/products'),
        ),
      );
    }

    // Group items by UMKM (shop)
    final groupedByShop = <String, List<CartItemData>>{};
    for (final item in cartState.items) {
      final shopId = item.product.shopId ?? 'default';
      if (!groupedByShop.containsKey(shopId)) {
        groupedByShop[shopId] = [];
      }
      groupedByShop[shopId]!.add(CartItemData(
        item: item,
        shopName: item.product.shopName ?? 'Toko',
      ));
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.navCart,
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StepIndicator(number: 1, label: 'Keranjang', isActive: true),
                Container(
                  height: 2,
                  width: 40,
                  color: AppTheme.dividerColor,
                ),
                _StepIndicator(number: 2, label: 'Pembayaran', isActive: false),
                Container(
                  height: 2,
                  width: 40,
                  color: AppTheme.dividerColor,
                ),
                _StepIndicator(number: 3, label: 'Konfirmasi', isActive: false),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppNumbers.paddingMedium),
              itemCount: groupedByShop.length,
              itemBuilder: (context, shopIndex) {
                final shopId = groupedByShop.keys.elementAt(shopIndex);
                final items = groupedByShop[shopId]!;
                final shopName = items.first.shopName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shopName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Items in this shop
                    ...items.map((itemData) => _CartItemCard(
                      item: itemData.item,
                      onQuantityChanged: (qty) {
                        ref.read(cartProvider.notifier).updateQuantity(
                          itemData.item.product.id,
                          qty,
                        );
                      },
                      onRemove: () {
                        ref.read(cartProvider.notifier).removeItem(
                          itemData.item.product.id,
                        );
                      },
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          // Summary and checkout
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Coin discount toggle
                Card(
                  color: AppTheme.primaryColor.withAlpha((255 * 0.05).round()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppNumbers.paddingMedium,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined,
                                size: 20, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Gunakan Lokal Coin',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Switch(
                          value: _coinDiscount > 0,
                          onChanged: (value) {
                            setState(() {
                              _coinDiscount = value ? 0.1 : 0;
                              ref.read(cartProvider.notifier)
                                  .setCoinDiscount(_coinDiscount);
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Price summary
                _PriceSummary(
                  cartState: cartState,
                  coinDiscount: _coinDiscount,
                ),
                const SizedBox(height: 16),
                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
                      ),
                    ),
                    child: Text(
                      'Lanjut ke Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemData {
  final CartItem item;
  final String shopName;

  CartItemData({required this.item, required this.shopName});
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppNumbers.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(8),
                image: item.product.image != null
                    ? DecorationImage(
                        image: NetworkImage(item.product.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.product.image == null
                  ? const Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: AppTheme.textHint,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${(item.product.price / 1000).toStringAsFixed(1)}k',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls and total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: () =>
                                  onQuantityChanged(item.quantity - 1),
                              size: 28,
                            ),
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  '${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: () =>
                                  onQuantityChanged(item.quantity + 1),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${(item.subtotal / 1000).toStringAsFixed(1)}k',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
              color: Colors.red,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textHint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: isActive ? AppTheme.primaryColor : AppTheme.textHint,
          ),
        ),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final CartState cartState;
  final double coinDiscount;

  const _PriceSummary({
    required this.cartState,
    required this.coinDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = cartState.subtotal;
    final tax = cartState.tax;
    final shipping = cartState.shippingCost;
    final discount = subtotal * coinDiscount;
    final total = subtotal + tax + shipping - discount;

    return Column(
      children: [
        _SummaryRow('Subtotal', subtotal),
        _SummaryRow('Pajak (10%)', tax),
        _SummaryRow('Ongkir', shipping),
        if (coinDiscount > 0) ...[
          const Divider(height: 12),
          _SummaryRow(
            'Diskon Lokal Coin',
            -discount,
            color: Colors.green,
          ),
        ],
        const Divider(height: 12),
        _SummaryRow(
          'Total',
          total,
          isBold: true,
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final Color? color;

  const _SummaryRow(
    this.label,
    this.amount, {
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
          Text(
            'Rp ${(amount / 1000).toStringAsFixed(1)}k',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
