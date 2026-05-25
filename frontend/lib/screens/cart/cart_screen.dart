import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.navCart),
      body: Column(
        children: [
          // Cart Items
          Expanded(
            child: ListView.builder(
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppNumbers.paddingMedium,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppNumbers.paddingSmall),
                    child: Row(
                      children: [
                        // Product Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image),
                        ),
                        const SizedBox(width: 12),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${item.product.price.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              // Quantity Controls
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          item.quantity - 1,
                                        ),
                                    icon: const Icon(Icons.remove_circle),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          item.quantity + 1,
                                        ),
                                    icon: const Icon(Icons.add_circle),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .removeItem(item.product.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppTheme.errorColor,
                                    ),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Summary & Checkout
          Container(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price breakdown
                _PriceRow(
                  label: 'Subtotal',
                  amount: cartState.subtotal,
                ),
                _PriceRow(
                  label: 'Pajak (10%)',
                  amount: cartState.tax,
                ),
                _PriceRow(
                  label: 'Ongkir',
                  amount: cartState.shippingCost,
                ),
                if (cartState.coinDiscount > 0) ...[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Diskon Lokal Coin',
                    amount: -cartState.discountAmount,
                    color: AppTheme.successColor,
                  ),
                ],
                const Divider(height: 24),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Rp ${cartState.total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/checkout'),
                    child: Text(AppStrings.btnCheckout),
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

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
