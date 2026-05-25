import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/products_provider.dart';
import '../../widgets/common/custom_widgets.dart' as custom_widgets;
import '../../widgets/product/product_widgets.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: custom_widgets.CustomAppBar(title: 'Produk'),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(AppNumbers.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                custom_widgets.CustomTextField(
                  controller: _searchController,
                  label: 'Cari produk',
                  onChanged: (value) {
                    ref.read(productFilterProvider.notifier).state =
                        ref.read(productFilterProvider.notifier).state.copyWith(
                          searchQuery: value,
                        );
                  },
                ),
                const SizedBox(height: 12),
                // Categories
                Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  data: (categories) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CategoryChip(
                            label: 'Semua',
                            isSelected: _selectedCategory == 'Semua',
                            onSelected: () {
                              setState(() => _selectedCategory = 'Semua');
                              ref
                                  .read(productFilterProvider.notifier)
                                  .state = ref
                                  .read(productFilterProvider.notifier)
                                  .state
                                  .copyWith(category: null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...categories.map((category) {
                            return Row(
                              children: [
                                _CategoryChip(
                                  label: category,
                                  isSelected: _selectedCategory == category,
                                  onSelected: () {
                                    setState(
                                        () => _selectedCategory = category);
                                    ref
                                        .read(
                                            productFilterProvider.notifier)
                                        .state = ref
                                        .read(
                                            productFilterProvider.notifier)
                                        .state
                                        .copyWith(category: category);
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                  loading: () =>
                      const custom_widgets.ShimmerLoader(width: 300, height: 40),
                  error: (e, st) => Text('Error: $e'),
                ),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return custom_widgets.EmptyStateWidget(
                    icon: '🔍',
                    title: 'Produk tidak ditemukan',
                    message: 'Coba ubah pencarian atau filter',
                  );
                }

                return ProductGridView(
                  products: products
                      .map((p) => {
                            'id': p.id,
                            'name': p.name,
                            'price': p.price,
                            'image': p.images.isNotEmpty ? p.images.first : '',
                            'rating': p.rating,
                            'reviewCount': p.reviewCount,
                          })
                      .toList(),
                  onProductTap: (productId) {
                    return () {
                      Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: productId,
                      );
                    };
                  },
                );
              },
              loading: () => GridView.builder(
                padding: const EdgeInsets.all(AppNumbers.paddingMedium),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: 4,
                itemBuilder: (context, index) =>
                    const custom_widgets.ShimmerLoader(width: double.infinity, height: 200),
              ),
              error: (error, st) => custom_widgets.ErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.refresh(productsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
      ),
    );
  }
}
