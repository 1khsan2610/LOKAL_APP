import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  int _imgIdx = 0;
  ProductVariantModel? _selectedVariant;
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _api = ApiService();

  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadDetail(widget.product.id);
    });
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final resp = await _api.getProductReviews(widget.product.id);
      final list = (resp.data['data']['data'] as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList();
      if (mounted) setState(() => _reviews = list);
    } catch (_) {
      // Biarkan list kosong jika gagal memuat
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _editReview(ReviewModel review) async {
    final result = await _showReviewDialog(
      initialRating: review.rating,
      initialComment: review.comment ?? '',
      title: 'Edit Ulasan',
    );
    if (result == null) return;
    try {
      await _api.updateReview(review.id, {
        'rating': result.$1,
        'comment': result.$2,
      });
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Ulasan diperbarui');
      _loadReviews();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal memperbarui ulasan', isError: true);
    }
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Ulasan'),
        content: const Text('Yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteReview(review.id);
      if (!mounted) return;
      AppSnackBar.show(context, '✓ Ulasan dihapus');
      _loadReviews();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Gagal menghapus ulasan', isError: true);
    }
  }

  Future<(int, String)?> _showReviewDialog({
    required int initialRating,
    required String initialComment,
    required String title,
  }) {
    int rating = initialRating;
    final controller = TextEditingController(text: initialComment);
    return showDialog<(int, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
              onPressed: () => setDialogState(() => rating = i + 1),
              icon: Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppTheme.warning, size: 28),
            ))),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis pengalamanmu dengan produk ini...',
                border: OutlineInputBorder(),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: rating == 0 ? null : () => Navigator.pop(ctx, (rating, controller.text.trim())),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    final ok = await context.read<CartProvider>().addItem(
      widget.product.id, _qty,
      variantId: _selectedVariant?.id,
    );
    if (!mounted) return;
    AppSnackBar.show(context, ok ? '✓ Ditambahkan ke keranjang' : 'Gagal menambahkan');
  }

  Future<void> _buyNow() async {
    await _addToCart();
    if (!mounted) return;
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<ProductProvider>().detail;
    final wishlist = context.watch<WishlistProvider>();
    final product = detail?.id == widget.product.id ? detail! : widget.product;
    final isFavorite = wishlist.isFavorite(product.id);
    final images  = product.images;
    final displayPrice = _selectedVariant != null
        ? product.price + _selectedVariant!.priceModifier
        : product.displayPrice;

    return Scaffold(
      body: CustomScrollView(slivers: [
        // AppBar with image
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppTheme.primary,
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              // Main image
              PageView.builder(
                itemCount: images.isEmpty ? 1 : images.length,
                onPageChanged: (i) => setState(() => _imgIdx = i),
                itemBuilder: (_, i) => images.isEmpty
                    ? Container(color: AppTheme.surface2,
                        child: const Center(child: Text('📦', style: TextStyle(fontSize: 80))))
                    : CachedNetworkImage(
                        imageUrl: resolveImageUrl(images[i].url), fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppTheme.surface2),
                        errorWidget: (_, __, ___) => Container(color: AppTheme.surface2,
                          child: const Icon(Icons.image_not_supported_outlined, size: 60)),
                      ),
              ),
              // Page indicator
              if (images.length > 1)
                Positioned(bottom: 12, left: 0, right: 0,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _imgIdx == i ? 18 : 6, height: 6,
                      decoration: BoxDecoration(
                        color: _imgIdx == i ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ),
              // Flash sale badge
              if (product.hasFlashSale)
                Positioned(top: 56, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(8)),
                    child: Text('⚡ -${product.flashSaleDiscount}% FLASH SALE',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
          actions: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
              onPressed: () async {
                final wishlistProvider = context.read<WishlistProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final message = isFavorite ? '💔 Dihapus dari wishlist' : '❤️ Ditambahkan ke wishlist';
                if (!mounted) return;
                await wishlistProvider.toggleFavorite(product);
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text(message)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () => AppSnackBar.show(context, '🔗 Link disalin'),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Price & name
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3)),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(currency.format(displayPrice),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  if (product.hasFlashSale) ...[
                    const SizedBox(width: 8),
                    Text(currency.format(product.price),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textHint,
                        decoration: TextDecoration.lineThrough)),
                  ],
                  const Spacer(),
                  CoinBadge(amount: product.coinReward),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppTheme.warning),
                  const SizedBox(width: 3),
                  Text(product.avgRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(' (${product.soldCount} terjual)',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 14, color: AppTheme.border),
                  const SizedBox(width: 12),
                  const Icon(Icons.inventory_2_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Text('Stok: ${product.stock}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ]),
            ),
            const Divider(height: 8),

            // Seller info
            GestureDetector(
              onTap: () => AppSnackBar.show(context, '🏪 Kunjungi toko ${product.umkm?.name}'),
              child: Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        (product.umkm?.name ?? '?').substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(product.umkm?.name ?? 'UMKM Lokal',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    Text('📍 ${product.umkm?.city ?? ''} · ⭐ ${product.umkm?.avgRating.toStringAsFixed(1) ?? "0"}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                  ])),
                  const Row(children: [
                    Text('Kunjungi', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, size: 16, color: AppTheme.primary),
                  ]),
                ]),
              ),
            ),
            const Divider(height: 8),

            // Variants
            if (product.variants.isNotEmpty) ...[
              Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pilih Varian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: product.variants.map((v) {
                      final sel = _selectedVariant?.id == v.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedVariant = sel ? null : v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.surface2 : AppTheme.surface,
                            border: Border.all(color: sel ? AppTheme.primary : AppTheme.border, width: sel ? 2 : 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(v.value,
                            style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? AppTheme.primary : AppTheme.textPrimary)),
                        ),
                      );
                    }).toList(),
                  ),
                ]),
              ),
              const Divider(height: 8),
            ],

            // Quantity
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Text('Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    _QtyBtn(icon: Icons.remove, onTap: () => setState(() => _qty = (_qty - 1).clamp(1, 99))),
                    SizedBox(width: 40, child: Text('$_qty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                    _QtyBtn(icon: Icons.add, onTap: () => setState(() => _qty = (_qty + 1).clamp(1, product.stock))),
                  ]),
                ),
                const SizedBox(width: 12),
                Text('Stok ${product.stock}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
              ]),
            ),
            const Divider(height: 8),

            // Description
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Deskripsi Produk',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(product.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.7)),
              ]),
            ),
            const Divider(height: 8),

            // Guarantees
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: const Wrap(spacing: 8, runSpacing: 8,
                children: [
                  _InfoChip(icon: '🚚', label: '2-3 Hari Kerja'),
                  _InfoChip(icon: '🛡️', label: 'Garansi Asli'),
                  _InfoChip(icon: '↩️', label: 'Retur 7 Hari'),
                  _InfoChip(icon: '🏭', label: 'Produk UMKM'),
                ],
              ),
            ),
            const Divider(height: 8),

            // Reviews section
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('⭐ Ulasan Pembeli',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${product.avgRating.toStringAsFixed(1)}/5.0',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                ]),
                const SizedBox(height: 12),
                if (_loadingReviews)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ))
                else if (_reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Belum ada ulasan untuk produk ini.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                  )
                else
                  ..._reviews.map((r) {
                    final myId = context.watch<AuthProvider>().user?.id;
                    return _ReviewCard(
                      name: r.userName,
                      rating: r.rating,
                      text: r.comment ?? '',
                      isOwn: myId != null && myId == r.userId,
                      onEdit: () => _editReview(r),
                      onDelete: () => _deleteReview(r),
                    );
                  }),
              ]),
            ),
            const SizedBox(height: 100),
          ]),
        ),
      ]),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Keranjang'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _buyNow,
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text('Beli Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, size: 18, color: AppTheme.primary),
    padding: const EdgeInsets.all(8),
  );
}

class _InfoChip extends StatelessWidget {
  final String icon, label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _ReviewCard extends StatelessWidget {
  final String name, text;
  final int rating;
  final bool isOwn;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.text,
    this.isOwn = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.surface2, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryLight,
          child: Text(name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        Row(children: List.generate(rating, (_) => const Icon(Icons.star_rounded, size: 14, color: AppTheme.warning))),
        if (isOwn) PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textHint),
          onSelected: (v) => v == 'edit' ? onEdit?.call() : onDelete?.call(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit Ulasan')),
            PopupMenuItem(value: 'delete', child: Text('Hapus Ulasan')),
          ],
        ),
      ]),
      const SizedBox(height: 8),
      Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.6)),
    ]),
  );
}
