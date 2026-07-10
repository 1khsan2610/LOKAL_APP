import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _api = ApiService();
  bool _loading = true;
  final List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadWishlistProducts();
  }

  Future<void> _loadWishlistProducts() async {
    setState(() => _loading = true);
    try {
      final ids = context.read<WishlistProvider>().favoriteProductIds;
      if (ids.isEmpty) {
        _products.clear();
        return;
      }

      final futures = ids.map((id) => _api.getProductDetail(id));
      final responses = await Future.wait(futures);
      _products
        ..clear()
        ..addAll(responses.map((response) => ProductModel.fromJson(response.data['data'])).toList());
    } catch (_) {
      _products.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          if (wishlist.favoriteProductIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await context.read<WishlistProvider>().clear();
                _products.clear();
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : wishlist.favoriteProductIds.isEmpty || _products.isEmpty
              ? const EmptyState(
                  emoji: '💛',
                  title: 'Wishlist masih kosong',
                  subtitle: 'Simpan produk favoritmu dari halaman produk untuk melihatnya di sini.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final product = _products[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: product.primaryImage != null
                                ? CachedNetworkImage(
                                    imageUrl: resolveImageUrl(product.primaryImage),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: AppTheme.surface2),
                                    errorWidget: (_, __, ___) => Container(color: AppTheme.surface2),
                                  )
                                : Container(color: AppTheme.surface2, child: const Icon(Icons.image_outlined)),
                          ),
                        ),
                        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${product.price.toString()} • ${product.umkm?.name ?? ''}', maxLines: 2),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: AppTheme.danger),
                          onPressed: () async {
                            await context.read<WishlistProvider>().toggleFavorite(product);
                            await _loadWishlistProducts();
                          },
                        ),
                        onTap: () => context.push('/product/detail/${product.id}'),
                      ),
                    );
                  },
                ),
    );
  }
}
