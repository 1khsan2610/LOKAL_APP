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
  String _selectedRatingLabel = 'Semua';
  RangeValues _selectedPriceRange = const RangeValues(0, 500000);
  double _selectedRadius = 5.0;

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

  void _applyFilter({String? searchQuery, String? category, double? minPrice, double? maxPrice, double? minRating, double? radius}) {
    ref.read(productFilterProvider.notifier).state =
        ref.read(productFilterProvider.notifier).state.copyWith(
              searchQuery: searchQuery,
              category: category,
              minPrice: minPrice,
              maxPrice: maxPrice,
              minRating: minRating,
              radius: radius,
            );
  }

  void _updateSearch(String value) {
    _applyFilter(searchQuery: value.trim().isEmpty ? null : value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
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
                  onChanged: _updateSearch,
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
                const SizedBox(height: 16),
                _buildRatingFilters(),
                const SizedBox(height: 16),
                _buildPriceRadiusFilters(),
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
                            'imageUrl': p.images.isNotEmpty ? p.images.first : AppConstants.placeholderImageUrl,
                            'rating': p.rating,
                            'reviewCount': p.reviewCount,
                            'stock': p.stock,
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
                onRetry: () => ref.refresh(filteredProductsProvider),
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

extension on _ProductListScreenState {
  Widget _buildRatingFilters() {
    final ratingOptions = ['Semua', '≥ 4.0', '≥ 3.0', '≥ 2.0'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ratingOptions.map((label) {
            final isSelected = _selectedRatingLabel == label;
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedRatingLabel = label);
                _applyFilter(
                  minRating: label == 'Semua'
                      ? null
                      : double.tryParse(label.replaceAll(RegExp('[^0-9.]'), '')),
                );
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              backgroundColor: Colors.transparent,
              side: BorderSide(color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRadiusFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter Harga', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        RangeSlider(
          values: _selectedPriceRange,
          min: 0,
          max: 1000000,
          divisions: 20,
          labels: RangeLabels(
            'Rp ${_selectedPriceRange.start.toStringAsFixed(0)}',
            'Rp ${_selectedPriceRange.end.toStringAsFixed(0)}',
          ),
          onChanged: (value) {
            setState(() => _selectedPriceRange = value);
            _applyFilter(
              minPrice: value.start > 0 ? value.start : null,
              maxPrice: value.end < 1000000 ? value.end : null,
            );
          },
        ),
        const SizedBox(height: 16),
        Text('Radius', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        Slider(
          value: _selectedRadius,
          min: 1.0,
          max: 20.0,
          divisions: 19,
          label: '${_selectedRadius.toStringAsFixed(0)} km',
          onChanged: (value) {
            setState(() => _selectedRadius = value);
            _applyFilter(radius: value);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${_selectedRadius.toStringAsFixed(0)} km', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
