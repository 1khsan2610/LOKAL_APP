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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppNumbers.paddingMedium),
              itemCount: cartState.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: AppNumbers.paddingMedium),
                  elevation: AppNumbers.elevationMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(AppNumbers.smallBorderRadius),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 32,
                            color: AppTheme.textHint,
                          ),
                        ),
                        const SizedBox(width: AppNumbers.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp ${item.product.price.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppNumbers.paddingSmall),
                              Row(
                                children: [
                                  _QuantityButton(
                                    icon: Icons.remove_circle_outline,
                                    onTap: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          item.quantity - 1,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.quantity}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(width: 8),
                                  _QuantityButton(
                                    icon: Icons.add_circle_outline,
                                    onTap: () => ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(
                                          item.product.id,
                                          item.quantity + 1,
                                        ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .removeItem(item.product.id),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppNumbers.paddingMedium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${item.subtotal.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: AppNumbers.elevationSmall,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ringkasan Belanja',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppNumbers.paddingMedium),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppNumbers.borderRadius),
                  ),
                  elevation: 0,
                  color: AppTheme.dividerColor.withAlpha((255 * 0.2).round()),
                  child: Padding(
                    padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Subtotal',
                          amount: cartState.subtotal,
                        ),
                        _PriceRow(
                          label: 'Pajak 10%',
                          amount: cartState.tax,
                        ),
                        _PriceRow(
                          label: 'Ongkir',
                          amount: cartState.shippingCost,
                        ),
                        if (cartState.coinDiscount > 0) ...[
                          const SizedBox(height: AppNumbers.paddingSmall),
                          _PriceRow(
                            label: 'Diskon Lokal Coin',
                            amount: -cartState.discountAmount,
                            color: AppTheme.successColor,
                          ),
                        ],
                        const Divider(height: AppNumbers.paddingLarge),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppNumbers.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppNumbers.smallBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.dividerColor.withAlpha((255 * 0.2).round()),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
