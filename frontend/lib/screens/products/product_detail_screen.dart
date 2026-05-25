import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/products_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;
import '../../widgets/product/product_widgets.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(title: 'Detail Produk', showBackButton: true),
      body: productAsync.when(
        data: (product) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                ProductImageCarousel(
                  images: product.images,
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rate,
                              color: AppTheme.warningColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating.toStringAsFixed(1)} (${product.reviewCount} ulasan)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppNumbers.smallBorderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.recommendedPrice != null &&
                                product.recommendedPrice! > 0 &&
                                product.recommendedPrice != product.price)
                              Text(
                                'Rekomendasi: Rp ${product.recommendedPrice!.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.successColor,
                                    ),
                              ),
                            Text(
                              'Rp ${product.price.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stock
                      Row(
                        children: [
                          const Icon(Icons.inventory_2,
                              size: 20, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            product.stock > 0
                                ? 'Stok: ${product.stock}'
                                : 'Stok habis',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),

                      // Attributes
                      if (product.attributes != null && product.attributes!.isNotEmpty) ...[
                        Text(
                          'Spesifikasi',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppNumbers.paddingSmall),
                            child: Column(
                              children: product.attributes!.entries
                                  .map((entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        entry.value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const custom_widgets.LoadingWidget(message: 'Memuat produk...'),
        error: (error, st) => custom_widgets.ErrorWidget(message: error.toString()),
      ),
      bottomNavigationBar: productAsync.when(
        data: (product) {
          return Container(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                top: BorderSide(color: AppTheme.dividerColor),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: product.stock > 0
                    ? () {
                        ref
                            .read(cartProvider.notifier)
                            .addItem(product);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('Produk ditambahkan ke keranjang'),
                          ),
                        );
                      }
                    : null,
                child: product.stock > 0
                    ? const Text('Tambah ke Keranjang')
                    : const Text('Stok Habis'),
              ),
            ),
          );
        },
        loading: () => Container(),
        error: (error, st) => Container(),
      ),
    );
  }
}
